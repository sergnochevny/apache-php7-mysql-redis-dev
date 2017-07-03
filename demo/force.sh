
#!/bin/bash

if [[ $# > 0 ]]; then
    docker build --no-cache=true -t $1 .
else
    echo
    echo "format command:"
    echo
    echo "  bash force.sh <project_name>"
fi
