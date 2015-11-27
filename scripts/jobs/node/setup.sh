#!/bin/bash
PROJECT_HOME=$1
SCRIPTS_DIR=$PROJECT_HOME/scripts/jobs/node
. $SCRIPTS_DIR/variables.sh
. $SCRIPTS_DIR/functions.sh

log "pre-setup script"

function setup_virtualenv {
  log "setting up python virtual environment"
  virtualenv $VIRTUALENV_DIR
}

function install_pip_packages {
	log "installing twisted, whisper, django and django-bootstrap via pip"
	pip install twisted
	pip install whisper
	pip install django
	pip install django-bootstrap3
	log "installation finished"
}

function install_graphite_api {
	#installing PyYaml
	pip install pyyaml
	#an additional requirement for graphite-api
	log "installing libffi"
	cd $DISTR_DIR/libffi-3.2
	./configure --prefix="$VIRTUALENV_DIR/additional"
	make && make install

	#and now make this lib visible to python
	export LD_LIBRARY_PATH=$VIRTUALENV_DIR/additional/lib
	export PKG_CONFIG_PATH=$VIRTUALENV_DIR/additional/lib/pkgconfig

	log "installing graphite-api"
	CFLAGS="-I$VIRTUALENV_DIR/additional/lib/libffi-3.2/include -L$VIRTUALENV_DIR/additional/lib" pip install graphite-api

	log "installation finished"
}

#all this extra effort is needed because of hardcoded paths that carbon uses
function install_carbon {
	log "installing carbon"

	PREFIX=$VIRTUALENV_DIR
  	apply_variables_on_file "PREFIX" $CONF_DIR/carbon.setup.cfg $DISTR_DIR/carbon-0.9.14/setup.cfg
	export PYTHONPATH=$VIRTUALENV_DIR:$PYTHONPATH

  cd $DISTR_DIR/carbon-0.9.14
	python setup.py install
	log "carbon installation finished"
}

function install_apache {
  log "installing apache"
  cd $DISTR_DIR/httpd-2.4.17
  ./configure --with-included-apr --prefix=$APACHE_DIR
  make && make install
  cp $APACHE_DIR/conf/httpd.conf $APACHE_DIR/conf/httpd.conf.backup
}

function install_mod_wsgi() {
	log "installing mod_wsgi"

	cd $DISTR_DIR/mod_wsgi-4.4.21
	./configure  --with-apxs=$APACHE_DIR/bin/apxs --with-python=$VIRTUALENV_DIR/bin/python
	make && make install
}

function install_collectd() {
	log "installing collectd"

	cd $DISTR_DIR/collectd-5.3.0
	./configure --prefix=$COLLECTD_DIR
	make && make install
}

function leave_trace {
  touch $DEPENDENCIES_DIR/pre-setup-was-here
}

if [ -f $DEPENDENCIES_DIR/pre-setup-was-here ]; then
    log "this script has already been run. remove contents of $DEPENDENCIES_DIR and start it again"
    exit 0
fi

setup_virtualenv
activate_virtualenv

install_pip_packages
install_graphite_api
install_carbon
install_apache
install_mod_wsgi

install_collectd

leave_trace

deactivate_virtualenv

exit 0
