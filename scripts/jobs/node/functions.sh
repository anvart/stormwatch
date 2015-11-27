#!/bin/bash

function log {
	echo $'\n'###$THIS_HOST: $1###$'\n'
}

# This function applies the given variables on the given files.
# Usage: "list of variables to apply" "source file" ["destination file"]
function apply_variables_on_file() {
	variables="$1"
	sourceFilePath="$2"

	if [ ! $3 == "" ]; then
		destinationFilePath="$3"
		cp $sourceFilePath $destinationFilePath
	else
		destinationFilePath="$sourceFilePath"
	fi

	for variable in $variables; do
		variableName="value=\$$variable"
		eval $variableName
		#echo "$variableName"
		sed -i "s/\$$variable/$(echo $value | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')/g" "$destinationFilePath"
	done
}

function create_dir() {
  if [ ! -d "$1" ]; then
    mkdir -p $1
  fi
}

function activate_virtualenv {
	log "activating virtualenv"
	source $VIRTUALENV_DIR/bin/activate
}

function deactivate_virtualenv {
	log "deactivating virtualenv"
	deactivate
}
