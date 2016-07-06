#!/bin/bash

set -x

thin stop
thin -d -p 3140 --tag "Robodou Testing" start
