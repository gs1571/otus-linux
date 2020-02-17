# Фильтрация трафика 

## Домашнее задание

## Полезная информация

The rules are setup to open the standard SSH port 22 after a series of single knocks to the ports 8881, 7777 and 9991 in that order.

32871
32277
27196

nmap -Pn --host-timeout 201 --max-retries 0 -p 32871 192.168.255.1
nmap -Pn --host-timeout 201 --max-retries 0 -p 32277 192.168.255.1
nmap -Pn --host-timeout 201 --max-retries 0 -p 27196 192.168.255.1

*nat
:PREROUTING ACCEPT [163:9928]
:INPUT ACCEPT [8:628]
:OUTPUT ACCEPT [362:26913]
:POSTROUTING ACCEPT [0:0]
-A POSTROUTING ! -d 192.168.0.0/16 -o eth0 -j MASQUERADE
COMMIT

*filter
:INPUT ACCEPT [0:0]
:TRAFFIC - [0:0]
:SSH-STEP-2 - [0:0]
:SSH-STEP-3 - [0:0]

# To get access to the SSH port, knocking three times is requred in follow way: 32871/TCP -> 32277/TCP -> 27196/TCP
-A INPUT -s 192.168.255.2/32 -j TRAFFIC
-A TRAFFIC -m state --state ESTABLISHED,RELATED -j ACCEPT
-A TRAFFIC -m state --state NEW -m tcp -p tcp --dport 22 -m recent --rcheck --seconds 30 --name KNOCK3 -j ACCEPT

-A TRAFFIC -m state --state NEW -m tcp -p tcp -m recent --name KNOCK3 --remove -j DROP

-A TRAFFIC -m state --state NEW -m tcp -p tcp --dport 27196 -m recent --rcheck --name KNOCK2 -j SSH-STEP-3
-A TRAFFIC -m state --state NEW -m tcp -p tcp -m recent --name KNOCK2 --remove -j DROP

-A TRAFFIC -m state --state NEW -m tcp -p tcp --dport 32277 -m recent --rcheck --name KNOCK1 -j SSH-STEP-2
-A TRAFFIC -m state --state NEW -m tcp -p tcp -m recent --name KNOCK1 --remove -j DROP

-A TRAFFIC -m state --state NEW -m tcp -p tcp --dport 32871 -m recent --name KNOCK1 --set -j DROP
-A SSH-STEP-2 -m recent --name KNOCK2 --set -j DROP
-A SSH-STEP-3 -m recent --name KNOCK3 --set -j DROP 
-A TRAFFIC -j DROP
COMMIT

   recent

       --set, --rcheck, --update and --remove are mutually exclusive.
       --name name
              Specify the list to use for the commands. If no name is given then DEFAULT will be used.
       [!] --set
              This will add the source address of the packet to the list. If the source address is already in the list, this will update  the  existing  entry.  This
              will always return success (or failure if ! is passed in).
       --rsource
              Match/save the source address of each packet in the recent list table. This is the default.
       [!] --rcheck
              Check if the source address of the packet is currently in the list.
       [!] --remove
              Check  if the source address of the packet is currently in the list and if so that address will be removed from the list and the rule will return true.
              If the address is not found, false is returned.
       --seconds seconds
              This option must be used in conjunction with one of --rcheck or --update. When used, this will narrow the match to only happen when the address  is  in
              the list and was seen within the last given number of seconds.