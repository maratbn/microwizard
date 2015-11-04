#!/bin/bash -eux

# removes all images on the MicroWizard host.

vagrant ssh --command 'docker rmi $(docker images -q)'