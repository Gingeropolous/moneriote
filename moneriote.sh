#!/bin/bash
#Gingeropolous Open node checker

# This is the directory where files are written to.
# If you run as a cronjob, you have to use the full path
DIR=/home/main12/files_moneriote

# This is the path for your monerod binary.
monerod=monerod

# This is the ip of your local daemon. If you're not running an open node, 127.0.0.1 is fine.
daemon=192.168.1.2

#Where your going to dump the file that will be published
html_dir=/var/www/mine.moneroworld.com/public_html/pages/

# Bound rpc port
bport=18089

#Port to sniff for
port=18089

echo $monerod
echo $daemon

###

mkdir $DIR
cp /home/main12/moneriote/*.html $DIR
cd $DIR
rm open_nodes.txt
rm nodes.html
cp nodes_base.html nodes.html

### Begin header of random thinger

cp base.html node_script.html

echo "##############"
echo "Check network white nodes for domains to add"

white=$($monerod --rpc-bind-ip $daemon --rpc-bind-port $bport print_pl | grep white | awk '{print $3}' | cut -f 1 -d ":")


white_a=($white)
echo ${white_a[@]}
echo "################"
echo ${#white_a[@]}

echo "#############"
echo "Starting loop"

ctr=0

echo "Number of nodes: "${#white_a[@]} >> moneriote.log


#Comment out to check within the loop, and uncomment the one below
l_hit="$(curl -X POST http://$daemon:$bport/getheight -H 'Content-Type: application/json' | grep height | cut -f 2 -d : | cut -f 1 -d ,)"

for i in "${white_a[@]}"
do
   : 
	echo "Checking ip: "$i
	#Uncomment the below to check within the loop
	#l_hit="$(curl -X POST http://$daemon:$bport/getheight -H 'Content-Type: application/json' | grep height | cut -f 2 -d : | cut -f 1 -d ,)"
	r_hit="$(curl -m 0.5 -X POST http://$i:$port/getheight -H 'Content-Type: application/json' | grep height | cut -f 2 -d : | cut -f 1 -d ,)"
	echo "Local Height: "$l_hit
	echo "Remote Height: "$r_hit
        mini=$(( $l_hit-10 ))
        echo "minimum is " $mini
        maxi=$(( $l_hit+10 ))
        echo "max is " $maxi
        if [[ "$r_hit" ==  "$l_hit" ]] || [[ "$r_hit" > "$mini" && "$r_hit" < "$maxi" ]] && [[ -n $r_hit ]] && [[ -n $l_hit ]]
        then
        echo "################################# Daemon $i is good" 
        ### Time to write these good ips to a file of some sort!
        ### Apparently javascript needs some weird format in order to randomize, so I'll make two outputs
        echo $i >> open_nodes.txt
	echo "myarray[$ctr]= \"$i\";" >> node_script.html
	let ctr=ctr+1
	elif [[ $r_hit ]] || [[ $l_hit ]]; then
	echo "Either the local or remote is dead"
	else
	echo "$i is closed"
	fi
done

cat bottom.html >> node_script.html
cat node_script.html >> nodes.html

echo `date` "The script finished" >> moneriote.log

sudo cp nodes.html $html_dir/

# http://stackoverflow.com/questions/16753876/javascript-button-to-pick-random-item-from-array
# http://www.javascriptkit.com/javatutors/randomorder.shtml



