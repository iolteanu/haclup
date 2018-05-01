#!/usr/bin/env bash

docker build -t iolteanu/spaclup .

docker run -p 44:22 -p 8088:8088 -p 9870:9870 -p 7077:7077 -p 53411:53411 -p 4040:4040 iolteanu/spaclup