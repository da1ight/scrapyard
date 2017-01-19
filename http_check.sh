#!/bin/bash

#status=`curl -s -I http://sobolluxury.ru | grep HTTP/1.1 | awk {'print $2'}`;
status=`curl -o /dev/null --silent --head --write-out '%{http_code}\n' http://ya.ru`;

if [[ "$status" != "200" ]]
then
echo "Вы получили данное пиьсмо, так как на сайте ya.ru произошел сбой. Веб севрер и сервер базы данных были перезарущены!" >> /root/check.txt
echo " " >> /root/check.txt
service apache2 restart >> /root/check.txt 2>&1
service mysql restart >> /root/check.txt 2>&1
echo " " >> /root/check.txt
echo "Общие сведения о нагрузке на сервер:" >> /root/check.txt
w >> /root/check.txt
echo " " >> /root/check.txt
echo "Сведения об используемой памяти:" >> /root/check.txt
free -m >> /root/check.txt
echo " " >> /root/check.txt
echo "Логи веб сервера Apache:" >> /root/check.txt
tail /var/log/apache2/error.log >> /root/check.txt
cat /root/check.txt | mail -s "Sobolluxury Site Service Fail!" "YOURMAIL@mail.com"
rm /root/check.txt
fi
