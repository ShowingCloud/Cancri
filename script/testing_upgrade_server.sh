#!/bin/bash

set -ex

git pull
rake db:schema:load
rake db:data:load_dir dir="datadump"
