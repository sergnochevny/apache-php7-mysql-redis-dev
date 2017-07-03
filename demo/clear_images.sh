#!/bin/sh

docker images -aq | xargs docker rmi -f