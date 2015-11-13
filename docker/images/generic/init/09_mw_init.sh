#!/bin/bash -e

# ------------------------------------------------------------------------------
# file: 09_mw_init.sh

MICROWIZARD_INIT_ROOT=/usr/src/service/microwizard

cp ${MICROWIZARD_INIT_ROOT}/datawire.conf /etc/datawire/datawire.conf
bash ${MICROWIZARD_INIT_ROOT}/mw.sh init