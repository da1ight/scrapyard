#!/bin/bash

#Set nodes counter
n=1

#Backup HAproxy cfg
cp /home/core/haproxy-config/haproxy.cfg /home/core/haproxy-config/haproxy.cfg.$(date +%Y%m%d)

#Delete previous HAProxy settings
sed -i '25{q}' /home/core/haproxy-config/haproxy.cfg

#Export services list for status page
/opt/bin/kubectl get --all-namespaces svc -o 'jsonpath={"Service:"}{" "}{"Namespace:"}{" "}{"NodePort:"}{"\n"}{range .items[?(@.spec.ports[*].nodePort)]}{.metadata.name}{" "}{.metadata.namespace}{" "}{.spec.ports[*].nodePort}{"\n"}{end}' | column -t | grep -v "kube-system" > /home/core/haproxy-config/svc.http

#Check and delete "NotReady" nodes
/opt/bin/kubectl get nodes | grep NotReady | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" | tee -a "list_nr.txt"
cat ./list_nr.txt | while read line; do
    /opt/bin/kubectl delete node $line
done
rm list_nr.txt

#Export service/port list
/opt/bin/kubectl get --all-namespaces svc -o 'jsonpath={range .items[?(@.spec.ports[*].nodePort)]}{.metadata.name}{" :"}{.spec.ports[*].nodePort}{"\n"}{end}' > service.txt

#Get nodeport values
for NODEPORT in $(/opt/bin/kubectl get --all-namespaces svc -o 'jsonpath={range .items[?(@.spec.ports[*].nodePort)]}{.spec.ports[*].nodePort}{"\n"}{end}');
do

#Add new services to HAProxy config
 echo -n "listen "; sed q ./service.txt
 sed -i 1d ./service.txt
 echo "        mode tcp"
 echo "        option tcplog"
 echo "        balance roundrobin"
  /opt/bin/kubectl get nodes | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" > list.txt
  cat ./list.txt | while read line; do
  echo "        server k8s_cluster_kubenode$n" $line:$NODEPORT check
  let n=n+1
  done;
  echo
  rm list.txt
done;

rm service.txt

#Stop HAproxy container
id=$(docker ps | grep haproxy | cut -c-12)
docker stop $id

#Start HAproxy container with new config
docker run -d -p 80:80 -v /home/core/haproxy-config:/usr/local/etc/haproxy/ haproxy:1.5

exit 0
