#!/bin/bash -e

cd /usr/src/lobsters
bundle
rake db:schema:load