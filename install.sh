#!/bin/bash
#
# stage install/update script

mkdir /usr/lib/stage
mkdir /etc/stage

cp -R functions /usr/lib/stage/

cp -R service_files stages.d /etc/stage/

cp rc.shutdown stage /usr/bin
