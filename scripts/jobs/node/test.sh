#!/bin/bash
PROJECT_HOME=$1
SCRIPTS_DIR=$PROJECT_HOME/scripts
. $SCRIPTS_DIR/variables.sh
. $SCRIPTS_DIR/functions.sh

dpkg -s libpcre
dpkg -s pcre-config