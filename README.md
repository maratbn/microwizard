# Datawire Microwizard #

The Datawire Microwizard is a Getting Started tool for developers with no experience with microservice architectures who want to learn more about them. It lets you get your feet wet and see some of the benefits of microservices by starting with a common adoption pattern: adding a single microservice to an existing monolith (as the first step in migrating from a monolith to a microservices architecture). This enables more rapid feature development of the new service without any possibility of unintentionally inducing bugs into the existing code.

By default, Microwizard ships with and uses an existing Ruby on Rails application named
[Lobsters](https://github.com/jcs/lobsters) as the demonstration monolith. We will walk you through how to add new functionality to the main Lobsters application by creating a microservice in Python (you do not need to know Python to understand this example).

# Requirements #

The Microwizard base system runs inside of a VirtualBox VM. We provision the VM using Vagrant and then use a combination of shell scripts, Ansible playbooks, and custom code to smooth over the experience. Developers should have the following software installed before trying to use Datawire Microwizard:

| Software | Version | Instructions |
| -------- | ------- | ------------------------- |
| Ansible  | >=1.9.4 | [Install](http://docs.ansible.com/ansible/intro_installation.html) |
| Vagrant  | >=1.7.4 | [Install](https://docs.vagrantup.com/v2/installation/index.html) |
| VirtualBox | >= 5.0 | [Install](https://www.virtualbox.org/wiki/Downloads) |

# Quick Start #

1. Clone the MicroWizard project on GitHub, as well as some of the Git submodules linked into this repository: 

`git clone --recursive git@github.com:datawire/microwizard.git`

2. Start vagran by running `vagrant up`. This will take a few minutes as the Microwizard bootstraps inside the VM.
3. Once the initial provisioning has completed run `./scripts/lobsters-up` to bring up the demonstration monolith application. Be patient - it can take anywhere from 3 to 5 minutes for Lobsters to fully provision itself for use.
4. Go to http://127.0.0.1:3000/ to see the Lobster application running.

# Checking the Environment #

Once the system is bootstrapped, you should be able to access the Lobsters application by navigating a web browser to http://127.0.0.1:3000 which represents our monolith application that we will glue microservice functionality onto. Occasionally this component will not be available immediately after Microwizard provisions because dependencies and other Rails stuff are still being pulled from the internet. Just keep trying and it usually becomes available within a minute or two.

[[JMK The entire paragraph above seem redundant given the last line above]]

You'll notice that once you reach that web page there is a link at the top "Most Popular Users" that is not normally present in a standard Lobsters install. The link has been created for you and will generate a web page that has data populated from a web service.

[[JMK Is this link part of the microservice or did we make a change to Lobsters to display it and link to the microservice location?]]

# Fun Part #

1. Open up `src/lobsters-popularity/popularity.py`. This is our microservice. Notice that it starts a simple little web server and exposes two URLs: / and /health. /health is for processing health checks and / provides the meat of the service by querying the MySQL DB
for the most popular Lobsters users (as determined by Karma)

[[JMK where did the MySQL and Karma come in? They were not mentioned as part of the system before]]

2. In the base deployment of the Microwizard example at http://localhost:3000/popular you'll notice that no users are displayed and a string like "NO SERVICES AVAILABLE" is shown. This is because no services are deployed by default.

3. Let's deploy a service! Leave the popularity.py file as it is for the moment and run the following commands to launch three new lobster-popularity microservices

```
./scripts/svrun lobsters-popularity lobpop_v1 UNCOMMITTED_COPY
./scripts/svrun lobsters-popularity lobpop_v1 UNCOMMITTED_COPY
./scripts/svrun lobsters-popularity lobpop_v1 UNCOMMITTED_COPY
```

The UNCOMMITTED_COPY argument tells the Microwizard service that it should take the current state of your repository instead of deploying from the official system of record at GitHub; copy it to a new directory on the Docker host and then mount the code as a Docker volume. Effectively this means you are running your current changes when the service starts.

[[JMK copy what? am I supposed to already know how to use Docker? We said above that we just need Vagrant, Ansible, and VirtualBox - where did Docker come in]]

4. Once the containers are deployed go back to http://127.0.0.1:3000/popular and you should see some data on the page. Some other statistical information is displayed like the query speed and which service handled the request.

5. Let's make a bad modification to our service and then do a canary deploy to only one microservice instance. Open up the popularity.py file and find the following two lines:

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

7. Once it is up and running refresh the http://localhost:3000/popular page and you should notice that occasionally the page takes a long time to load. This is because Baker Street is routing to the service with the inefficient code. Note that even though the service is operating slowly it is not causing the rest of the application to grind to a halt!

8. To remove the bad service run the following command:

```./scripts/svkill lobpop_v2```

[[JMK we should loop back and show that the page loads quickly again]]

[[JMK Stopped editing here (for now)]]

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

# Architecture Overview and Issues #

First and foremost it is important to understand that this was built as a demo. Certain architectural choices were made that would likely not be OK in a production microservices environment. These decisions were made because the premise of the demo was to show people how they could get started with microservices rather than to provide a true generic reference architecture.

All the services in the architecture were designed to run inside of a container. For the most part we have hidden the container image build process away from the developer in this demo. During the initial provisioning process we build a base Docker image that contains Datawire components such as Watson and Sherlock (/docker/images/base). Developers for convenience are expected to base their service images off this particular image rather than generating their own, however, it is not a hard requirement to do that.

One of the bigger flaws in the design right now is that in order to properly map service addresses into the Datawire directory we need to mount the host controller Docker process as a volume onto each service. This allows us to then query the ephemeral port assigned by Docker to the service so that we can properly map the address into the Directory. The major problem with this approach is that individual containers then have read/write access to the entire Docker environment which is likely not desireable. A more robust solution would be to maintain our own mapping of ports which we then tell Docker about when running a new container. Another approach would be to run a process on the host machine that can query the API for containers.

# Implementing Custom Microservices #

Implementing a custom microservice is really simple. The provisioning system baked with MicroWizard means you only need to concentrate on application/service code and can forget about deployment and wiring.

1. Copy the template microservice
2. Modify the template microwizard.yml file with your service name, exposed port and necessary links
3. Modify the mw.sh script and update the init and run functions as necessary.

# FAQ #

