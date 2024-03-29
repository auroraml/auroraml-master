#!/bin/bash

####     Install Prerequisites     ####
apt update

apt --reinstall install -y curl

####     Functions    ####
. ./func.sh

####     Packages    ####
. ./syslog.sh

. ./apache.sh

. ./php.sh

. ./auroraml.sh

. ./postfix.sh

. ./haproxy.sh


echo "Done !"
