#!/bin/bash

set -x

thin -p 3240 -e production stop
thin -d -p 3240 -e production --tag "Robodou Production" start
