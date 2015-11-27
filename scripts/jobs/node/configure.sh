#!/bin/bash
PROJECT_HOME=$1
SCRIPTS_DIR=$PROJECT_HOME/scripts/jobs/node
. $SCRIPTS_DIR/variables.sh
. $SCRIPTS_DIR/functions.sh

log "job-configure.sh"

function configure_carbon {
  log "configuring carbon-cache"
  cp $CONF_DIR/carbon.conf $VIRTUALENV_DIR/conf/carbon.conf
  cp $CONF_DIR/storage-schemas.conf $VIRTUALENV_DIR/conf/storage-schemas.conf
}

function configure_graphite_api {
	log "configuring graphite-api"

	SEARCH_INDEX=$VIRTUALENV_DIR/index
  WHISPER_DIR=$VIRTUALENV_DIR/storage/whisper

	apply_variables_on_file "SEARCH_INDEX WHISPER_DIR" $CONF_DIR/graphite-api.yaml $VIRTUALENV_DIR/conf/graphite-api.yaml
}

function configure_apache {
	log "configuring apache"

  create_dir $PROJECT_HOME/tmp/www/wsgi-scripts
  create_dir $PROJECT_HOME/tmp/run

	#WSGI_DIR=$NODE_HOME/www/wsgi-scripts
  WSGI_DIR=$PROJECT_HOME/tmp/www/wsgi-scripts

	WSGI_SCRIPT=$WSGI_DIR/graphite-api.wsgi
	WSGI_SOCKET_DIR=$PROJECT_HOME/tmp/run
	WSGI_PYTHON_PATH=$VIRTUALENV_DIR/lib/python2.7/site-packages:$WSGI_DIR:$STORMWATCH_DIR
	WSGI_PYTHON_HOME=$VIRTUALENV_DIR

  STORMWATCH_WSGI_SCRIPT=$STORMWATCH_DIR/stormwatch/wsgi.py

	create_dir $WSGI_DIR
	create_dir $PROJECT_HOME/tmp/run

	cp $CONF_DIR/graphite-api.wsgi $WSGI_DIR
  cp $APACHE_DIR/conf/httpd.conf.backup $APACHE_DIR/conf/httpd.conf
  #port 80 is not allowed for use, apache crashes when trying to bind
  sed -i -- 's/Listen 80/#Listen 80/g' $APACHE_DIR/conf/httpd.conf
	cat $CONF_DIR/httpd.conf.append >> $APACHE_DIR/conf/httpd.conf

	apply_variables_on_file "WSGI_SOCKET_DIR WSGI_PYTHON_HOME WSGI_PYTHON_PATH" $CONF_DIR/apache.common.conf $APACHE_DIR/conf/apache.common.conf
  apply_variables_on_file "WSGI_DIR WSGI_SCRIPT" $CONF_DIR/apache.graphite-api.conf $APACHE_DIR/conf/apache.graphite-api.conf
  apply_variables_on_file "STORMWATCH_DIR STORMWATCH_WSGI_SCRIPT" $CONF_DIR/apache.stormwatch.conf $APACHE_DIR/conf/apache.stormwatch.conf
}

function configure_nimbus_mock {
  NIMBUS_MOCK_DIR=$PROJECT_HOME/mock/nimbus
  printf "\nInclude conf/apache.nimbus-mock.conf" >> $APACHE_DIR/conf/httpd.conf
  apply_variables_on_file "NIMBUS_MOCK_DIR NIMBUS_MOCK_PORT" $CONF_DIR/apache.nimbus-mock.conf $APACHE_DIR/conf/apache.nimbus-mock.conf
}

activate_virtualenv

configure_carbon
configure_graphite_api
configure_apache

#a setup for an imitation of storm-ui REST API (https://github.com/knusbaum/incubator-storm/blob/master/STORM-UI-REST-API.md)
configure_nimbus_mock

deactivate_virtualenv
