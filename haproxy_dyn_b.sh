#!/bin/bash
n=1
#Backup HAproxy cfg
cp /home/core/haproxy-config/haproxy.cfg /home/core/haproxy-config/haproxy.cfg.$(date +%Y%m%d)
#Delete previous backends
sed -i /^"    server k8s_cluster_kubenode"/d /home/core/haproxy-config/haproxy.cfg
#Get node port
p=$(kubectl describe svc my-nginx | grep NodePort | grep -o '[0-9]*')
#Get backend's list
curl http://localhost:8080/api/v1/nodes -s | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}"  | uniq | tee -a list.txt
cat ./list.txt | while read line; do
    echo "    server k8s_cluster_kubenode$n" $line:$p check | tee -a haproxy.cfg
    let n=n+1
done
rm list.txt
#Stop HAproxy container
docker ps | grep haproxy | cut -c-12
#Start HAproxy cantainer with new config
docker run -d -p 80:80 -v /home/core/haproxy-config:/usr/local/etc/haproxy/ haproxy:1.5
#echo option httpchk HEAD /index.html HTTP/1.0 >> backendslist.txt
