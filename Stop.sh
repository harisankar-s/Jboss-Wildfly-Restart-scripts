#!/bin/bash

. $(find ~/ -maxdepth 1 -type f -name '.bash_profile')
isDumps=0
if (($# == 1))
then
	isDumps=1
fi

path=$0
thisFileName=$(basename ${path})
length=$(expr ${#path} - ${#thisFileName} - 1)
appPath=${path:0:$length}
if ((${#appPath} <= 1))
then
        appPath=$(pwd)
fi
dirName=$(echo ${appPath}  | awk -F"/" '{print $NF}')
length=$(expr ${#appPath} - ${#dirName})
appHome=${appPath:0:$length}
delimitCnt=$(echo ${appHome}  | awk -F"/" '{print NF-1}')
appName=$(echo ${appHome}  | cut -d"/" -f${delimitCnt})
appCnt=$(ps -Aef | grep java | grep $appHome | grep -v grep | wc -l)
deployedWarFile=$(find ${appHome}/standalone/deployments -maxdepth 1 -type d -name '*.war' | awk -F'/' '{print $NF}')
if (( $appCnt > 0 ))
then
	appPid=$(ps -Aef | grep java | grep ${appHome} | grep -v grep | awk '{print $2}')
	echo Stopping Application $appName with Process Id $appPid...
	echo 'Source Path      : ' $appPath
	echo 'Application Path : ' $appHome
	
	cd ${appPath}
	if ((${isDumps} == 1))
	then
		echo "Please Wait a While... Collecting Thread Dump for ${appName} on Process Id ${appPid}"
		#${JAVA_HOME}/bin/jmap -J-d64 -dump:live,format=b,file=${appHome}/standalone/log/Heap_${appName}_${appPid}_${timeNow}.dump ${appPid}
	        for ((i=0; i<6; i++))
        	 do
		#	/usr/bin/kill -3 ${appPid} >> ${appHome}/standalone/log/Thread_${appName}_${appPid}_${timeNow}.dump
		#       	${JAVA_HOME}/bin/jstack ${appPid} >> ${appHome}/standalone/log/Thread_JStack_${appName}_${appPid}_${timeNow}.dump
		 #      	sleep 10
			echo
	         done
	fi
	kill -9 $appPid
        echo -n "${appName} Stopping"
        for ((cnt=0; cnt<10; cnt++))
        do
                echo -n .
                sleep 1
        done
        echo " [ STOPPED ]"
	if ((${#deployedWarFile} > 0))
	then
		if [ -f ${appHome}/standalone/deployments/${deployedWarFile}.undeployed ]
		then
			rm -f ${appHome}/standalone/deployments/${deployedWarFile}.undeployed
		fi
		touch ${appHome}/standalone/deployments/${deployedWarFile}.dodeploy
	fi
	echo "Stopped Application ${appHome} having the PID $appPid."
fi

if [ -d  ${appHome}/standalone/tmp/ ]
then
	rm -rf ${appHome}/standalone/tmp/*
fi

serverLogFile=$(grep "file path=" ${appHome}/standalone/configuration/standalone.xml | awk -F'"' '{print $2}')
if ((${#serverLogFile} > 0))
then
	if [ -f ${serverLogFile} ]
	then
		mv ${serverLogFile} ${serverLogFile}_$(date '+%d%m%Y_%H%M%S_%N')
	fi
fi

appLogFile=$(grep fileName  ${appHome}/standalone/deployments/${deployedWarFile}/WEB-INF/classes/log4j2.xml | grep ".log" | grep -v grep | awk -F'fileName' '{print $2}' | awk '{print $1}' | awk -F'"' '{print $(NF-1)}')
if ((${#appLogFile} > 0))
then
	if [ -f ${appLogFile} ]
	then
        	mv ${appLogFile} ${appLogFile}_$(date '+%d%m%Y_%H%M%S_%N')
	fi
fi
