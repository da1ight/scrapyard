#!/bin/bash
OUTPUTFILE=./output.txt
echo -n "Enter web service hostname or IP:"
read host
echo "***Megafon Test***" | tee -a $OUTPUTFILE
echo "-PING-" | tee -a $OUTPUTFILE
ping -I !YOUR ISP IP HERE! -c 10 $host | tee -a $OUTPUTFILE
echo "-TRACEROUTE-" | tee -a $OUTPUTFILE
traceroute -i eth1 $host | tee -a $OUTPUTFILE
echo "-MTR-" | tee -a $OUTPUTFILE
/usr/sbin/mtr --no-dns --address !YOUR ISP IP HERE! $host --report | tee -a $OUTPUTFILE
echo "***Teleport Test***" | tee -a $OUTPUTFILE
echo "-PING-" | tee -a $OUTPUTFILE
ping -I !YOUR ISP IP HERE! -c 10 $host | tee -a $OUTPUTFILE
echo "-TRACEROUTE-" | tee -a $OUTPUTFILE
traceroute -i eth2 $host | tee -a $OUTPUTFILE
echo "-MTR-" | tee -a $OUTPUTFILE
/usr/sbin/mtr --no-dns --address !YOUR ISP IP HERE! $host --report | tee -a $OUTPUTFILE
