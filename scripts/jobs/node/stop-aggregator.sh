#!/bin/bash
PROJECT_HOME=$1
SCRIPTS_DIR=$PROJECT_HOME/scripts/jobs/node
. $SCRIPTS_DIR/variables.sh
. $SCRIPTS_DIR/functions.sh

log "stoppping aggregator machine"

function stop_carbon {
  log "stopping carbon-cache"
  cd $VIRTUALENV_DIR/bin
  python carbon-cache.py stop
}

function stop_apache {
  log "stopping apache"
	$APACHE_DIR/bin/apachectl stop
}

activate_virtualenv

stop_carbon
stop_apache

deactivate_virtualenv