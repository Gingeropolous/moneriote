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
	CHECK=$(nc -z -v -w5 $i 18081)
	echo $CHECK
done
