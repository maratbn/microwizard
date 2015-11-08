# Datawire Microwizard #

The Datawire Microwizard is a sandbox tool for playing with microservices. It is a very basic reference architecture for building, deploying and fiddling about with microservices.

At the moment we envision Microwizard as a Getting Started tool for developers that zero experience with microservice architectures. In its current state it's a great tool for getting your feet wet and seeing what the benefits of microservices. A common challenge that developers face in developing microservices is how to migrate from a monolith to a microservices architecture. The Playground is intended to serve as an example on how to add a single microservice to an existing monolith, enabling more rapid feature development.

The Playground uses an existing Ruby on Rails application named
[Lobsters](https://github.com/jcs/lobsters) as an existing application, and adds functionality to the main application via a new Python microservice.

# Requirements #

The Microwizard base system runs inside of a VirtualBox VM. We provision the VM using Vagrant and then use a combination of shell scripts, Ansible playbooks and custom code to smooth over the experience. Developers at a minimum should have the following software installed:

| Software | Version | Instructions |
| -------- | ------- | ------------------------- |
| Ansible  | >=1.9.4 | [Install](http://docs.ansible.com/ansible/intro_installation.html) |
| Vagrant  | >=1.7.4 | [Install](https://docs.vagrantup.com/v2/installation/index.html) |
| VirtualBox | >= 5.0 | [Install](https://www.virtualbox.org/wiki/Downloads) |

# Quick Start #

#. Clone the Playground project on GitHub, as well as some of the Git submodules linked into this repository: 

`git clone --recursive git@github.com:datawire/microwizard.git`

#. Run `vagrant up`. This will take a few minutes as the Microwizard bootstraps inside the VM.

#. Run `install.sh`, which will prepopulate the system with some test data.
   
#. Go to http://localhost:3000/ to see the Lobster webapp running.

Now the fun part:

#. We introduce a bug in the popularity component, e.g., the
popularity algorithm takes 1000 longer to compute. We make the change
live.
  - Notice how the website still works even though the popularity calc doesn't appear for awhile
  - If this were in the monolith the monolith would grind to a halt

#. Fix the code, and do an incremental rollout of the code.
   - Make sure no regressions, you can see for 50% of the loads it's pretty fast and for the other 50% it's not


This is what's great about microservices:

 - independently deployable code
 - resilience to software bugs


# Checking the Environment #

Once the system is bootstrapped you should be able to access the Lobsters application by navigating a web browser to http://localhost:3000 which for the purpose of this little example tool represents our "Monolith" application that we will glue microservice functionality onto.

You'll notice that once you reach that web page there is a link at the top "Most Popular Users" that is not normally present in a standard Lobsters install. This link has been created for you and will generate a web page that has data populated from a web service.

# Fun Part #

1. Open up src/lobsters-popularity/popularity.py. This is a very simple program that will act as a microservice in our environment. Notice that it starts a simple little web server and exposes two URLs. One URL is /health and this is where healthchecks will be sent. The other URL is / and it provides the meat of the service by querying the MySQL DB for the most popular users (as determined by Karma)

2. In the base deployment of the Microwizard example you'll notice that if you go to http://localhost:3000/popular then no users will be displayed and a string like "NO SERVICES AVAILABLE" will be shown. This is because in the base deployment no services are deployed.

3. Let's deploy a service. The lobsters-popularity service project comes with two Git committed files that are ready to use for this demo. Let's deploy a couple of the healthy services into the environment, run the following commands:

`./scripts/svrun lobpop_v1 149d2b0147b6f95cdb3234dc0922842acb911a79`
`./scripts/svrun lobpop_v1 149d2b0147b6f95cdb3234dc0922842acb911a79`

The `149d2b0147b6f95cdb3234dc0922842acb911a79` part is a git commit hash. Microwizard works by deploying Git repositories and using a specific hash. The first time you run the command it may take a moment as the container image for lobsters-popularity is built.

4. Once the containers are deployed go back to http://localhost:3000/popular and you should see some data on the page. Some other statistical information is displayed like the query speed and which service handled the request.

5. Let's deploy a slightly broken service. The broken service runs very slowly in comparison to the previous two ones. It can be deployed by using the following command:

`./scripts/svrun lobpop_v2 3c35bc4587fb266f30e08de67eec709f7fd6f365`

6. Once it is up and running refresh the http://localhost:3000/popular page and you should notice that occasionally the page takes a long time to load. This is because Baker Street is routing to the service, hoever, even though the service is operating slowly it is not causing the rest of the application to grind to a halt!

# Microwizard Architecture #

How does this all work?

* The monolithic Lobsters Ruby on Rails application, running in a Docker container
* MariaDB
* The popularity microservice, written as a Python application
* A simple service discovery service




# Building a new Microservice #

Let's build a new containerized Microservice...

# Launching the Microservices #

Launching a new microservice

* Service implements a new feature... let's call it the popularity service which returns the most popular users by their
karma

* Implement the service in Python or Node.
* Communicate with MariaDB to run the simple query
* Actually launches two of these services 

# Consuming the Microservice #

How to use the microservice from inside their dev and production environments

* Update Lobster to have a new URL that communicates with the Popularity Service
* Renders that data

# How it works #

1. Microservice code is committed into a Git repository.
2. When a new service is launched then Microwizard performs a checkout against the specified Git commit. The checked out code is moved into a directory specifically for that commit. Microwizard then launches a container and mounts the source code as a volume on the container.
3. The container starts and runs some initialization logic (see docker/images/lobsters-popularity/init directory).
4. The container then starts the service process.
5. Sherlock and Watson are automatically instalelled on the container so when the service starts it automatically registers with the Datawire directory.

# FAQ #

