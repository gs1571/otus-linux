# High-Avalability Atomation platform based on AWX

## Description

The project presents HA cluster of AWX. [AWX](https://github.com/ansible/awx) provides a web-based user interface, REST API, and task engine built on top of Ansible. It is the upstream project for Tower, a commercial derivative of AWX.

The lab eviroment has:
* Load balancers
  - keepalived
  - haproxy
* WEB application
  - AWX version 9.2.0
* Database cluster
  - PostgreSQL Patroni cluster with three nodes
* Backup of the database
  - pg_probackup
* Loging server
  - journald
* Monitoring server
  - grafana
  - prometheus

All of them are connected to one network and spread over seven VMs follow the diagram:

![network diagram](diagrams/network_diagram.png)

Functional diagram is presented below:

![functional diagram](diagrams/functional_diagram.png)

Backup details

The pg_probackup utility is used for that purpose. The util run by cron. Strantegy is:
- create one full backup by ansible playbook
- create full backup every hour
- create delta backup every 10 minutes
- retention policy is save last five full backups
- for each of database servers in cluster its own backup store is created

Some specific points of the lab enviroments:
- patroni cluster is supported just one instance of consul database hosted on VM mon (it sould be fixed to achive fully HA)
- traffic to AWX web nodes balanced by VRRP since they can work in same time for management of AWX
- at least of three task nodes is required for AWX cluster, since additional VM just for wax task purpose is intriduced
- last role awx_ha_recovery is required since two of three task node are not connected to the cluster and their reboot are necessary
- monitoring part has just node_exporter and does not provide more detail monitoring information from other elemnts of lab (point for improvement)
- centralizelogging does not get logs from AWX, Postgres (point for improvement)

Thanks a lot for Ansible roles of AWX cluster to [sujiar37](https://github.com/sujiar37). I adopted material from his repo https://github.com/sujiar37/AWX-HA-InstanceGroup.

Thanks a lot for webjournal app for journald-remote to [skob](https://github.com/skob). I adopted material from his repo https://github.com/skob/journal.

### Resources of the lab

* HAPoxy
  - [http://192.168.10.10:7000]

* AWX
  - [http://192.168.10.10]
  - user: admin
  - password: password

* PostgreSQL
  - psql://192.168.10.10:5000
  - user: postgres
  - password: gfhjkm

* webjournal
  - [http://192.168.10.30]
  
* Consul
  - [http://192.168.10.30:8500]

* Pormetheus
  - [http://192.168.10.30:9090/graph]

* Grafana
  - [http://192.168.10.30:3000]
