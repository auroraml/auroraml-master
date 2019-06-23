#!/bin/bash

####     Functions    ####
read_def (){
    # Use: read_def <prompt> <default>
    prompt="$1"
    default="$2"

    read -p "$prompt [$default]: " var
    test -z $var && var=$default

    echo "$var"
}


####     Install Prerequisites     ####
apt install -y postfix 
apt install -y curl
apt install -y rsyslog
apt install -y apache2 
apt install -y php7.2 libapache2-mod-php php-mysql php-mbstring

a2enmod php7.2

####          Syslog               ####
syslog_conf='/etc/rsyslog.conf'
cp "${syslog_conf}" "${syslog_conf}.bk"
echo '#  /etc/rsyslog.conf	Configuration file for rsyslog.
#
#			For more information see
#			/usr/share/doc/rsyslog-doc/html/rsyslog_conf.html


#################
#### MODULES ####
#################

module(load="imuxsock") # provides support for local system logging
module(load="imklog")   # provides kernel logging support
#module(load="immark")  # provides --MARK-- message capability

# provides UDP syslog reception
#module(load="imudp")
#input(type="imudp" port="514")

# provides TCP syslog reception
module(load="imtcp")
input(type="imtcp" port="514")


###########################
#### GLOBAL DIRECTIVES ####
###########################

#
# Use traditional timestamp format.
# To enable high precision timestamps, comment out the following line.
#
$ActionFileDefaultTemplate RSYSLOG_TraditionalFileFormat

#
# Set the default permissions for all log files.
#
$FileOwner root
$FileGroup adm
$FileCreateMode 0640
$DirCreateMode 0755
$Umask 0022

#
# Where to place spool and state files
#
$WorkDirectory /var/spool/rsyslog

#
# Include all config files in /etc/rsyslog.d/
#
$IncludeConfig /etc/rsyslog.d/*.conf


###############
#### RULES ####
###############

#
# First some standard log files.  Log by facility.
#
auth,authpriv.*			/var/log/auth.log
*.*;auth,authpriv.none		-/var/log/syslog
#cron.*				/var/log/cron.log
daemon.*			-/var/log/daemon.log
kern.*				-/var/log/kern.log
lpr.*				-/var/log/lpr.log
mail.*				-/var/log/mail.log
user.*				-/var/log/user.log

#
# Logging for the mail system.  Split it up so that
# it is easy to write scripts to parse these files.
#
mail.info			-/var/log/mail.info
mail.warn			-/var/log/mail.warn
mail.err			/var/log/mail.err

#
# Some "catch-all" log files.
#
*.=debug;\
	auth,authpriv.none;\
	news.none;mail.none	-/var/log/debug
*.=info;*.=notice;*.=warn;\
	auth,authpriv.none;\
	cron,daemon.none;\
	mail,news.none		-/var/log/messages

#
# Emergencies are sent to everybody logged in.
#
*.emerg				:omusrmsg:*
'


echo '# Log error and debug to separate files
# Messages generated by PHP
:msg, contains, "PHP"        /var/log/auroraml-worker.error
& stop


if $syslogtag == "auroraml-worker:" then {
   *.warning    /var/log/auroraml-worker.error
   & stop

   *.info       /var/log/auroraml-worker
   & stop

   *.debug      /var/log/auroraml-worker.debug
   & stop
}
' > '/etc/rsyslog.d/20-auroraml.conf'

####            WWW                ####
cp -r ./www /var/www/html

