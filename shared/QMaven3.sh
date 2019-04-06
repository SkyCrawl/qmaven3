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
			# https://stackoverflow.com/a/52012684
			return 1 2>/dev/null
			exit 1
		fi
		
		# 
		# Comment-out JRE's additions to /etc/profile (if not commented-out already). For various reasons,
		# it MUST be done here, not in the installation script!
		# 
		
		# JAVA_HOME, single or double quotes
		/bin/sed -i "s+^export JAVA_HOME=/usr/local/jre+# export JAVA_HOME=/usr/local/jre # obsoleted by QMaven+" /etc/profile
		
		# PATH, single quotes only!
		/bin/sed -i 's+^export PATH=$PATH:$JAVA_HOME/bin+# export PATH=$PATH:$JAVA_HOME/bin # obsoleted by QMaven+' /etc/profile

		# 
		# Now reference our own source scripts from /etc/profile (if not already referenced). For various
		# reasons, it MUST be done here, not in the installation script!
		# 

		# Java environment, double quotes only!
		/bin/cat /etc/profile | /bin/grep "source $QPKG_INSTALL_PATH/set_env_java" 1>>/dev/null 2>>/dev/null
		[ $? -ne 0 ] && /bin/echo "source $QPKG_INSTALL_PATH/set_env_java # added by QMaven" >> /etc/profile
		
		# Maven environment, double quotes only!
		/bin/cat /etc/profile | /bin/grep "source $QPKG_INSTALL_PATH/set_env_mvn" 1>>/dev/null 2>>/dev/null
		[ $? -ne 0 ] && /bin/echo "source $QPKG_INSTALL_PATH/set_env_mvn # added by QMaven" >> /etc/profile
		
		# PATH, single quotes only!
		# /bin/cat /etc/profile | /bin/grep -E '^export PATH=\$PATH:\$JAVA_HOME/bin' 1>>/dev/null 2>>/dev/null
		# [ $? -ne 0 ] && /bin/echo 'export PATH=$PATH:$JAVA_HOME/bin # added by QMaven' >> /etc/profile
		
		# 
		# Finally, make our environment scripts available to the user.
		# 
		
		/bin/ln -sf "$QPKG_INSTALL_PATH/set_env_java" "/usr/local/bin/set_env_java"
		/bin/ln -sf "$QPKG_INSTALL_PATH/set_env_mvn" "/usr/local/bin/set_env_mvn"
		;;

	stop)
		# 		
		# Remove our own references from /etc/profile (if not already referenced). For various reasons,
		# it MUST be done here, not in the installation script!
		# 
	
		# Java and Maven environments, double quotes only!
		# Note: both lines are deleted entirely, solution taken from: https://stackoverflow.com/a/5410784
		/bin/sed -i "/$QPKG_NAME/d" /etc/profile
		
		# PATH, single quotes only!
		# Note: the whole line is replaced, solution taken from: https://stackoverflow.com/a/11245501
		# /bin/sed -i '/^export PATH=$PATH:$JAVA_HOME\/bin/c\' /etc/profile
		
		# 
		# Finally, make our environment scripts NOT available to the user.
		# 
		
		/bin/rm "/usr/local/bin/set_env_java"
		/bin/rm "/usr/local/bin/set_env_mvn"
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
		# https://stackoverflow.com/a/52012684
		return 1 2>/dev/null
		exit 1
esac

# if everything goes well...
# https://stackoverflow.com/a/52012684
return 0 2>/dev/null
exit 0
