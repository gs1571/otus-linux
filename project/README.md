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
* [ ] Intermediate testing
  - [x] power-off hap1
  - [x] power-on  hap1
  - [ ] power-off hap2
  - [ ] power-on  hap2
  - [ ] power-off task
  - [ ] power-on  task
  - [ ] power-off pg1
  - [ ] power-on  pg1
  - [x] power-off pg2
  - [x] power-on  pg2
  - [ ] power-off pg3
  - [ ] power-on  pg3
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
* [ ] Final testing
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

### Firewall

* hap1
users:(("dhclient",pid=5161,fd=6)) *:68
users:(("rpcbind",pid=1439,fd=5),("systemd",pid=1,fd=57)) *:111
users:(("ntpd",pid=6420,fd=16)) *:123
users:(("rpcbind",pid=1439,fd=10)) *:660
users:(("beam.smp",pid=10521,fd=8)) *:25672
users:(("haproxy",pid=9767,fd=6)) *:5000
users:(("rpcbind",pid=1439,fd=4),("systemd",pid=1,fd=50)) *:111
users:(("epmd",pid=10549,fd=3)) *:4369
users:(("sshd",pid=2656,fd=3)) *:22
users:(("haproxy",pid=9767,fd=4)) *:7000

* hap2
users:(("dhclient",pid=5143,fd=6)) *:68
users:(("rpcbind",pid=1515,fd=5),("systemd",pid=1,fd=39)) *:111
users:(("ntpd",pid=6400,fd=29)) *:123
users:(("rpcbind",pid=1515,fd=10)) *:676
users:(("beam.smp",pid=10495,fd=8)) *:25672
users:(("haproxy",pid=9745,fd=6)) *:5000
users:(("rpcbind",pid=1515,fd=4),("systemd",pid=1,fd=38)) *:111
users:(("epmd",pid=10510,fd=3)) *:4369
users:(("sshd",pid=2643,fd=3)) *:22
users:(("haproxy",pid=9745,fd=4)) *:7000

* task
users:(("dhclient",pid=5177,fd=6)) *:68
users:(("rpcbind",pid=1433,fd=5),("systemd",pid=1,fd=67)) *:111
users:(("ntpd",pid=6424,fd=29)) *:123
users:(("rpcbind",pid=1433,fd=10)) *:635
users:(("beam.smp",pid=9358,fd=8)) *:25672
users:(("rpcbind",pid=1433,fd=4),("systemd",pid=1,fd=66)) *:111
users:(("epmd",pid=9374,fd=3)) *:4369
users:(("sshd",pid=2503,fd=3)) *:22

* pg1

users:(("rpcbind",pid=1527,fd=10)) *:1003
users:(("dhclient",pid=5102,fd=6)) *:68
users:(("rpcbind",pid=1527,fd=5),("systemd",pid=1,fd=61)) *:111
users:(("ntpd",pid=6356,fd=16)) *:123
users:(("patroni",pid=10308,fd=4)) 192.168.10.21:8008
users:(("rpcbind",pid=1527,fd=4),("systemd",pid=1,fd=60)) *:111
users:(("sshd",pid=2437,fd=3)) *:22
users:(("postgres",pid=10736,fd=3)) 192.168.10.21:5432

* pg2

users:(("dhclient",pid=5119,fd=6)) *:68
users:(("dhclient",pid=2524,fd=6)) *:68
users:(("rpcbind",pid=1481,fd=5),("systemd",pid=1,fd=65)) *:111
users:(("ntpd",pid=6372,fd=16)) *:123
users:(("rpcbind",pid=1481,fd=10)) *:680
users:(("patroni",pid=10328,fd=4)) 192.168.10.22:8008
users:(("rpcbind",pid=1481,fd=4),("systemd",pid=1,fd=64)) *:111
users:(("sshd",pid=2447,fd=3)) *:22
users:(("postgres",pid=10925,fd=3)) 192.168.10.22:5432

* pg3

users:(("dhclient",pid=5073,fd=6)) *:68  
users:(("dhclient",pid=2398,fd=6)) *:68  
users:(("rpcbind",pid=1530,fd=5),("systemd",pid=1,fd=31)) *:111 
users:(("ntpd",pid=6323,fd=16)) *:123 
users:(("rpcbind",pid=1530,fd=10)) *:704 
users:(("patroni",pid=10281,fd=4)) 192.168.10.23:8008
users:(("rpcbind",pid=1530,fd=4),("systemd",pid=1,fd=30)) *:111 
users:(("sshd",pid=2584,fd=3)) *:22  
users:(("postgres",pid=10880,fd=3)) 192.168.10.23:5432

* mon

users:(("dhclient",pid=5070,fd=6)) *:68  
users:(("dhclient",pid=2313,fd=6)) *:68  
users:(("consul",pid=16064,fd=11)) 192.168.10.30:8301
users:(("consul",pid=16064,fd=8)) 192.168.10.30:8302
users:(("rpcbind",pid=1610,fd=5),("systemd",pid=1,fd=27)) *:111 
users:(("ntpd",pid=6331,fd=16)) *:123 
users:(("consul",pid=16064,fd=12)) 127.0.0.1:8600
users:(("rpcbind",pid=1610,fd=10)) *:843 
users:(("consul",pid=16064,fd=3)) 192.168.10.30:8300
users:(("consul",pid=16064,fd=10)) 192.168.10.30:8301
users:(("consul",pid=16064,fd=7)) 192.168.10.30:8302
users:(("rpcbind",pid=1610,fd=4),("systemd",pid=1,fd=26)) *:111 
users:(("nginx",pid=14359,fd=7),("nginx",pid=14358,fd=7),("nginx",pid=14357,fd=7)) *:80  
users:(("consul",pid=16064,fd=14)) 192.168.10.30:8500
users:(("sshd",pid=2591,fd=3)) *:22  
users:(("consul",pid=16064,fd=13)) 127.0.0.1:8600
users:(("python2",pid=14468,fd=9)) 127.0.0.1:8888

### Otus projects

* https://otus.ru/nest/post/801/ 
* https://otus.ru/nest/post/384/ 
*  https://otus.ru/nest/post/638/
* https://github.com/sinist3rr/otus-linux/tree/master/PROJ

### Postgres Backup

* https://postgrespro.ru/education/courses/DBA1 - PostgreSQL backup lecture 17
* https://postgrespro.github.io/pg_probackup/ - documenation
* https://github.com/postgrespro/pg_probackup - installation
* https://postgrespro.ru/docs/postgrespro/10/app-pgprobackup - useful documentation


### HAProxy
* https://dasunhegoda.com/how-to-setup-haproxy-with-keepalived/833/

### AWX

Base version:
* https://github.com/ansible/awx/blob/devel/INSTALL.md - official installation guide
* https://www.centlinux.com/2019/09/install-ansible-use-playbooks-centos-7.html
* https://www.centlinux.com/2019/09/install-ansible-awx-with-docker-compose-on-centos-7.html

HA version:
* https://github.com/sujiar37/AWX-HA-InstanceGroup - AWX on docker with HA

### Journald

* https://habr.com/ru/company/southbridge/blog/317182/
* https://sematext.com/docs/logagent/how-to-centralize-linux-system-journal/

### Working notes (will be removed)

pre-install
```
yum-config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
yum install -y ansible git gcc gcc-c++ nodejs gettext device-mapper-persistent-data lvm2 bzip2 python-pip python-devel docker-ce
pip install --upgrade pip
pip install docker-compose
systemctl enable --now docker
```

inventory file
```
pg_hostname=192.168.10.10
pg_port=5000
```

database
```
psql -U postgres -h hap -p 5000
CREATE USER awx WITH ENCRYPTED PASSWORD 'awxpass';
CREATE DATABASE awx OWNER awx;
```

install
```
git clone --depth 50 https://github.com/ansible/awx.git
cd awx/installer
ansible-playbook -i inventory install.yml
```

cli
```
pip install "https://github.com/ansible/awx/archive/11.0.0.tar.gz#egg=awxkit&subdirectory=awxkit" --install-option="--install-scripts=/usr/bin"
```


```
sudo yum install -y ansible git
```
HA-AWX
```
git clone https://github.com/sujiar37/AWX-HA-InstanceGroup.git
cd AWX-HA-InstanceGroup/
ansible-playbook -i inventory/hosts awx_ha.yml --skip-tags fw_rules -vvvv
```
```
cat > inventory/hosts
[all]

[awx_instance_group_web]
hap1
hap2

[awx_instance_group_task]
task1

```
```
cat > inventory/group_vars/all.yml
---
ansible_user: vagrant
ansible_password: vagrant
### AWX Default Settings
awx_unique_secret_key: awxsecret
awx_admin_default_pass: password

### Postgre DB details
pg_db_host: "192.168.10.10"
pg_db_pass: "awxpass"
pg_db_port: "5000"
pg_db_user: "awx"
pg_db_name: "awx"


###  RabbitMQ default settings
rabbitmq_cookie: "cookiemonster"
rabbitmq_username: "awx"
rabbitmq_password: "password"
```
Re run docker containers
```
cd /var/lib/awx/build_image && docker-compose restart
```

### Postgres Backup

* https://postgrespro.ru/education/courses/DBA1 - PostgreSQL backup lecture 17
* https://postgrespro.github.io/pg_probackup/ - documenation
* https://github.com/postgrespro/pg_probackup - installation
* https://postgrespro.ru/docs/postgrespro/10/app-pgprobackup - useful documentation

Advises:

--ssh-options='CheckHostIP=no'

* full backup
```
pg_probackup-11 backup \
        -d postgres \
        -B $BACKUP_FOLDER \
        --instance $BACKUP_INSTANCE \
        --compress-algorithm=zlib \
        --compress-level=4 \
        -j 4 \
        --log-filename=$BACKUP_LOG_FILENAME \
        --log-level-console=info \
        --log-level-file=info \
        --remote-user=$BACKUP_REMOTE_USER \
        --remote-host=$BACKUP_HOST \
        -b FULL
}
```
* Purge old backups
```
# Purge old backup
function backup_delete {
pg_probackup-11 delete \
        -B $BACKUP_FOLDER \
        --instance $BACKUP_INSTANCE \
        --retention-redundancy=30 \
        --wal-depth=30 \
        --delete-wal \
        --delete-expired \
        --merge-expired \
}
```
* Restoration
```
bootstrap:
  method: probackup
  probackup:
    command: ssh dbbackup@<backup_IP> 'bash /var/backup/pg_restore.sh'
    keep_existing_recovery_conf: false
    recovery_conf:
     recovery_target_timeline: latest
     restore_command: pg_probackup-11 archive-get -B /var/backup --instance db-mt --remote-user=dbbackup --wal-file-path %p --wal-file-name %f --remote-host=<remote_host_ip>
```
> Это на бекап хосте. И он по ссх коннектится к хосту БД. Там тоже нужен pg_probackup

