#!/bin/bash

# This script is used to build and run a the lightweight desktop on developer's machine

docker build -t lxde-vnc .                                                                                                                                                                                       ─╯
docker run -d --rm -p 6080:6080 -p 5900:5900 --name mylxde lxde-vnc
