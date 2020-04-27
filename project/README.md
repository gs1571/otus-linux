# High-Avalability Atomation platform based on AWX

## Description

The project presents very common architecture of infrastructure for a WEB application. 
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

All of them will be connected to one network and spread over seven VMs follow the diagram:

![network diagram](diagrams/network_diagram.png)

Functional diagram is presented below:

![functional diagram](diagrams/functional_diagram.png)

Backup details

The pg_probackup utility is used for that purpose. The util run by cron. Strantegy is:
- create one full backup by ansible play-book
- create full backup every hour
- create delta backup every 10 minutes
- retention policy is save last five full backups
- for each of databse servers in cluster its own backup store is created

Some specific points of the lab enviroments:
- traffic to AWX web nodes balanced by VRRP since they can work in same time for management of AWX
- at least of three task nodes is required for AWX cluster, since additional VM just for wax task purpose is intriduced

Thanks a lot for Ansible roles of AWX cluster to [sujiar37](https://github.com/sujiar37). I adopted material from his repo https://github.com/sujiar37/AWX-HA-InstanceGroup.

Thanks a lot for webjournal app for journald-remote to [skob](https://github.com/skob). I adopted material from his repo https://github.com/skob/journal.

### Checklist

* [x] Common config
* [x] Keepalived pair
* [x] HAProxy pair
* [x] Patroni cluster
* [x] AWX cluster
* [x] Postgres backup
* [x] Firewall
* [x] Logging
  - [x] haproxy
  - [x] patroni
  - [ ] consul
  - [ ] postgres
  - [ ] awx
  - [ ] pg_probackup
* [x] Prometheus
  - [x] node_exporter
  - [x] haproxy
  - [x] patroni
  - [ ] consul
  - [ ] postgres
  - [ ] awx
  - [ ] pg_probackup
* [x] Grafana
* [x] Final testing
  - [x] power-off hap1
  - [x] power-on  hap1
  - [x] power-off hap2
  - [x] power-on  hap2
  - [x] power-off task
  - [x] power-on  task
  - [x] power-off pg1
  - [x] power-on  pg1
  - [x] power-off pg2
  - [x] power-on  pg2
  - [x] power-off pg3
  - [x] power-on  pg3

Optional:
* [ ] IPv6

## Useful links and notes

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

### How to check

Patroni
```
/usr/local/bin/patronictl -c /etc/patroni/patroni.yml list

psql -U postgres -h 192.168.10.10 -p 5000

postgres=# select * from pg_stat_replication;

SELECT d.datname as "Name",
pg_catalog.pg_get_userbyid(d.datdba) as "Owner"
FROM pg_catalog.pg_database d
WHERE d.datname = 'your_name'
ORDER BY 1;
```

journald
```
journalctl -D /var/log/journal/remote/ --follow
```

Backup
```
pg_probackup-10 show -B /var/lib/pgbackup/  --instance 'pg1'
pg_probackup-10 show -B /var/lib/pgbackup/  --instance 'pg2'
pg_probackup-10 show -B /var/lib/pgbackup/  --instance 'pg3'
pg_probackup-10 show -B /var/lib/pgbackup/
```
