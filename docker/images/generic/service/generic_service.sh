#!/bin/bash -e

# ===========================
# README / USAGE INSTRUCTIONS
# ===========================
#
# Modify the exec command below to start your service. The command you issue MUST NOT daemonize the program. The Runit
# system will daemonize the process for you.
#
# While not required, it is recommended that the name of this file be renamed to something consistent with your actual
# service. If you rename this file then DO NOT forget to update the Dockerfile appropriately as failure to do so will
# cause builds to fail when the target file is not found.
#
# Runit documentation can be found here: http://smarden.org/runit/

MICROWIZARD_INIT_ROOT=/usr/src/service/microwizard
bash ${MICROWIZARD_INIT_ROOT}/mw.sh run