# Project

## Description

The project presents very common architecture of infrastructure for a WEB application. 
The lab eviroment has:
* Load balancers
  - keepalived
  - haproxy
* WEB application
  - AWX or something else
* Database cluster
  - patroni cluster of the three nodes
* Loging server
  - journald
* Monitoring server
  - grafana
  - prometheus
* Backup server
  - barman

All of them will be connected to one network and spread over six VMs follow the diagram:

![network diagram](diagrams/network_diagram.png)

Functional diagram is presented below:

![functional diagram](diagrams/functional_diagram.png)

Some specific points of the lab enviroments:
- load balancer will support WEB application and DB cluster in the same time;
- all the VMs interconnect with each other just over IPv6 (if I have enough time).


## Useful links and notes
https://otus.ru/nest/post/801/ 
https://otus.ru/nest/post/384/ 
 https://otus.ru/nest/post/638/
https://github.com/sinist3rr/otus-linux/tree/master/PROJ

1. HAproxy + keepalived
1. AWX on docker with HA - https://github.com/sujiar37/AWX-HA-InstanceGroup
1. HAproxy + keepalived
1. PostgreSQL - Patroni
1. Logs - journald
1. Monitoring - Graphana/Prometheus