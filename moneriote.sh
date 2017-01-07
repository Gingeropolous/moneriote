#!/bin/bash
#Gingeropolous Open node checker


DIR=~/files_moneriote

daemon=192.168.1.9
wallet=test.bin
pass=test
wrpc=18092

### Check Existing DNS entries for any to remove

DOMAIN=node.moneroworld.com
export IPs=`dig $DOMAIN | grep $DOMAIN | grep -v ';' | awk '{ print $5 }'`;
export arr=($IPs)
# declare -a opennodes
# declare -a closednodes

for i in "${arr[@]}"
do
   : 
	if nc -z $i 18081  
	then 
	echo "$i is up" 
	opennodes+=($i)
	else
	echo "$i is down"
	closednodes+=($i)
	fi
done

echo ${opennodes[@]}
export opennodes

# Check network white nodes for domains to add

white=$(monerod --rpc-bind-ip 192.168.1.9 print_pl | grep white |  awk '{print $3}' | cut -f 1 -d ":")
white_a=($white)


# Check to see if wallet connects and is behaving good (matches local daemon height +/- a few)

export arr_onodes=($opennodes)
for p in "${arr_onodes[@]}"
do
   : 
	export lhit="$(curl -X POST http://192.168.1.9:18081/getheight -H 'Content-Type: application/json' | grep height | cut -f 2 -d : | cut -f 1 -d ,)"
	echo "Local height: " $lhit
	monero-wallet-rpc --daemon-host $p --wallet-file $DIR/$wallet --password $pass --rpc-bind-port $wrpc & \
	end=$((SECONDS+60))
	goteem=0
	while [ $SECONDS -lt $end  ||  $goteem=="0" ] ; ### GODDAMN YOU SOINOFBITCH JUST WORK
	do
	if [ "$(tail -4 monero-wallet-cli.log | grep "net_service" )" ] ;
	then
	echo "GOTTEEEM"
	goteem=1
	fi
	sleep 1
	done

	echo "Checking node $i"

	export rhit="$(curl -X POST http://127.0.0.1:18092/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"getheight"}' -H 'Content-Type: application/json' | grep height | cut -f 2 -d :)"
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
	fi
	curl -X POST http://127.0.0.1:18092/json_rpc -d '{"jsonrpc":"2.0","id":"0","method":"stop_wallet"}' -H 'Content-Type: application/json'
	sleep 2
done

#monero-wallet-rpc --daemon-host $daemon --wallet-file $DIR/$wallet --wallet-password $pass --rpc-bind-port $wrpc

