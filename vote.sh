#!/bin/bash

echo "Введите число голосов:"
read i
n=0
while [  $n -lt $i ]
do 
userAgents=`curl -s http://www.user-agents.org/allagents.xml | grep -iB 5 '<Type>B</Type>' | grep -i '<String>' | cut -c 9- | sed 's/..........$//'`
maxLines=`echo "$userAgents" | wc -l | tr -d ' '`
randomUserAgent=$(echo "$userAgents" | sed -n $[ ( $RANDOM % ( $[ $maxLines - 1 ] + 1 ) ) + 1 ]p)

IP=`echo $((RANDOM%=255))"."$((RANDOM%=255))"."$((RANDOM%=255))"."$((RANDOM%=255))`
SESSIONID=`cat /dev/urandom | tr -d -c 'a-z0-9' | fold -w 32 | head -1`

echo $randomUserAgent
echo $IP
echo $SESSIONID

curl -i -s -k  -X 'POST'     -H "User-Agent: $randomUserAgent" -H "Content-Type: application/x-www-form-urlencoded" -H "REMOTE-ADDR: $IP" -H "X-Requested-With: XMLHttpRequest" -H "Connection: close" -H "Referer: http://www.yourdomain.ru/referer"     -b "_ym_usid=$SESSIONID; _ym_isad=2; PHPSESSID=$SESSIONID; _ym_visorc_28138833=w"     --data-binary $"member_id=150"     "http://www.yourdomain.ru/ajax_vote.php"
let n=n+1
done
