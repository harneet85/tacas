#! /bin/bash
#########################################
########## Creator Harneet
#########################################

###### Enviornment Variables #############

log=./tac.log
USER1=harneesi
PASS1=Gurnaazkaur1234
USER2=IN0090G5
PASS2=kaurarorataru123
URL1=https://129.39.151.35:950/
URL2=https://9.140.49.20:950/
URL3=https://129.39.136.163:950/
mv $log $log.$(date +%d.%m.%y)

################# Function #######################
function logpurge {

	find ./ -iname "tac.log.*" -mtime +3 -exec rm -rf {} \;
	find ./ -iname "tac.log.*" -mtime +2 -exec gzip {} \;

}

function state {

	d=`cat $log |egrep -i "IST|authorized" | tail -n4| head -n1`
	c=`cat $log |egrep -i "IST|authorized" | tail -n4| grep -i authorized |wc -l`
	cd=`expr $(( $(date +%s)/60 ))`
	if [ ! -z "$d" ]; then
		gd=`expr $(( $(date -d "$d" +%s)/60 ))` 
		echo current date : $cd ,  given date:  $gd
		echo date grepped : $d , count : $c
		diff=`expr $(( $cd - $gd  ))`
		echo Difference : $diff
		if [[ $diff -gt 20 ]] ; then echo connection could be stale
		elif [[ $c -lt 3 ]] ; then echo Connections are NOT ok 
		else echo ALL connection / date OK
		fi
	fi
}

function state2 {

        d=`cat $log |egrep -i "IST|authorized" | tail -n4| head -n1`
        c=`cat $log |egrep -i "IST|authorized" | tail -n4| grep -i authorized |wc -l`
        cd=`expr $(( $(date +%s)/60 ))`
        if [ ! -z "$d" ]; then
                echo current date : $cd 
                echo date grepped : $d , count : $c
                echo Difference : $diff
                if [[ $c -lt 3 ]] ; then echo Connections are NOT ok
                else echo ALL connection / date OK; echo `expr $(( $(date +%s)/60 ))`> ./tac.status
                fi
	fi

}


################ MAIN execution ####################
logpurge
cat /dev/null > $log
while : ; do
	date | tee -a $log
	for i in $URL1 $URL2; do 
		echo "Re-authenticating for UK $i"
   		ID=$(curl -k $i 2>/dev/null | grep ID | sed 's/.*value="//' | sed 's/">.*//')
   		curl -s -d "ID=$ID&STATE=1&DATA=$USER1" -k $i >> $log
   		curl -s -d "ID=$ID&STATE=2&DATA=$PASS1" -k $i >> $log
   		#curl -s -d "ID=$ID&STATE=3&DATA=1&submit=Submit" -k $i | grep -i authenticated| tee -a $log
   		curl -s -d "ID=$ID&STATE=3&DATA=1&submit=Submit" -k $i| grep -i authorized|awk -F">" '{print $3}'|sed 's?<BR??g' | tee -a $log
	done
                echo "Re-authenticating for Spain https://129.39.136.163:950/"
                ID=$(curl -k $URL3 2>/dev/null | grep ID | sed 's/.*value="//' | sed 's/">.*//')
                curl -s -d "ID=$ID&STATE=1&DATA=$USER2" -k $URL3 >> $log
                curl -s -d "ID=$ID&STATE=2&DATA=$PASS2" -k $URL3 >> $log
                curl -s -d "ID=$ID&STATE=3&DATA=1&submit=Submit" -k $URL3 | grep -i authorized|awk -F">" '{print $3}'|sed 's?<BR??g' | tee -a $log
	echo " ">> $log
	state2
	sleep 900
done
