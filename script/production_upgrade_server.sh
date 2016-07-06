#!/bin/bash

set -ex

RAILS_ENV=production
export RAILS_ENV

git pull
rake db:migrate
#rake db:data:load_dir dir="datadump"
rake assets:clean
rake assets:precompile
#rake deface:precompile
