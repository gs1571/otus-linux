# DNS/DHCP - настройка и обслуживание

## Домашнее задание

Стенд разворачивается через [vagrantfile](vagrantfile). Провиженинг делается через ansible playbook, который настраивает DNS сервер на ns01 (master) и ns02 (slave) с реализацией функционала split-view.

Результат:
```bash
[vagrant@client ~]$ dig @192.168.50.10 web1.dns.lab +short
192.168.50.15
[vagrant@client ~]$ dig @192.168.50.10 web2.dns.lab +short
[vagrant@client ~]$ dig @192.168.50.10 www.newdns.lab +short
192.168.50.15
192.168.50.16
[vagrant@client ~]$ dig @192.168.50.11 web1.dns.lab +short
192.168.50.15
[vagrant@client ~]$ dig @192.168.50.11 web2.dns.lab +short
[vagrant@client ~]$ dig @192.168.50.11 www.newdns.lab +short
192.168.50.15
192.168.50.16
[vagrant@client ~]$

[vagrant@client2 ~]$ dig @192.168.50.10 web1.dns.lab +short
192.168.50.15
[vagrant@client2 ~]$ dig @192.168.50.10 web2.dns.lab +short
192.168.50.16
[vagrant@client2 ~]$ dig @192.168.50.10 www.newdns.lab +short
[vagrant@client2 ~]$ dig @192.168.50.11 web1.dns.lab +short
192.168.50.15
[vagrant@client2 ~]$ dig @192.168.50.11 web2.dns.lab +short
192.168.50.16
[vagrant@client2 ~]$ dig @192.168.50.11 www.newdns.lab +short
[vagrant@client2 ~]$
```

## Полезная информация

