#!/bin/bash
PROJECT_HOME=$1
SCRIPTS_DIR=$PROJECT_HOME/scripts/jobs/node
. $SCRIPTS_DIR/variables.sh
. $SCRIPTS_DIR/functions.sh

log "setting up collectd"

create_dir $NODE_CONF
create_dir $NODE_LOG_DIR
create_dir $NODE_COLLECTD_DIR

apply_variables_on_file "AGGREGATOR_HOST NODE_COLLECTD_LOG_FILE" $CONF_DIR/collectd.conf $NODE_COLLECTD_DIR/collectd.conf
