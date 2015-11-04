#!/bin/bash -e

cd /usr/src/lobsters
bundle
rake db:schema:load
rake db:migrate
rake fake_data