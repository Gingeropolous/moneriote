#!/bin/bash
#Gingeropolous Open node checker


DIR=~/files_moneriote
dig node.moneroworld.com > $DIR/node_list.txt
DOMAIN=node.moneroworld.com
IPs=`dig $DOMAIN | grep $DOMAIN | grep -v ';' | awk '{ print $5 }'`;
arr=($IPs)

for i in "${arr[@]}"
do
   : 
	if nc -z $i 18081 ; then echo "$i is up" ; fi


done
