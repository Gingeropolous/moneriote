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
rm random_nodes.html

### Begin header of random thinger

echo -e "

<input type=\"\button\"\ id=\"\btnSearch\"\ value=\"\Search\"\ onclick=\"\GetValue();\"\ /> \n\
<p id="message" ></p> \n\
\n\
<script> \n\
function GetValue() \n\
{ \n\
    var random = contents[Math.floor(Math.random() * myarray.length)]; \n\
    //alert(random); \n\
    document.getElementById(\"\message\"\).innerHTML=random; \n\
} \n\
\n\
var contents=new Array() \n\
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
	echo "contents[$ctr]='$i'" >> random_nodes.html
	ctr=$ctr+1
	else
	echo "$i is closed"
	fi
done

echo "</script>" >> random_nodes.html


# http://stackoverflow.com/questions/16753876/javascript-button-to-pick-random-item-from-array
# http://www.javascriptkit.com/javatutors/randomorder.shtml


<input type="button" id="btnSearch" value="Search" onclick="GetValue();" />
<p id="message" >ddd</p>

<script>

function GetValue()
{
    var myarray= new Array();
  myarray[0]= "85.194.238.130";
  myarray[1]= "176.31.117.66";
  myarray[2]= "107.167.87.242";
  myarray[3]= "38.135.33.74";
  myarray[4]= "23.228.193.90";
   var random = myarray[Math.floor(Math.random() * myarray.length)];
   document.getElementById("message").innerHTML=random;
}
</script>

