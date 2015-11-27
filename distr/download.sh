#!/bin/bash
dir=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
cd $dir

#downloading and unpacking apache 
#https://httpd.apache.org/download.cgi#apache24
function download_apache() {
	apache=httpd-2.4.17
	apache_tar_gz=$apache.tar.gz
	wget http://mirror.switch.ch/mirror/apache/dist//httpd/$apache_tar_gz
	tar xvf $apache_tar_gz
	rm $apache_tar_gz
}

#extra modules are needed for apache (apr and apr-util)
#https://httpd.apache.org/docs/2.4/install.html
function download_apache_extras() {
	#downloading, unpacking and placing inside apache's srclib directory apr and apr-utils
	#https://apr.apache.org/download.cgi
	apr=apr-1.5.2
	apr_tar_gz=$apr.tar.gz
	wget http://www.pirbot.com/mirrors/apache//apr/$apr_tar_gz
	tar xvf $apr_tar_gz
	rm $apr_tar_gz
	mv $apr $apache/srclib/apr

	apr_util=apr-util-1.5.4
	apr_util_tar_gz=$apr_util.tar.gz
	wget http://www.pirbot.com/mirrors/apache//apr/$apr_util_tar_gz
	tar xvf $apr_util_tar_gz
	rm $apr_util_tar_gz
	mv $apr_util $apache/srclib/apr-util
}

#downloading carbon
#https://pypi.python.org/pypi/carbon/0.9.14
function download_carbon() {
	carbon=carbon-0.9.14
	carbon_tar_gz=$carbon.tar.gz
	wget https://pypi.python.org/packages/source/c/carbon/$carbon_tar_gz
	tar xvf $carbon_tar_gz
	rm $carbon_tar_gz	
}

#downloading mod_wsgi
#https://github.com/GrahamDumpleton/mod_wsgi/releases
function download_mod_wsgi() {
	mod_wsgi=mod_wsgi-4.4.21
	mod_wsgi_tar_gz=4.4.21.tar.gz	
	#yes, that's how the link look like, but 
	#at the end a proper tar.gz is downloaded
	wget https://github.com/GrahamDumpleton/mod_wsgi/archive/$mod_wsgi_tar_gz
	tar xvf $mod_wsgi_tar_gz
	rm $mod_wsgi_tar_gz
}

#downloading libffi
function download_libffi() {
	libffi=libffi-3.2
	libffi_tar_gz=$libffi.tar.gz	
	wget ftp://sourceware.org/pub/libffi/$libffi_tar_gz
	tar xvf $libffi_tar_gz
	rm $libffi_tar_gz		
}

#downloading collectd
#https://collectd.org/download.shtml
function download_collectd() {
	collectd=collectd-5.3.0
	collectd_tar_gz=$collectd.tar.gz	
	wget https://collectd.org/files/$collectd_tar_gz
	tar xvf $collectd_tar_gz
	rm $collectd_tar_gz
}


download_apache
download_apache_extras
download_carbon
download_mod_wsgi
download_libffi

download_collectd
