# Datawire MicroWizard #

The Datawire MicroWizard is a sandbox tool for playing with microservices. It is a very basic reference architecture for building, deploying and fiddling about with microservices.

At the moment we envision MicroWizard as a Getting Started tool for developers that zero experience with microservice architectures. In it's current state it's a great tool for getting your feet wet and seeing what the benefits of microservices. A common challenge that developers face in developing microservices is how to migrate from a monolith to a microservices architecture. The Playground is intended to serve as an example on how to add a single microservice to an existing monolith, enabling more rapid feature development. The Playground uses an existing Ruby on Rails application named [Lobsters](https://github.com/jcs/lobsters) as the core application to demonstrate enhancement around using Microservices.

# Requirements #

The MicroWizard base system runs inside of a VirtualBox VM. We provision the VM using Vagrant and then use a combination of shell scripts, Ansible playbooks and custom code to smooth over the experience. Developers at a minimum should have the following software installed:

| Software | Version | Instructions |
| -------- | ------- | ------------------------- |
| Ansible  | >=1.9.4 | [Install](http://docs.ansible.com/ansible/intro_installation.html) |
| Vagrant  | >=1.7.4 | [Install](https://docs.vagrantup.com/v2/installation/index.html) |
| VirtualBox | >= 5.0 | [Install](https://www.virtualbox.org/wiki/Downloads) |

# Getting Started (VM) #

MicroWizard bootstraps inside of a VM. To 

If you're comfortable working inside a VM we also provide a Vagrant template that can setup a working environment.

# Quick Start #

1. Clone the Playground project on GitHub
2. Run `vagrant up`

2. Run install.sh
   - This will prepopulate the system with some test data
3. Go to http://localhost:3000/ to see the Lobster webapp running.

Now the fun part:

4. We introduce a bug in the popularity component, e.g., the
popularity algorithm takes 1000 longer to compute. We make the change
live.
  - Notice how the website still works even though the popularity calc doesn't appear for awhile
  - If this were in the monolith the monolith would grind to a halt

5. Fix the code, and do an incremental rollout of the code.
   - Make sure no regressions, you can see for 50% of the loads it's pretty fast and for the other 50% it's not


This is what's great about microservices:

 - independently deployable code
 - resilience to software bugs


# MicroWizard Architecture #

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

How what the developer just did works.

* Baker Street!
* Btw did we mention that ChaosMonkey (or equivalent) was running in the background and killing the Popularity Service
and stuff just continued to work?

# FAQ #

