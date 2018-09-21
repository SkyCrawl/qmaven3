#!/bin/sh

# declare variables
QPKG_CONF="/etc/config/qpkg.conf"
QPKG_NAME="QMaven3"
QPKG_INSTALL_PATH=$(/sbin/getcfg $QPKG_NAME Install_Path -f $QPKG_CONF)

# perform the given action
case "$1" in
	start)
		# determine and check status
		QPKG_ENABLED=$(/sbin/getcfg $QPKG_NAME Enable -u -d FALSE -f $QPKG_CONF)
		if [ "$QPKG_ENABLED" = "UNKNOWN" ]; then
			# do enable the QPKG
			/sbin/setcfg "$QPKG_NAME" Enable TRUE -f "$QPKG_CONF"
		elif [ "$QPKG_ENABLED" != "TRUE" ]; then
			# disabled QPKG has no right to start...
			echo "$QPKG_NAME is disabled."
			exit 1
		fi
		
		# comment-out JRE's additions to /etc/profile (if not commented-out already)
		# Note: it MUST be done here (not in the installation script) as JRE may have been installed AFTER QMaven3!
		/bin/sed -i "s+^export JAVA_HOME=/usr/local/jre+# export JAVA_HOME=/usr/local/jre # obsoleted by $QPKG_NAME+" /etc/profile
		/bin/sed -i "s+^export PATH=$PATH:$JAVA_HOME/bin+# export PATH=$PATH:$JAVA_HOME/bin # obsoleted by $QPKG_NAME+" /etc/profile
		
		# now reference our own source scripts from /etc/profile (if not already referenced)
		# Note: it MUST be done here (not in the installation script) as system restart rolls back the original /etc/profile!
		/bin/cat /etc/profile | /bin/grep "source $QPKG_INSTALL_PATH/set_env_java" 1>>/dev/null 2>>/dev/null
		[ $? -ne 0 ] && /bin/echo "source $QPKG_INSTALL_PATH/set_env_java" >> /etc/profile
		/bin/cat /etc/profile | /bin/grep "source $QPKG_INSTALL_PATH/set_env_mvn" 1>>/dev/null 2>>/dev/null
		[ $? -ne 0 ] && /bin/echo "source $QPKG_INSTALL_PATH/set_env_mvn" >> /etc/profile
		;;

	stop)
		# remove reference of our own source scripts from /etc/profile
		/bin/sed -i "s:^source $QPKG_INSTALL_PATH/set_env_java::" /etc/profile
		/bin/sed -i "s:^source $QPKG_INSTALL_PATH/set_env_mvn::" /etc/profile
		;;
		
	test)
		;;

	restart)
		./$0 stop
		# Note: doesn't work properly without these additional commands...
		/bin/sleep 5
		/bin/sync
		./$0 start
		;;

	*)
		echo "Usage: $0 {start|stop|restart|test}"
		exit 1
esac

# if everything goes well...
exit 0
