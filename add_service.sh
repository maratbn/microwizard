#!/bin/bash

GIT_COMMIT=$1

ansible-playbook\
 -i .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory\
 --extra-vars "git_commit=${GIT_COMMIT}"\
  ansible/add_service.yml