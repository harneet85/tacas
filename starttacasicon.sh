#!/bin/bash

DISPLAY=:0.0 
a=`ps -ef| grep -i sysicon.py| grep -v grep |wc -l`
if [[ $a > 0 ]]
then
	echo VPN Process up
else
	nohup python /home/harneet/scripts/tacas/sysicon.py &
fi
