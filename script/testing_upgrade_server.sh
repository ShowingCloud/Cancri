#!/bin/bash

set -ex

git pull
rake db:migrate
#rake db:data:load_dir dir="datadump"
