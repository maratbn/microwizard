# Datawire Microwizard

The Datawire Microwizard is a Getting Started tool for developers with no experience with microservice architectures who want to learn more about them. It lets you get your feet wet and see some of the benefits of microservices by starting with a common adoption pattern: adding a single microservice to an existing monolith (as the first step in migrating from a monolith to a microservices architecture). This enables more rapid feature development of the new service without any possibility of unintentionally inducing bugs into the existing code.

By default, Microwizard ships with and uses an existing Ruby on Rails application named
[Lobsters](https://github.com/jcs/lobsters) as the demonstration monolith. We will walk you through how to add new functionality to the main Lobsters application by creating a microservice in Python (you do not need to know Python to understand this example).

# Architecture Overview and Issues #

First and foremost it is important to understand that this system was built as a demo. Certain architectural choices were made that would likely not be acceptable in a production microservices environment. These decisions were made because the premise of the demo was to show people how they could get started with microservices rather than to provide a true generic reference architecture.

All of the services in the architecture were designed to run inside of a container. For the most part we have hidden the container image build process away from the developer in this demo. During the initial provisioning process we build a base Docker image that contains Datawire components such as Watson and Sherlock (/docker/images/base). We expect most developers to base their service images on this particular image for convenience rather than generating their own. However, this is not a hard requirement.

One of the bigger flaws in the design right now is that to properly map service addresses into the Datawire directory we need to mount the host controller Docker process as a volume onto each service. This allows us to query the ephemeral port assigned to the service by Docker so that we can properly map the address into the Directory. The major problem with this approach is that individual containers have read/write access to the entire Docker environment which is a potential security risk - each container has access to the entire environment including the ability to destroy other containers. A more robust solution would be to maintain a separate mapping of ports which we tell Docker about when launching a new container. Another approach would be to run a process on the host machine that queries the API for container locations.

#Requirements

The Microwizard base system runs inside of a VirtualBox VM. We provision the VM using Vagrant and then use a combination of shell scripts, Ansible playbooks, and custom code to smooth over the experience. Developers should have the following software installed before trying to use Datawire Microwizard:

| Software | Version | Instructions |
| -------- | ------- | ------------------------- |
| Ansible  | >=1.9.4 | `pip ansible install` or see the official [install](http://docs.ansible.com/ansible/intro_installation.html) instructions |
| Vagrant  | >=1.7.4 | [Install](https://docs.vagrantup.com/v2/installation/index.html) |
| VirtualBox | >= 5.0 | [Install](https://www.virtualbox.org/wiki/Downloads) |

#Quick Start

1. Clone the MicroWizard project on GitHub, as well as some of the Git submodules linked into this repository: 

`git clone --recursive git@github.com:datawire/microwizard.git`

Note: Using the --recursive flag is equivalent to running `git submodule init && git submodule update` after a normal git clone command. 

2. Start vagrant by running `vagrant up`. This will take some time as the Microwizard bootstraps inside the VM, possibly as long as 15-20 minutes depending on your system - be patient, this step is automating a lot of configuration so you don't have to do it manually.
3. Once the initial provisioning has completed run `./scripts/lobsters-up` to bring up the demonstration monolith application. Note that it usually takes from 3 to 5 minutes for Lobsters to fully provision itself for use (and can take even longer at times).
4. Go to http://127.0.0.1:3000/ to see the Lobster application running.

# Checking the Environment #

As mentioned above, once the system is bootstrapped you should be able to access the Lobsters application by navigating to http://127.0.0.1:3000 in a web browser. This represents the monolith application prior to adding any new microservices.

You'll notice that this web page has a link at the top called "Most Popular Users" - this is not normally present in a standard Lobsters install; we added it to the monolith to provide access to data from the new microservice.

# Fun Part - Launching a microservice!#

1. Open up `src/lobsters-popularity/popularity.py`. This is our microservice. Notice that it starts a simple web server and exposes two URLs: / and /health. /health is for processing health checks and / provides the meat of the service by querying the MySQL DB used by the existing monolith for the most popular Lobsters users (as determined by karma points)

2. In the base deployment of the Microwizard example at http://127.0.0.1:3000/popular you'll notice that no users are displayed and the string "NO SERVICES AVAILABLE" is shown. This is because no services are deployed by default.

3. Let's deploy a service! Leave the popularity.py file as it is for the moment and run the following commands to launch three new lobster-popularity microservices

```
./scripts/svrun lobsters-popularity lobpop_v1 UNCOMMITTED_COPY
./scripts/svrun lobsters-popularity lobpop_v1 UNCOMMITTED_COPY
./scripts/svrun lobsters-popularity lobpop_v1 UNCOMMITTED_COPY
```

The UNCOMMITTED_COPY argument tells the Microwizard service that it should take the current state of your repository (instead of deploying from the official system of record, the committed state within git), copy it to a new directory on the Docker host, and then mount the code as a Docker volume. Effectively this means you are running your current changes when the service starts.

4. Once the containers are deployed, go back to http://127.0.0.1:3000/popular and you should see some data on the page including statistical information like the query speed and which service handled the request.

5. Let's make a bad modification to our service and then deploy it to one new microservice instance without modifying the three existing instances. Open up the popularity.py file at `src/lobsters-popularity/popularity.py` and find the following two lines:

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

7. Once it is up and running, refresh the http://127.0.0.1:3000/popular page repeatedly. You should notice that occasionally the page takes a long time to load. This is because Baker Street is routing to the service with the inefficient code. Note that even though the service is operating slowly it is not causing the rest of the application to grind to a halt! You can demonstrate this by clicking on other links within the Lobsters application and noticing that they all load quickly even when the microservice page is slow.

8. To remove the bad service run the following command:

```./scripts/svkill lobpop_v2```

9. Refresh the http://127.0.0.1:3000/popular page repeatedly and notice that all of the page loads are fast. The slow loads are gone because we removed the instance running the bad code.

# Microwizard Architecture #

How does this all work?

The demonstration is composed of the following pieces which all run inside Docker containers:

1. Lobsters Ruby on Rails application
2. MariaDB (open source MySQL fork)
3. Popularity microservice written in Python Flask.
4. [Baker Street](http://www.bakerstreet.io)

The popularity microservice is written so that during initialization of each instance's container the instance is registered as alive by its local Watson component which sends the information to the Datawire Directory. The Sherlock instance we added to the Lobsters monolith subscribes to popularity service availability information and receives push notices from the Datawire Directory indicating new instances are available as each instance is brought up. Calls to the popularity microservice instances at each page reload is distributed among all of the available instances as noted in the local Sherlock.

The popularity microservice has a directory called microwizard/ in its root project directory. This directory contains three important files that configure everything and make it all work:

1. datawire.conf - configures Datawire settings 
2. microwizard.yml - describes the deployment to Microwizard
3. mw.sh - the service initialization and startup routines.

# How it works #

1. Microservice code is committed into a Git repository.
2. When a new service is launched the Microwizard performs a checkout against the specified Git commit. 
3. The checked out code is moved into a directory specifically for that commit. 
4. Microwizard then launches a container and mounts the source code as a volume on the container.
5. The container starts and runs the init() function in your services mw.sh
6. The container starts and runs the run() function in your services mw.sh
7. Sherlock and Watson are automatically installed on the container so when the service starts it automatically registers with the Datawire directory.

# Implementing Custom Microservices #

Implementing a custom microservice in this environment is really simple, but remember that it is not designed for production and does not have many of the features required for a production environment. The provisioning system baked with MicroWizard means you only need to concentrate on application/service code and can forget about deployment and wiring.

1. Copy the template microservice
2. Modify the template microwizard.yml file with your service name, exposed port and necessary links. You should be modifying the service_name, service_url, and health_check_url fields.
3. Modify the mw.sh script and update the run and init functions as necessary.

Make sure that the service_name field in microwizard.yml matches the service_name field in datawire.conf and that the service_port in microwizard.yml is the same value that's in the service_url field of datawire.conf.

You should be able to substitute the base URL for your new service for the URL for the popularity service. If you need additional help, see the [Baker Street documentation](http://bakerstreet.io/docs/quickstart.html).

# FAQ

**Q**: Where can I report problems or suggest improvements to the micro wizard?

**A**: Please use the [Issues list](https://github.com/datawire/microwizard/issues) of the Microwizard GitHub repository to report a problem or suggest an improvement.

**Q**: Are there any known issues not covered in this README?

**A**: Yes, known issues are tracked in the [Issues list](https://github.com/datawire/microwizard/issues) of the Microwizard GitHub repository.