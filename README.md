# Datawire Microservices Playground #

Alt name ideas:
* Microservices Hero (like the Jukebox Hero?)
* MicroWizard (Play on the DropWizard framework which popularized simple REST services in Java via glueing best of class components together)

The Datawire Microservices Playground is designed to be a combination of hacking sandbox for developers interested in
microservice architectures as well as a very simple reference architecture that can be used as a launch point for teams
that want to get started quickly.

The Playground uses an existing example 2-tier application named [Lobsters](https://github.com/jcs/lobsters) as the core
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

 # Installation #

1. Clone the Playground project on GitHub
2. Run the installation tool
3. Start Hacking!

# What the Playground Provides #

1. A running instance of Lobsters inside a Docker container
2. A running instance of MariaDB inside another Docker container.
3. A running instance of the Datawire directory inside a Docker container.

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

