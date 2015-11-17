# Datawire Microwizard

The Datawire Microwizard is a Getting Started tool for developers with no experience with microservice architectures who want to learn more about them. It lets you get your feet wet and see some of the benefits of microservices by starting with a common adoption pattern: adding a single microservice to an existing monolith (as the first step in migrating from a monolith to a microservices architecture). This enables more rapid feature development of the new service without any possibility of unintentionally inducing bugs into the existing code.

By default, Microwizard ships with and uses an existing Ruby on Rails application named
[Lobsters](https://github.com/jcs/lobsters) as the demonstration monolith. We will walk you through how to add new functionality to the main Lobsters application by creating a microservice in Python (you do not need to know Python to understand this example).

# Architecture Overview and Issues #

First and foremost it is important to understand that this system was built as a demo. Certain architectural choices were made that would likely not be acceptable in a production microservices environment. These decisions were made because the premise of the demo was to show people how they could get started with microservices rather than to provide a true generic reference architecture.

All of the services in the architecture were designed to run inside of a container. For the most part we have hidden the container image build process away from the developer in this demo. During the initial provisioning process we build a base Docker image that contains Datawire components such as Watson and Sherlock (/docker/images/base). We expect most developers to base their service images on this particular image for convenience rather than generating their own. However, this is not a hard requirement.

One of the bigger flaws in the design right now is that to properly map service addresses into the Datawire directory we need to mount the host controller Docker process as a volume onto each service. This allows us to query the ephemeral port assigned to the service by Docker so that we can properly map the address into the Directory. The major problem with this approach is that individual containers have read/write access to the entire Docker environment which is not ideal. A more robust solution would be to maintain a separate mapping of ports which we tell Docker about when launching a new container. Another approach would be to run a process on the host machine that queries the API for container locations.

[[JMK is the read/write access a security risk? something else? I feel like a very brief explanation of why this is not good would improve this]]

[[PAL: Yes it is a large security risk because it means a container has access to the entire operating environment including the ability to destroy other containers.]]

#Requirements

The Microwizard base system runs inside of a VirtualBox VM. We provision the VM using Vagrant and then use a combination of shell scripts, Ansible playbooks, and custom code to smooth over the experience. Developers should have the following software installed before trying to use Datawire Microwizard:

| Software | Version | Instructions |
| -------- | ------- | ------------------------- |
| Ansible  | >=1.9.4 | [Install](http://docs.ansible.com/ansible/intro_installation.html) |
| Vagrant  | >=1.7.4 | [Install](https://docs.vagrantup.com/v2/installation/index.html) |
| VirtualBox | >= 5.0 | [Install](https://www.virtualbox.org/wiki/Downloads) |

#Quick Start

1. Clone the MicroWizard project on GitHub, as well as some of the Git submodules linked into this repository: 

`git clone --recursive git@github.com:datawire/microwizard.git`

2. Start vagrant by running `vagrant up`. This will take a few minutes as the Microwizard bootstraps inside the VM.
3. Once the initial provisioning has completed run `./scripts/lobsters-up` to bring up the demonstration monolith application. Be patient - it can take anywhere from 3 to 5 minutes for Lobsters to fully provision itself for use.
4. Go to http://127.0.0.1:3000/ to see the Lobster application running.

# Checking the Environment #

As mentioned above, once the system is bootstrapped you should be able to access the Lobsters application by navigating to http://127.0.0.1:3000 in a web browser. This represents the monolith application prior to adding any new microservices. Occasionally this component will not be available immediately after Microwizard provisions because dependencies are still being pulled from the internet. Keep trying and it usually becomes available within a minute or two.

[[JMK The entire paragraph above seem redundant given the last line above]]

[[PAL: Prolly needs some reworking. The command tends to exit faster than the provisioning of lobsters so the app won't be up when the lobsters-up command finishes. This is probably an area for improvement code-wise. Basically poll to see if it's up before returning. For now we'll just need to document around it and mention it will be at 127.0.0.1:3000 but it needs a minute or two and just keep refrshing]]

You'll notice that this web page has a link at the top called "Most Popular Users" - this is not normally present in a standard Lobsters install. The link has been created for you and will generate a new web page with data populated from a new microservice.

[[JMK Is this link part of the microservice or did we make a change to Lobsters to display it and link to the microservice location?]]

[[PAL: Link is a modification to the Lobsters monolith itself]]

# Fun Part - Launching a microservice!#

1. Open up `src/lobsters-popularity/popularity.py`. This is our microservice. Notice that it starts a simple web server and exposes two URLs: / and /health. /health is for processing health checks and / provides the meat of the service by querying the MySQL DB
for the most popular Lobsters users (as determined by Karma)

[[JMK where did the MySQL and Karma come in? They were not mentioned as part of the system before]]

[[PAL: MySQL is implementation detail of the monolith. Lobsters needs MySQL to run. It runs in its own container right now alongside everything else. It's the "MySQL service" for lack of a better way to phrase it. As for karma, that's just points like on HN or Reddit. Karma is the thing we are aggregating and showing]]

2. In the base deployment of the Microwizard example at http://localhost:3000/popular you'll notice that no users are displayed and a string like "NO SERVICES AVAILABLE" is shown. This is because no services are deployed by default.

3. Let's deploy a service! Leave the popularity.py file as it is for the moment and run the following commands to launch three new lobster-popularity microservices

```
./scripts/svrun lobsters-popularity lobpop_v1 UNCOMMITTED_COPY
./scripts/svrun lobsters-popularity lobpop_v1 UNCOMMITTED_COPY
./scripts/svrun lobsters-popularity lobpop_v1 UNCOMMITTED_COPY
```

The UNCOMMITTED_COPY argument tells the Microwizard service that it should take the current state of your repository instead of deploying from the official system of record at GitHub; copy it to a new directory on the Docker host and then mount the code as a Docker volume. Effectively this means you are running your current changes when the service starts.

[[JMK copy what? am I supposed to already know how to use Docker? We said above that we just need Vagrant, Ansible, and VirtualBox - where did Docker come in ETA: by moving the architectures/issues section to the top we provide some of the context needed for this instruction to make sense, but we still assume that folks know how to use Docker - if we want this to be a requirement we should list it as such. If not, we should provide some instructions or a link with instructions]]

[[PAL: You're not copying anything. I'm explaining what it does behind the scenes. When you invoke svrun with UNCOMMITTED_COPY then it copies your source tree and mounts it as a Docker volume. You are correct that the end user does not need to know how this works, but I'm describing what's occuring behind the scenes a bit... I'm open to better ideas about how to frame this]]

4. Once the containers are deployed, go back to http://127.0.0.1:3000/popular and you should see some data on the page including statistical information like the query speed and which service handled the request.

5. Let's make a bad modification to our service and then do a canary deploy to only one microservice instance. Open up the popularity.py file and find the following two lines:

[[JMK do we need to define canary deploy? or we could just omit the word and just say deploy to only one instance]]

[[PAL: Maybe? A canary deploy is when you rollout a small subset of your service (like 1) and then test to make sure it works. If it works, then you rollout more otherwise you roll it back]]

```
#users = inefficient_query()
users = efficient_query()
```

Change the code to look like this:

```
users = inefficient_query()
#users = efficient_query()
```

6. Roll out one of the poorly implemented services:

```./scripts/svrun lobsters-popularity lobpop_v2 UNCOMMITTED_COPY```

[[JMK Is this a new instance? Your description above (which I edited slightly) made it seem like we were updating one of the three existing instances]]

[[PAL: new instance]]

7. Once it is up and running, refresh the http://localhost:3000/popular page repeatedly. You should notice that occasionally the page takes a long time to load. This is because Baker Street is routing to the service with the inefficient code. Note that even though the service is operating slowly it is not causing the rest of the application to grind to a halt!

[[JMK how can we tell? all we're looking at is the microservice - can we go somewhere else and see other things operating smoothly while the microservice page is slow?]]

[[PAL Sure click any of the other links in the Lobsters application]]

8. To remove the bad service run the following command:

```./scripts/svkill lobpop_v2```

[[JMK we should loop back and show that the page loads quickly again]]

[[PAL Good Idea]]

# Microwizard Architecture #

How does this all work?

The demonstration is composed of the following pieces which all run inside Docker containers:

1. Lobsters Ruby on Rails application
2. MariaDB (open source MySQL fork)
3. Popularity microservice written in Python Flask.
4. Baker Street

Microservices are written so that during initialization of their container they connect to the Datawire Directory which powers Baker Street's powerful service discovery mechanism. Microservices should have a directory called microwizard/ in their root project directory. This directory contains three important files:

1. datawire.conf - configures Datawire settings 
2. microwizard.yml - describes the deployment to Microwizard
3. mw.sh - your services initialization and startup routines.

When modifying datawire.conf for your microserice the only relevant fields for a developer are service_name, service_url, and health_check_url.
When modifying microwizard.yml ensure that service_name matches the service_name in datawire.conf also update the service_port to the same value in datawire.conf service_url.
When modifying mw.sh then all that's required is to implement the body of the init and run bash functions.

# How it works #

1. Microservice code is committed into a Git repository.
2. When a new service is launched then Microwizard performs a checkout against the specified Git commit. The checked out code is moved into a directory specifically for that commit. Microwizard then launches a container and mounts the source code as a volume on the container.
3. The container starts and runs some initialization logic (see docker/images/lobsters-popularity/init directory).
4. The container then starts the service process.
5. Sherlock and Watson are automatically installed on the container so when the service starts it automatically registers with the Datawire directory.

# Implementing Custom Microservices #

Implementing a custom microservice is really simple. The provisioning system baked with MicroWizard means you only need to concentrate on application/service code and can forget about deployment and wiring.

1. Copy the template microservice
2. Modify the template microwizard.yml file with your service name, exposed port and necessary links
3. Modify the mw.sh script and update the init and run functions as necessary.

# FAQ #

