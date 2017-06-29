#!/bin/bash

[ -f /root/dev-env/setup.sh ] && /root/dev-env/setup.sh

/usr/bin/supervisord
