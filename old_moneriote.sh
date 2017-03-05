#!/bin/bash
#Gingeropolous Open node checker


DIR=/home/monero/files_moneriote


monerod=monerod
daemon=107.172.25.35

DOMAIN=node.moneroworld.com
html_dir=/var/www/mine.moneroworld.com/public_html/pages/

echo $monerod
echo $daemon

###
cd /home/monero/moneriote
mkdir $DIR
cp *.html $DIR
cd $DIR
rm open_nodes.txt
rm nodes.html
cp nodes_base.html nodes.html
echo `date` "The script started" >> moneriote.log

### Begin header of random thinger

cp base.html node_script.html

### Check Existing DNS entries for any to remove
### Kind of stupid right now because I can't update a DNS entry

export IPs=`dig $DOMAIN | grep $DOMAIN | grep -v ';' | awk '{ print $5 }'`;
export arr=($IPs)
# declare -a opennodes
# declare -a closednodes

for i in "${arr[@]}"
do
   : 
	if nc -z -w 4 $i 18081  
	then 
	echo "$i is up" 
	opennodes+=($i)
	else
	echo "$i is down"
	closednodes+=($i)
	fi
done

echo ${opennodes[@]}

echo "##############"
echo "Check network white nodes for domains to add"



white=$($monerod --rpc-bind-ip $daemon print_pl | grep white | awk '{print $3}' | cut -f 1 -d ":")
white_a=($white)
white_a+=($opennodes)
echo ${white_a[@]}
echo "################"
echo "Number of nodes: "${#white_a[@]} >> moneriote.log


echo "#############"
echo "Starting loop"

ctr=1

for i in "${white_a[@]}"
do
   : 
	echo "Checking ip: "$i
	l_hit="$(curl -X POST http://$daemon:18081/getheight -H 'Content-Type: application/json' | grep height | cut -f 2 -d : | cut -f 1 -d ,)"
	r_hit="$(curl -m 0.5 -X POST http://$i:18081/getheight -H 'Content-Type: application/json' | grep height | cut -f 2 -d : | cut -f 1 -d ,)"
	echo "Local Height: "$l_hit
	echo "Remote Height: "$r_hit
        mini=$(( $l_hit-10 ))
        echo "minimum is " $mini
        maxi=$(( $l_hit+10 ))
        echo "max is " $maxi
        if [[ "$r_hit" ==  "$l_hit"  ]] || [[ "$r_hit" > "$mini" && "$r_hit" < "$maxi" ]]
        then
        echo "################################# Daemon $i is good" 
        ### Time to write these good ips to a file of some sort!
        ### Apparently javascript needs some weird format in order to randomize, so I'll make two outputs
        echo $i >> open_nodes.txt
	echo "myarray[$ctr]= \"$i\";" >> node_script.html
	let ctr=ctr+1
	else
	echo "$i is closed"
	fi
done

echo "Number of open nodes: $ctr" >> moneriote.log

cat bottom.html >> node_script.html
cat node_script.html >> nodes.html

cp nodes.html $html_dir/

echo `date` "The script finished" >> moneriote.log

# http://stackoverflow.com/questions/16753876/javascript-button-to-pick-random-item-from-array
# http://www.javascriptkit.com/javatutors/randomorder.shtml



