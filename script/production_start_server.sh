#!/bin/bash

set -x

sidekiqctl stop tmp/pids/sidekiq.pid 60
thin -p 3240 -e production stop
thin -d -p 3240 -e production --tag "Robodou Production" start
sidekiq -C config/sidekiq.yml -d -e production --tag "Robodou Production"
