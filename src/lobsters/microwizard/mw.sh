#!/bin/bash -eu

# file: mw.sh

function init {
  bundle
  rake db:schema:load
  rake db:migrate
  rake fake_data
}

function run {
  sv exit watson # no need for this on here
  exec rails server
}

command=$1

cd /usr/src/service
if [ "$command" = "init" ]; then
  init
elif [ "$command" = "run" ]; then
  run
else
  echo "unknown command (name: $command)"
  exit 1
fi