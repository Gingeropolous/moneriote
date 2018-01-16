#!/bin/bash
#Gingeropolous Open node checker


DIR=/home/main12/files_moneriote


monerod=monerod
daemon=192.168.1.2

DOMAIN=node.moneroworld.com
html_dir=/var/www/mine.moneroworld.com/public_html/pages/

echo $monerod
echo $daemon

###
cd /home/main12/moneriote
mkdir $DIR
cd $DIR

echo `date` "The domain script started" >> dom_nodes.txt
echo `date` "Good nodes" >> good_dom_nodes.txt
echo `date` "Bad nodes" >> bad_dom_nodes.txt

### Begin header of random thinger

### Check Existing DNS entries for any to remove
### Kind of stupid right now because I can't update a DNS entry

export IPs=`dig $DOMAIN | grep $DOMAIN | grep -v ';' | awk '{ print $5 }'`;
export arr=($IPs)

for i in "${arr[@]}"
do
   : 
	if nc -z -w 4 $i 18089  
	then 
	echo "$i is up" 
	opennodes+=($i)
	else
	echo "$i is down"
	closednodes+=($i)
	fi
done

echo "open Nodes"
echo ${opennodes[@]} #>> dom_nodes.txt
echo "closed nodes"
echo ${closednodes[@]} #>> dom_nodes.txt
echo "##############"
echo "Check network white nodes for domains to add"

white_a=($opennodes)



#white_a=(${white_a// / })

#white_a=' ' read -r -a array <<< "$opennodes"

echo ${white_a[@]}
echo "################"
echo "Number of domain nodes: "${#white_a[@]} #>> dom_nodes.txt


echo "#############"
echo "Starting loop"

ctr=1

for i in "${opennodes[@]}"
do
   : 
	echo "Checking ip: "$i
	l_hit="$(curl -X POST http://$daemon:18089/getheight -H 'Content-Type: application/json' | grep height | cut -f 2 -d : | cut -f 1 -d ,)"
	r_hit="$(curl -m 20 -X POST http://$i:18089/getheight -H 'Content-Type: application/json' | grep height | cut -f 2 -d : | cut -f 1 -d ,)"
	echo "Local Height: "$l_hit
	echo "Remote Height: "$r_hit
        mini=$(( $l_hit-10 ))
        echo "minimum is " $mini
        maxi=$(( $l_hit+10 ))
        echo "max is " $maxi
        if [[ "$r_hit" ==  "$l_hit"  ]] || [[ "$r_hit" > "$mini" && "$r_hit" < "$maxi" ]]
        then
        echo "################################# Daemon $i is good" #>> dom_nodes.txt 
        ### Time to write these good ips to a file of some sort!
        ### Apparently javascript needs some weird format in order to randomize, so I'll make two outputs
	echo $i >> good_dom_nodes.txt
	echo "myarray[$ctr]= \"$i\";" >> node_script.html
	let ctr=ctr+1
	else
	echo " !!!!!!!!!!!!!!!!!! Daemon $i is closed" # >> dom_nodes.txt
	echo $i >> bad_dom_nodes.txt
	fi
done

echo "Number of domain nodes: $ctr" # >> dom_nodes.txt

echo `date` "The Domain script finished" # >> dom_nodes.txt

# http://stackoverflow.com/questions/16753876/javascript-button-to-pick-random-item-from-array
# http://www.javascriptkit.com/javatutors/randomorder.shtml



