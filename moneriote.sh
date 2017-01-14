#!/bin/bash
#Gingeropolous Open node checker


DIR=~/files_moneriote


monerod=monerod
daemon=192.168.1.9

DOMAIN=node.moneroworld.com


echo $monerod
echo $daemon

###

mkdir $DIR
cd $DIR
rm open_nodes.txt
rm random_nodes.js

### Begin header of random thinger

echo -e "
<!-- begin snippet: js hide: false console: false babel: false --> \n\
\n\
<!-- language: lang-js --> \n\
\n\
    var uls = document.querySelectorAll('ul'); \n\
    for (var j = 0; j < uls.length; j++) { \n\
      var ul = uls.item(j); \n\
      for (var i = ul.children.length; i >= 0; i--) { \n\
        ul.appendChild(ul.children[Math.random() * i | 0]); \n\
      } \n\
    } \n\
\n\
<!-- language: lang-html --> \n\
\n\
    <ul>\n\
" > random_nodes.html



### Check Existing DNS entries for any to remove

### Kind of stupid right now because I can't update a DNS entry

DOMAIN=node.moneroworld.com

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
echo ${#white_a[@]}

echo "#############"
echo "Starting loop"

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
        echo "<li>$i</li>" >> random_nodes.html
	else
	echo "$i is closed"
	fi
done

echo "</ul>" >> random_nodes.html



