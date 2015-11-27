#!/bin/bash
PROJECT_HOME=$1
SCRIPTS_DIR=$PROJECT_HOME/scripts/jobs/node
. $SCRIPTS_DIR/variables.sh
. $SCRIPTS_DIR/functions.sh

log "starting aggregator machine"

function export_vars {
  export LD_LIBRARY_PATH=$VIRTUALENV_DIR/additional/lib
	export PKG_CONFIG_PATH=$VIRTUALENV_DIR/additional/lib/pkgconfig
  export GRAPHITE_API_CONFIG=$VIRTUALENV_DIR/conf/graphite-api.yaml
}

function start_carbon {
  log "starting carbon-cache"
  cd $VIRTUALENV_DIR/bin
  python carbon-cache.py start
}

function start_apache {
  log "starting apache"
	$APACHE_DIR/bin/apachectl start
}

activate_virtualenv

export_vars
start_carbon
start_apache

deactivate_virtualenv
