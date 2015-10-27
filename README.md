# Datawire Microservices Playground #

Alt name ideas:
* Microservices Hero (like the Jukebox Hero?)
* MicroWizard (Play on the DropWizard framework which popularized simple REST services in Java via glueing best of class components together)

The Microservices Playground is a hacking sandbox for developers interested in microservice architectures.

A common challenge that developers face in developing microservices is how to migrate from a monolith to a microservies architecture. The Playground is intended to serve as an example on how to add a single microservice to an existing monolith, enabling more rapid feature development. The Playground uses an existing Ruby on Rails application named [Lobsters](https://github.com/jcs/lobsters) as the core
 application to demonstrate enhancement around using Microservices.
 
# Getting Started #

To get started your system will the following pre-requisite software:

| Software | Installation Instructions |
| -------- | -----|
| Docker | <ul><li>[Mac OS X](https://docs.docker.com/installation/mac/)</li><li>[Debian](https://docs.docker.com/installation/debian/)</li><li>[Fedora](https://docs.docker.com/installation/fedora/)</li><li>[Ubuntu](https://docs.docker.com/installation/ubuntulinux/)<li>[Windows](https://docs.docker.com/installation/windows/)</li><li>[Other](https://docs.docker.com/installation/)</li>
| Docker Registry | [All Platforms](https://docs.docker.com/registry/)

Installing those two components is above and beyond the scope of this document because they require approving several
OS level changes, however, documentation for installation and setup can be found at the following URLs: 

### Alternative Getting Started (VM) ###

If you're comfortable working inside a VM we also provide a Vagrant template that can setup a working environment.

# Quick Start #

1. Clone the Playground project on GitHub
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

