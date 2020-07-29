#!/bin/bash

. $(find ~/ -maxdepth 1 -type f -name '.bash_profile')
path=$0
thisFileName=$(basename $path)
length=$(expr ${#path} - ${#thisFileName} - 1)
appPath=${path:0:$length}
if ((${#appPath} <= 1))
then
        appPath=$(pwd)
fi
dirName=$(echo $appPath  | awk -F"/" '{print $NF}')
length=$(expr ${#appPath} - ${#dirName})
appHome=${appPath:0:$length}
delimitCnt=$(echo $appHome  | awk -F"/" '{print NF-1}')
appName=$(echo $appHome  | cut -d"/" -f$delimitCnt)
cd $appPath
find $appPath -maxdepth 1 -mindepth 1 -type f -mmin +10 -name '.Restart.ONPROCESS' -exec rm -f {} \;
if [ -f $appPath/.Restart.ONPROCESS ]
then
	echo "*********RESTART ALREADY ON PROGRESS*********"
	exit 0
fi
echo "RESTARTING Digimate BL_04" > $appPath/.Restart.ONPROCESS
echo PATH :: $(pwd)
./Stop.sh 1
sleep 1
./Start.sh
sleep 1
rm -f $appPath/.Restart.ONPROCESS
