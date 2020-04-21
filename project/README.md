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

### Accounts

* Patroni
user: postgres
password: gfhjkm

### Resources of the lab

* [http://192.168.10.10:7000/] - HAProxy

### How to check

Patroni
```
/usr/local/bin/patronictl -c /etc/patroni/patroni.yml list
psql -U postgres -h 192.168.10.10 -p 5000
postgres=# select * from pg_stat_replication;
```

### Otus projects

https://otus.ru/nest/post/801/ 
https://otus.ru/nest/post/384/ 
 https://otus.ru/nest/post/638/
https://github.com/sinist3rr/otus-linux/tree/master/PROJ

### AWX

* https://github.com/ansible/awx/blob/devel/INSTALL.md - official installation guide
* https://github.com/sujiar37/AWX-HA-InstanceGroup - AWX on docker with HA
* https://www.centlinux.com/2019/09/install-ansible-awx-with-docker-compose-on-centos-7.html - Install Ansible AWX with Docker-Compose on CentOS 7

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
