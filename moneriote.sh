#!/bin/bash
#Gingeropolous Open node checker


DIR=~/files_moneriote


monerod=monerod
daemon=192.168.1.9
wallet=test.bin
pass=test
wrpc=18092
walletbin="monero-wallet-rpc"

echo $monerod
echo $daemon
echo $wallet
echo $pass
echo $wrpc
echo $walletbin

###

mkdir $DIR
cd $DIR
rm open_nodes.txt
rm random_nodes.js

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



white=$($monerod --rpc-bind-ip $daemon print_pl | grep white |  awk '{print $3}' | cut -f 1 -d ":")
white_a=($white)
echo ${white_a[@]}
echo "################"
echo ${#white_a[@]}

echo "#############"
echo "Starting loop"

for i in "${white_a[@]}"
do
   : 
	echo $i
        if nc -z -w 1 $i 18081  
        then 
        echo "$i is up" 
        opennodes+=($i)
        else
        echo "$i is down"
        closednodes+=($i)
        fi
done




# Check to see if wallet connects and is behaving good (matches local daemon height +/- a few)
# Ah screw the range.

echo ${opennodes[@]}
for p in "${opennodes[@]}"
do
   : 
	wrpc=$((wrpc+1))
	export lhit="$(curl -X POST http://192.168.1.9:18081/getheight -H 'Content-Type: application/json' | grep height | cut -f 2 -d : | cut -f 1 -d ,)"
	echo "Local height: " $lhit
	$walletbin --daemon-host $p --wallet-file $DIR/$wallet --password $pass --rpc-bind-port $wrpc & \
	end=$((SECONDS+60))
	goteem=0
	while (( SECONDS < end && goteem == 0 ))
	do
		if [ "$(tail -4 monero-wallet-cli.log | grep "net_service" )" ] ;
			then
			echo "GOTTEEEM"
			goteem=1
		fi
		sleep 1
	done

	echo "Checking node $i"

	export rhit="$(curl -X POST http://127.0.0.1:$wrpc/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"getheight"}' -H 'Content-Type: application/json' | grep height | cut -f 2 -d :)"
	echo "###############"
	echo "remote height: " $rhit
	echo "##############"
	mini=$(( $lhit-10 ))
	echo "minimum is " $mini
	maxi=$(( $lhit+10 ))
	echo "max is " $maxi
	if [[ "$hit" ==  "$lhit" ]]
	then
	echo "Daemon $p is good" 
	### Time to write these good ips to a file of some sort!
	### Apparently javascript needs some weird format in order to randomize, so I'll make two outputs
	echo $p >> open_nodes.txt
	echo "<li>$p</li>" >> random_nodes.html


	fi
	curl -X POST http://127.0.0.1:$wrpc/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"stop_wallet"}' -H 'Content-Type: application/json'
	sleep 0.5
	rm monero-wallet-cli.log


done
echo "</ul>" >> random_nodes.html


#monero-wallet-rpc --daemon-host $daemon --wallet-file $DIR/$wallet --wallet-password $pass --rpc-bind-port $wrpc

