#!/bin/bash

if [[ $# > 3 ]]; then

    interactive=$1
    if [[ "$interactive" == "--interactive" ]]; then
        image_name=$2
        container_name=$3
        host_name=$4
        www_path=$6
        mysql_path=$7
        payload_path=$5
    else
        interactive=''
        image_name=$1
        container_name=$2
        host_name=$3
        www_path=$5
        mysql_path=$6
        payload_path=$4
    fi

    run="docker run --hostname $host_name --net host --add-host $host_name:127.0.0.1 --name $container_name"
    run+=$([ ${interactive} ] && echo " -it" ||  echo " -d" )
    run+=" --rm -p 80 -p 443 -p 22"
    run+=" -v $payload_path:/root/dev-env"
    run+=$([ ${www_path} ] && echo " -v $www_path:/var/www")
    run+=$([ ${mysql_path} ] && echo " -v $mysql_path:/var/lib/mysql")
    run+=" $image_name"

#    echo "$run"

    $run
else
    echo
    echo "format command:"
    echo
    echo "      bash run.sh [--interactive] <image_name> <container_name> <host_name> <payload_path> [<www_path>] [<mysql_path>]"
fi
