#!/bin/bash
PROJECT_HOME=$1
SCRIPTS_DIR=$PROJECT_HOME/scripts/jobs/node
. $SCRIPTS_DIR/variables.sh
. $SCRIPTS_DIR/functions.sh

log "stopping collectd"

NODE_COLLECTD_DIR=$2

. $SCRIPTS_DIR/collectd-start-stop.sh stop $COLLECTD_DIR $NODE_COLLECTD_DIR
