#!/bin/bash

. $(find ~/ -maxdepth 1 -type f -name '.bash_profile')
if ((${#appPath} <= 1))
then
        appPath=$(pwd)
fi

userInfo=$(/usr/bin/whoami)

if [[ ${userInfo} = "root" ]]
then 
        echo "******************************HELLO!!! PLEASE RUN ME FROM NON ROOT USER******************************"
        exit 0
fi
dirName=$(echo ${appPath}  | awk -F"/" '{print $NF}')
length=$(expr ${#appPath} - ${#dirName})
appHome=${appPath:0:$length}
delimitCnt=$(echo $appHome  | awk -F"/" '{print NF-1}')
appName=$(echo $appHome  | cut -d"/" -f$delimitCnt)
appCnt=$(ps -Aef | grep java | grep $appHome | grep -v grep | wc -l)
if (( $appCnt == 0 ))
then
	echo Starting Application $appName...
	echo 'Source Path      : ' $appPath
	echo 'Application Path : ' $appHome
	cd $appPath
	rm -f nohup.out
	if  [ -f wildfly.sh ] && [ -s wildfly.sh ]
	then
		./wildfly.sh
	else
		echo "ERROR: Satrt Script 'myrun.sh' not found..."
	fi
	ps -Aef | grep java | grep ${appHome} | grep -v grep
else
	appPid=$(ps -Aef | grep java | grep $appHome | grep -v grep | awk '{print $2}')
	echo ERROR: $appName Application Already Running With Process ID $appPid...
fi
