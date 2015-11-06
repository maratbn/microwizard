require 'net/http'
require 'json'

class HomeController < ApplicationController
  # for rss feeds, load the user's tag filters if a token is passed
  before_filter :find_user_from_rss_token, :only => [ :index, :newest ]
  before_filter { @page = page }
  before_filter :require_logged_in_user, :only => [ :upvoted ]

  def about
    begin
      render :action => "about"
    rescue
      render :text => "<div class=\"box wide\">" <<
        "A mystery." <<
        "</div>", :layout => "application"
    end
  end

  def chat
    render :action => "chat"
  end

  def privacy
    begin
      render :action => "privacy"
    rescue
      render :text => "<div class=\"box wide\">" <<
        "You apparently have no privacy." <<
        "</div>", :layout => "application"
    end
  end

  def hidden
    @stories, @show_more = get_from_cache(hidden: true) {
      paginate stories.hidden
    }

    @heading = @title = "Hidden Stories"
    @cur_url = "/hidden"

    render :action => "index"
  end

  def index
    @stories, @show_more = get_from_cache(hottest: true) {
      paginate stories.hottest
    }

    @rss_link ||= { :title => "RSS 2.0",
      :href => "/rss#{@user ? "?token=#{@user.rss_token}" : ""}" }
    @comments_rss_link ||= { :title => "Comments - RSS 2.0",
      :href => "/comments.rss#{@user ? "?token=#{@user.rss_token}" : ""}" }

    @heading = @title = ""
    @cur_url = "/"

    respond_to do |format|
      format.html { render :action => "index" }
      format.rss {
        if @user && params[:token].present?
          @title = "Private feed for #{@user.username}"
        end

        render :action => "rss", :layout => false
      }
      format.json { render :json => @stories }
    end
  end

  def newest
    @stories, @show_more = get_from_cache(newest: true) {
      paginate stories.newest
    }

    @heading = @title = "Newest Stories"
    @cur_url = "/newest"

    @rss_link = { :title => "RSS 2.0 - Newest Items",
      :href => "/newest.rss#{@user ? "?token=#{@user.rss_token}" : ""}" }

    respond_to do |format|
      format.html { render :action => "index" }
      format.rss {
        if @user && params[:token].present?
          @title += " - Private feed for #{@user.username}"
        end

        render :action => "rss", :layout => false
      }
      format.json { render :json => @stories }
    end
  end

  def newest_by_user
    by_user = User.where(:username => params[:user]).first!

    @stories, @show_more = get_from_cache(by_user: by_user) {
      paginate stories.newest_by_user(by_user)
    }

    @heading = @title = "Newest Stories by #{by_user.username}"
    @cur_url = "/newest/#{by_user.username}"

    @newest = true
    @for_user = by_user.username

    render :action => "index"
  end

  def recent
    @stories, @show_more = get_from_cache(recent: true) {
      scope = if page == 1
        stories.recent
      else
        stories.newest
      end
      paginate scope
    }

    @heading = @title = "Recent Stories"
    @cur_url = "/recent"

    # our content changes every page load, so point at /newest.rss to be stable
    @rss_link = { :title => "RSS 2.0 - Newest Items",
      :href => "/newest.rss#{@user ? "?token=#{@user.rss_token}" : ""}" }

    render :action => "index"
  end

  def tagged
    @tag = Tag.where(:tag => params[:tag]).first!

    @stories, @show_more = get_from_cache(tag: @tag) {
      paginate stories.tagged(@tag)
    }

    @heading = @title = @tag.description.blank?? @tag.tag : @tag.description
    @cur_url = tag_url(@tag.tag)

    @rss_link = { :title => "RSS 2.0 - Tagged #{@tag.tag} (#{@tag.description})",
      :href => "/t/#{@tag.tag}.rss" }

    respond_to do |format|
      format.html { render :action => "index" }
      format.rss { render :action => "rss", :layout => false }
      format.json { render :json => @stories }
    end
  end

  TOP_INTVS = { "d" => "Day", "w" => "Week", "m" => "Month", "y" => "Year" }
  def top
    @cur_url = "/top"
    length = { :dur => 1, :intv => "Week" }

    if m = params[:length].to_s.match(/\A(\d+)([#{TOP_INTVS.keys.join}])\z/)
      length[:dur] = m[1].to_i
      length[:intv] = TOP_INTVS[m[2]]

      @cur_url << "/#{params[:length]}"
    end

    @stories, @show_more = get_from_cache(top: true, length: length) {
      paginate stories.top(length)
    }

    if length[:dur] > 1
      @heading = @title = "Top Stories of the Past #{length[:dur]} " <<
        length[:intv] << "s"
    else
      @heading = @title = "Top Stories of the Past " << length[:intv]
    end

    render :action => "index"
  end

  def upvoted
    @stories, @show_more = get_from_cache(upvoted: true, user: @user) {
      paginate @user.upvoted_stories.order('votes.id DESC')
    }

    @heading = @title = "Your Upvoted Stories"
    @cur_url = "/upvoted"

    @rss_link = { :title => "RSS 2.0 - Your Upvoted Stories",
      :href => "/upvoted.rss#{(@user ? "?token=#{@user.rss_token}" : "")}" }

    respond_to do |format|
      format.html { render :action => "index" }
      format.rss {
        if @user && params[:token].present?
          @title += " - Private feed for #{@user.username}"
        end

        render :action => "rss", :layout => false
      }
      format.json { render :json => @stories }
    end
  end

  # -----------------------
  # DATAWIRE INCISION POINT
  # -----------------------

  def most_popular
    @heading = @title = "Most Popular Users"
    @cur_url = "/popular"

    t1 = Time.now
    url = URI.parse('http://localhost:8000/lobsters-popularity')
    #res = Net::HTTP.get(URI.parse('http://localhost:8000/lobsters-popularity'))
    #req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host, url.port) { |http|
      http.get("/lobsters-popularity")
    }
    t2 = Time.now

    def time_diff_milli(start, finish)
      (finish - start) * 1000.0
    end

    if res.code == "200"
      data = JSON.parse(res.body)
      @users = data['users']
      @service_id = data['service_id']
      @query_time = time_diff_milli t1, t2
    else
      @service_id = "NO SERVICES AVAILABLE"
      @users = JSON.parse('[]')
      @query_time = 0
    end

    respond_to do |format|
      format.html { render :action => "most_popular" }
    end
  end

private
  def filtered_tag_ids
    if @user
      @user.tag_filters.map{|tf| tf.tag_id }
    else
      tags_filtered_by_cookie.map{|t| t.id }
    end
  end

  def stories
    StoryRepository.new(@user, exclude_tags: filtered_tag_ids)
  end

  def page
    params[:page].to_i > 0 ? params[:page].to_i : 1
  end

  def paginate(scope)
    StoriesPaginator.new(scope, page, @user).get
  end

  def get_from_cache(opts={}, &block)
    if Rails.env.development? || @user || tags_filtered_by_cookie.any?
      yield
    else
      key = opts.merge(page: page).sort.map{|k,v| "#{k}=#{v.to_param}"
        }.join(" ")
      Rails.cache.fetch("stories #{key}", :expires_in => 45, &block)
    end
  end
end
