#!/bin/bash

#Backup HAproxy cfg
cp /home/core/haproxy-config/haproxy.cfg /home/core/haproxy-config/haproxy.cfg.$(date +%Y%m%d)

#Delete previous backends
sed -i /^"    server k8s_cluster_kubenode"/d /home/core/haproxy-config/haproxy.cfg

#Export services list
kubectl get --all-namespaces svc -o 'jsonpath={"Service:"}{" "}{"Namespace:"}{" "}{"NodePort:"}{"\n"}{range .items[?(@.spec.ports[*].nodePort)]}{.metadata.name}{" "}{.metadata.namespace}{" "}{.spec.ports[*].nodePort}{"\n"}{end}' | column -t | grep -v "kube-system" > /home/core/haproxy-config/svc.http

#Get node port
p=$(kubectl describe svc my-nginx | grep NodePort | grep -o '[0-9]*')

#Check and delete "NotReady" nodes
kubectl get nodes | grep NotReady | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" | tee -a "list_nr.txt"
cat ./list_nr.txt | while read line; do
    kubectl delete node $line
done
rm list_nr.txt

#Get backend's list
curl http://localhost:8080/api/v1/nodes -s | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}"  | uniq | tee -a list.txt
cat ./list.txt | while read line; do
    echo "    server k8s_cluster_kubenode$n" $line:$p check | tee -a haproxy.cfg
done
rm list.txt

#Stop HAproxy container
id=$(docker ps | grep haproxy | cut -c-12)
docker stop $id

#Start HAproxy container with new config
docker run -d -p 80:80 -p 8090:8090 -v /home/core/haproxy-config:/usr/local/etc/haproxy/ haproxy:1.5

#echo option httpchk HEAD /index.html HTTP/1.0 >> backendslist.txt
