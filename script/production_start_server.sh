#!/bin/bash

set -x

thin -p 3240 -e production --servers 3 stop
thin -d -p 3240 -e production --tag "Robodou Production" --servers 3 start
