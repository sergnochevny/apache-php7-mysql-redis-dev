#!/bin/bash

if [[ $# > 0 ]]; then
    docker build -t $1 .
else
    echo
    echo "format command:"
    echo
    echo "      bash build.sh <project_name>"
fi