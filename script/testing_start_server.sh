#!/bin/bash

set -x

sidekiqctl stop tmp/pids/sidekiq.pid 60
thin stop
thin -d -p 3140 --tag "Robodou Testing" start
sidekiq -C config/sidekiq.yml -d --tag "Robodou Testing"
