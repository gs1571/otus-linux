# Инициализация системы. Systemd и SysV


## Полезная информация

Основные каталоги:
* **/usr/lib/systemd** - основной каталог
* **/usr/lib/systemd/system** - все unit-файлы прилетающие из пакетов
* **/etc/systemd** - конфигурация
* **/etc/systemd/system** - оверлей куда пишет администратор, положенные сюда юнит файлы имеют высший приоритет над юнит-файлами из /usr/lib/
* **/etc/systemd/system/*.wants** - каталоги уровней, в которые кладутся симлинки при **systemctl enable**
* **/etc/sysconfig** - каталог, содержащий переменные

Управление:
```
systemctl status somename.service
systemctl start|stop|(try)-restart|reload somename.service
systemctl reload|reload-or-(try)-restart somename.service
systemctl (re)enable (--now)|disable|mask|unmask somename.service
systemctl daemon-reload
```

[root@otuslinux vagrant]#  cat /etc/sysconfig/watchdog
# Configuration file for my watchdog service
# Place it to /etc/sysconfig

# File and word in that file that we will be monit
WORD="ALERT"
LOG=/var/log/watchlog.log

[root@otuslinux vagrant]# cat /opt/watchlog.sh
#!/bin/bash

WORD=$1
LOG=$2
DATE=`date`

if grep $WORD $LOG &> /dev/null
then
  logger "$DATE: I found word, Master!"
else
  logger "$DATE: I didn't find word, Master!"
  exit 0
fi

[root@otuslinux vagrant]# cat /etc/systemd/
bootchart.conf  journald.conf   system/         user/
coredump.conf   logind.conf     system.conf     user.conf
[root@otuslinux vagrant]# cat /etc/systemd/system/watchlog.unit
cat: /etc/systemd/system/watchlog.unit: No such file or directory
[root@otuslinux vagrant]# cat /etc/systemd/system/watchlog.service
[Unit]
Description=My watchlog service

[Service]
Type=oneshot
EnvironmentFile=/etc/sysconfig/watchdog
ExecStart=/opt/watchlog.sh $WORD $LOG

[root@otuslinux vagrant]# cat /etc/systemd/system/watchlog.timer
[Unit]
Description=Run watchlog script every 30 second

[Timer]
# Run every 30 second
OnUnitActiveSec=30
Unit=watchlog.service

[Install]
WantedBy=multi-user.target

[root@otuslinux vagrant]# cat /etc/sysconfig/spawn-fcgi
# You must set some working options before the "spawn-fcgi" service will work.
# If SOCKET points to a file, then this file is cleaned up by the init script.
#
# See spawn-fcgi(1) for all possible options.
#
# Example :
SOCKET=/var/run/php-fcgi.sock
#OPTIONS="-u apache -g apache -s $SOCKET -S -M 0600 -C 32 -F 1 -P /var/run/spawn-fcgi.pid -- /usr/bin/php-cgi"
OPTIONS="-u apache -g apache -s $SOCKET -S -M 0600 -C 32 -F 1 -- /usr/bin/php-cgi"

[root@otuslinux vagrant]# cat /etc/systemd/system/spawn-fcgi.service
[Unit]
Description=Spawn-fcgi startup service by Otus
After=network.target

[Service]
Type=simple
PIDFile=/var/run/spawn-fcgi.pid
EnvironmentFile=/etc/sysconfig/spawn-fcgi
ExecStart=/usr/bin/spawn-fcgi -n $OPTIONS
KillMode=process

[Install]
WantedBy=multi-user.target
