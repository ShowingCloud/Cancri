#!/bin/bash

set -x

sidekiqctl stop tmp/pids/sidekiq.pid 60
pumactl restart
sidekiq -C config/sidekiq.yml -d -e production --tag "Robodou Production"
