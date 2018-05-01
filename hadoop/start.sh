#!/usr/bin/env bash

docker build -t iolteanu/haclup .

docker run -p 44:22 -p 8088:8088 -p 9870:9870 iolteanu/haclup