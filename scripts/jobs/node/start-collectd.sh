#!/bin/bash
PROJECT_HOME=$1
SCRIPTS_DIR=$PROJECT_HOME/scripts/jobs/node
. $SCRIPTS_DIR/variables.sh
. $SCRIPTS_DIR/functions.sh

log "starting collectd"

. $SCRIPTS_DIR/collectd-start-stop.sh start $COLLECTD_DIR $NODE_COLLECTD_DIR
