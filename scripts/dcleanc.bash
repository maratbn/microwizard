#!/bin/bash -eux

# stops and removes all containers on the MicroWizard host.

vagrant ssh --command 'docker stop $(docker ps -a -q) && docker rm $(docker ps -a -q)'