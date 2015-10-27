# Datawire Microservices Playground #

The Datawire Microservices Playground is designed to be a combination of hacking sandbox for developers interested in
microservice architectures as well as a very simple reference architecture that can be used as a launch point for teams
that want to get started quickly.

The Playground uses an existing example 2-tier application named [Lobsters](https://github.com/jcs/lobsters) as the core
 application to demonstrate enhancement around using Microservices.
 
# Getting Started #

To get started your system will the following pre-requisite software:

1. Docker
2. Docker Registry 

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

Let's build a new containerized Microservice

