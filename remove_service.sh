#!/bin/bash -eux

NAME=$1

ansible-playbook\
 -i .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory\
 --extra-vars "tag=${NAME}"\
  ansible/remove_service.yml