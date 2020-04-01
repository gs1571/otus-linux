# PostreSQL

## Домашнее задание

Развернуть кластер PostgreSQL из трех нод. Создать тестовую базу -
проверить статус репликации
- Сделать switchover/failover
- Поменять конфигурацию PostgreSQL + с параметром требующим перезагрузки

* Настроить клиентские подключения через HAProxy

### Описание стенда

Стенд создан на основе стенда взятого из репозитория - https://gitlab.com/otus_linux/patroni. В стенд были внесены следующие изменения:
- ubuntu-server был заменен на centos на всех VM;
- добавлена третья нода PostgreSQL;
- версия PostgreSQL изменена с 11 на 10.

Cтенд содержит следующие VM:
- consul - БД Consul, DCS для кластера patroni
- pg1, pg3, pg3 - три сервера PostgreQSL 10 с установленным на тех же серверах patroni.
- haproxy - балансировщик проверяющий доступность patroni на каждой из нод кластера и направляющего весь прихдящий на него трафик на порт 5000 в текущую master ноду кластера.

IP адреса:
- 192.168.11.100 - consul;
- 192.168.11.101 - haproxy, управление по порту 7000, балансировка до кластера БД по порту 5000;
- 192.168.11.120 - первая нода кластера БД;
- 192.168.11.121 - вторая нода кластера БД;
- 192.168.11.122 - третья нода кластера БД;

Стенд разворачивается через [Vagrantfile](Vagrantfile) в котором при провижиненге последней VM запускается ansible-playbook.

### Проверка стенда

#### Создание тестовой базы и проверка репликации

Проверяем состояние кластера, подключаемся через балансировщик к мастеру, проверяем что есть репликация на две других ноды в кластере
```
[root@pg1 vagrant]# /usr/local/bin/patronictl -c /etc/patroni/patroni.yml list
+---------+--------+----------------+--------+---------+----+-----------+
| Cluster | Member |      Host      |  Role  |  State  | TL | Lag in MB |
+---------+--------+----------------+--------+---------+----+-----------+
|   otus  |  pg1   | 192.168.11.120 | Leader | running |  1 |           |
|   otus  |  pg2   | 192.168.11.121 |        | running |  1 |         0 |
|   otus  |  pg3   | 192.168.11.122 |        | running |  1 |         0 |
+---------+--------+----------------+--------+---------+----+-----------+
[root@pg1 vagrant]# su - postgres
Last login: Wed Apr  1 04:54:45 UTC 2020 on pts/0
-bash-4.2$ psql -h 192.168.11.101 -p 5000
Password:
psql (10.12)
Type "help" for help.

postgres=# \x
Expanded display is on.
postgres=# select * from pg_stat_replication;
-[ RECORD 1 ]----+------------------------------
pid              | 7445
usesysid         | 16384
usename          | replicator
application_name | pg2
client_addr      | 192.168.11.121
client_hostname  |
client_port      | 42406
backend_start    | 2020-03-31 20:41:54.333254+00
backend_xmin     |
state            | streaming
sent_lsn         | 0/40010C8
write_lsn        | 0/40010C8
flush_lsn        | 0/40010C8
replay_lsn       | 0/40010C8
write_lag        |
flush_lag        |
replay_lag       |
sync_priority    | 0
sync_state       | async
-[ RECORD 2 ]----+------------------------------
pid              | 7446
usesysid         | 16384
usename          | replicator
application_name | pg3
client_addr      | 192.168.11.122
client_hostname  |
client_port      | 54636
backend_start    | 2020-03-31 20:41:58.745916+00
backend_xmin     |
state            | streaming
sent_lsn         | 0/40010C8
write_lsn        | 0/40010C8
flush_lsn        | 0/40010C8
replay_lsn       | 0/40010C8
write_lag        |
flush_lag        |
replay_lag       |
sync_priority    | 0
sync_state       | async

postgres=#
```
Проверяем список баз и создаем новую базу test:
```
postgres=# \x
Expanded display is off.
postgres=# \l+
                                                                    List of databases
   Name    |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges   |  Size   | Tablespace |                Description
-----------+----------+----------+-------------+-------------+-----------------------+---------+------------+--------------------------------------------
 postgres  | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |                       | 7855 kB | pg_default | default administrative connection database
 template0 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +| 7721 kB | pg_default | unmodifiable empty database
           |          |          |             |             | postgres=CTc/postgres |         |            |
 template1 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +| 7721 kB | pg_default | default template for new databases
           |          |          |             |             | postgres=CTc/postgres |         |            |
(3 rows)

postgres=# create database test;
CREATE DATABASE
postgres=# \l+
                                                                    List of databases
   Name    |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges   |  Size   | Tablespace |                Description
-----------+----------+----------+-------------+-------------+-----------------------+---------+------------+--------------------------------------------
 postgres  | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |                       | 7855 kB | pg_default | default administrative connection database
 template0 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +| 7721 kB | pg_default | unmodifiable empty database
           |          |          |             |             | postgres=CTc/postgres |         |            |
 template1 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +| 7721 kB | pg_default | default template for new databases
           |          |          |             |             | postgres=CTc/postgres |         |            |
 test      | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |                       | 7721 kB | pg_default |
(4 rows)

postgres=#
```
Паралельно на сервре pg2 проверяем, что база test отреплицировалась:
```
[root@pg2 vagrant]# psql -U postgres -h 192.168.11.121
Password for user postgres:
psql (10.12)
Type "help" for help.

postgres=# \l+
                                                                    List of databases
   Name    |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges   |  Size   | Tablespace |                Description
-----------+----------+----------+-------------+-------------+-----------------------+---------+------------+--------------------------------------------
 postgres  | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |                       | 7855 kB | pg_default | default administrative connection database
 template0 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +| 7721 kB | pg_default | unmodifiable empty database
           |          |          |             |             | postgres=CTc/postgres |         |            |
 template1 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +| 7721 kB | pg_default | default template for new databases
           |          |          |             |             | postgres=CTc/postgres |         |            |
(3 rows)

postgres=# \l+
                                                                    List of databases
   Name    |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges   |  Size   | Tablespace |                Description
-----------+----------+----------+-------------+-------------+-----------------------+---------+------------+--------------------------------------------
 postgres  | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |                       | 7855 kB | pg_default | default administrative connection database
 template0 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +| 7721 kB | pg_default | unmodifiable empty database
           |          |          |             |             | postgres=CTc/postgres |         |            |
 template1 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +| 7721 kB | pg_default | default template for new databases
           |          |          |             |             | postgres=CTc/postgres |         |            |
 test      | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |                       | 7721 kB | pg_default |
(4 rows)
```
#### Switchover
Для тестрования switchover выключаем сервис patroni на мастер ноде, проверям кто мастер и подключившись к нему создаем базу test-switchover:
```
[root@pg3 vagrant]# /usr/local/bin/patronictl -c /etc/patroni/patroni.yml list
+---------+--------+----------------+--------+---------+----+-----------+
| Cluster | Member |      Host      |  Role  |  State  | TL | Lag in MB |
+---------+--------+----------------+--------+---------+----+-----------+
|   otus  |  pg1   | 192.168.11.120 | Leader | running |  1 |           |
|   otus  |  pg2   | 192.168.11.121 |        | running |  1 |         0 |
|   otus  |  pg3   | 192.168.11.122 |        | running |  1 |         0 |
+---------+--------+----------------+--------+---------+----+-----------+
```
```
[root@pg1 vagrant]# systemctl stop patroni.service
```
```
[root@pg3 vagrant]# /usr/local/bin/patronictl -c /etc/patroni/patroni.yml list
+---------+--------+----------------+--------+---------+----+-----------+
| Cluster | Member |      Host      |  Role  |  State  | TL | Lag in MB |
+---------+--------+----------------+--------+---------+----+-----------+
|   otus  |  pg1   | 192.168.11.120 |        | stopped |    |   unknown |
|   otus  |  pg2   | 192.168.11.121 | Leader | running |  2 |           |
|   otus  |  pg3   | 192.168.11.122 |        | running |  2 |         0 |
+---------+--------+----------------+--------+---------+----+-----------+
[root@pg3 vagrant]# pgs
bash: pgs: command not found
[root@pg3 vagrant]#
[root@pg3 vagrant]# psql -U postgres -h 192.168.11.121
Password for user postgres:
psql (10.12)
Type "help" for help.

postgres=# \l+
                                                                    List of databases
   Name    |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges   |  Size   | Tablespace |                Description
-----------+----------+----------+-------------+-------------+-----------------------+---------+------------+--------------------------------------------
 postgres  | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |                       | 7855 kB | pg_default | default administrative connection database
 template0 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +| 7721 kB | pg_default | unmodifiable empty database
           |          |          |             |             | postgres=CTc/postgres |         |            |
 template1 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +| 7721 kB | pg_default | default template for new databases
           |          |          |             |             | postgres=CTc/postgres |         |            |
 test      | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |                       | 7721 kB | pg_default |
(4 rows)

postgres=# create database test_switchover;
CREATE DATABASE
postgres=# \l+
                                                                       List of databases
      Name       |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges   |  Size   | Tablespace |                Description
-----------------+----------+----------+-------------+-------------+-----------------------+---------+------------+--------------------------------------------
 postgres        | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |                       | 7855 kB | pg_default | default administrative connection database
 template0       | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +| 7721 kB | pg_default | unmodifiable empty database
                 |          |          |             |             | postgres=CTc/postgres |         |            |
 template1       | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +| 7721 kB | pg_default | default template for new databases
                 |          |          |             |             | postgres=CTc/postgres |         |            |
 test            | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |                       | 7721 kB | pg_default |
 test_switchover | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |                       | 7721 kB | pg_default |
(5 rows)

postgres=#
```
Логи переключения на трех нодах
```
Apr 01 20:29:43 pg1 patroni[7381]: [patroni] 2020-04-01 20:29:43,620 INFO: Lock owner: pg1; I am pg1
Apr 01 20:29:43 pg1 patroni[7381]: [patroni] 2020-04-01 20:29:43,626 INFO: no action.  i am the leader with the lock
Apr 01 20:29:50 pg1 systemd[1]: Stopping Runners to orchestrate a high-availability PostgreSQL...
Apr 01 20:29:51 pg1 patroni[7381]: [patroni] 2020-04-01 20:29:51,906 INFO: Lock owner: pg1; I am pg1
Apr 01 20:29:52 pg1 systemd[1]: Stopped Runners to orchestrate a high-availability PostgreSQL.
```
```
Apr 01 20:29:44 pg2 patroni[7379]: [patroni] 2020-04-01 20:29:44,989 INFO: Lock owner: pg1; I am pg2
Apr 01 20:29:44 pg2 patroni[7379]: [patroni] 2020-04-01 20:29:44,990 INFO: does not have lock
Apr 01 20:29:45 pg2 patroni[7379]: [patroni] 2020-04-01 20:29:45,005 INFO: no action.  i am a secondary and i am following a leader
Apr 01 20:29:51 pg2 patroni[7379]: [patroni] 2020-04-01 20:29:51,974 INFO: Got response from pg3 http://192.168.11.122:8008/patroni: {"state": "running", "postmaster_start_time": "2020-03-31 20:41:53.212 UTC", "role": "replica", "server_version": 100012, "cluster_unlocked": true, "xlog": {"received_location": 83886232, "replayed_location": 83886232, "replayed_timestamp": "2020-04-01 20:23:48.755 UTC", "paused": false}, "timeline": 1, "database_system_identifier": "6810475096960646383", "patroni": {"version": "1.6.4", "scope": "otus"}}
Apr 01 20:29:51 pg2 patroni[7379]: [patroni] 2020-04-01 20:29:51,982 WARNING: Request failed to pg1: GET http://192.168.11.120:8008/patroni (HTTPConnectionPool(host='192.168.11.120', port=8008): Max retries exceeded with url: /patroni (Caused by ProtocolError('Connection aborted.', ConnectionResetError(104, 'Connection reset by peer'))))
Apr 01 20:29:52 pg2 patroni[7379]: [patroni] 2020-04-01 20:29:52,097 INFO: promoted self to leader by acquiring session lock
Apr 01 20:29:52 pg2 patroni[7379]: server promoting
Apr 01 20:29:52 pg2 patroni[7379]: [patroni] 2020-04-01 20:29:52,144 INFO: cleared rewind state after becoming the leader
Apr 01 20:29:53 pg2 patroni[7379]: [patroni] 2020-04-01 20:29:53,175 INFO: Lock owner: pg2; I am pg2
Apr 01 20:29:53 pg2 patroni[7379]: [patroni] 2020-04-01 20:29:53,261 INFO: no action.  i am the leader with the lock
Apr 01 20:30:03 pg2 patroni[7379]: [patroni] 2020-04-01 20:30:03,174 INFO: Lock owner: pg2; I am pg2
Apr 01 20:30:03 pg2 patroni[7379]: [patroni] 2020-04-01 20:30:03,204 INFO: no action.  i am the leader with the lock
```
```
Apr 01 20:29:44 pg3 patroni[7378]: [patroni] 2020-04-01 20:29:44,378 INFO: Lock owner: pg1; I am pg3
Apr 01 20:29:44 pg3 patroni[7378]: [patroni] 2020-04-01 20:29:44,378 INFO: does not have lock
Apr 01 20:29:44 pg3 patroni[7378]: [patroni] 2020-04-01 20:29:44,390 INFO: no action.  i am a secondary and i am following a leader
Apr 01 20:29:51 pg3 patroni[7378]: [patroni] 2020-04-01 20:29:51,974 WARNING: Request failed to pg1: GET http://192.168.11.120:8008/patroni (HTTPConnectionPool(host='192.168.11.120', port=8008): Max retries exceeded with url: /patroni (Caused by ProtocolError('Connection aborted.', ConnectionResetError(104, 'Connection reset by peer'))))
Apr 01 20:29:51 pg3 patroni[7378]: [patroni] 2020-04-01 20:29:51,987 INFO: Got response from pg2 http://192.168.11.121:8008/patroni: {"state": "running", "postmaster_start_time": "2020-03-31 20:41:53.849 UTC", "role": "replica", "server_version": 100012, "cluster_unlocked": true, "xlog": {"received_location": 83886232, "replayed_location": 83886232, "replayed_timestamp": "2020-04-01 20:23:48.755 UTC", "paused": false}, "timeline": 1, "database_system_identifier": "6810475096960646383", "patroni": {"version": "1.6.4", "scope": "otus"}}
Apr 01 20:29:52 pg3 patroni[7378]: [patroni] 2020-04-01 20:29:52,065 INFO: Could not take out TTL lock
Apr 01 20:29:52 pg3 patroni[7378]: [patroni] 2020-04-01 20:29:52,094 INFO: following new leader after trying and failing to obtain lock
Apr 01 20:29:57 pg3 patroni[7378]: [postgres] 2020-04-01 20:29:57.905 UTC  2020-04-01 20:29:57 UTC   0 00000: LOG:  listening on IPv4 address "192.168.11.122", port 5432
Apr 01 20:29:57 pg3 patroni[7378]: [postgres] 2020-04-01 20:29:57.913 UTC  2020-04-01 20:29:57 UTC   0 00000: LOG:  listening on Unix socket "./.s.PGSQL.5432"
Apr 01 20:29:57 pg3 patroni[7378]: [patroni] 2020-04-01 20:29:57,912 INFO: postmaster pid=3391
Apr 01 20:29:57 pg3 patroni[7378]: [postgres] 2020-04-01 20:29:57.942 UTC  2020-04-01 20:29:57 UTC   0 00000: LOG:  redirecting log output to logging collector process
Apr 01 20:29:57 pg3 patroni[7378]: [postgres] 2020-04-01 20:29:57.942 UTC  2020-04-01 20:29:57 UTC   0 00000: HINT:  Future log output will appear in directory "log".
Apr 01 20:29:57 pg3 patroni[7378]: 192.168.11.122:5432 - rejecting connections
Apr 01 20:29:57 pg3 patroni[7378]: 192.168.11.122:5432 - accepting connections
Apr 01 20:29:57 pg3 patroni[7378]: [patroni] 2020-04-01 20:29:57,996 INFO: Lock owner: pg2; I am pg3
Apr 01 20:29:58 pg3 patroni[7378]: [patroni] 2020-04-01 20:29:57,996 INFO: does not have lock
Apr 01 20:29:58 pg3 patroni[7378]: [patroni] 2020-04-01 20:29:57,997 INFO: establishing a new patroni connection to the postgres cluster
Apr 01 20:29:58 pg3 patroni[7378]: [patroni] 2020-04-01 20:29:58,068 INFO: no action.  i am a secondary and i am following a leader
Apr 01 20:30:08 pg3 patroni[7378]: [patroni] 2020-04-01 20:30:08,155 INFO: Lock owner: pg2; I am pg3
Apr 01 20:30:08 pg3 patroni[7378]: [patroni] 2020-04-01 20:30:08,156 INFO: does not have lock
Apr 01 20:30:08 pg3 patroni[7378]: [patroni] 2020-04-01 20:30:08,191 INFO: no action.  i am a secondary and i am following a leader
```

#### Failover
После возвращения выключенной ранее мастерноды в кластер производим ручной failover
```
[root@pg2 vagrant]# /usr/local/bin/patronictl -c /etc/patroni/patroni.yml list
+---------+--------+----------------+--------+---------+----+-----------+
| Cluster | Member |      Host      |  Role  |  State  | TL | Lag in MB |
+---------+--------+----------------+--------+---------+----+-----------+
|   otus  |  pg1   | 192.168.11.120 |        | running |  2 |         0 |
|   otus  |  pg2   | 192.168.11.121 | Leader | running |  2 |           |
|   otus  |  pg3   | 192.168.11.122 |        | running |  2 |         0 |
+---------+--------+----------------+--------+---------+----+-----------+
[root@pg2 vagrant]# /usr/local/bin/patronictl -c /etc/patroni/patroni.yml failover
Candidate ['pg1', 'pg3'] []: pg3
Current cluster topology
+---------+--------+----------------+--------+---------+----+-----------+
| Cluster | Member |      Host      |  Role  |  State  | TL | Lag in MB |
+---------+--------+----------------+--------+---------+----+-----------+
|   otus  |  pg1   | 192.168.11.120 |        | running |  2 |         0 |
|   otus  |  pg2   | 192.168.11.121 | Leader | running |  2 |           |
|   otus  |  pg3   | 192.168.11.122 |        | running |  2 |         0 |
+---------+--------+----------------+--------+---------+----+-----------+
Are you sure you want to failover cluster otus, demoting current master pg2? [y/N]: y
2020-04-01 20:37:19.93564 Successfully failed over to "pg3"
+---------+--------+----------------+--------+---------+----+-----------+
| Cluster | Member |      Host      |  Role  |  State  | TL | Lag in MB |
+---------+--------+----------------+--------+---------+----+-----------+
|   otus  |  pg1   | 192.168.11.120 |        | running |  2 |         0 |
|   otus  |  pg2   | 192.168.11.121 |        | stopped |    |   unknown |
|   otus  |  pg3   | 192.168.11.122 | Leader | running |  2 |           |
+---------+--------+----------------+--------+---------+----+-----------+
[root@pg2 vagrant]#
[root@pg2 vagrant]#
[root@pg2 vagrant]# /usr/local/bin/patronictl -c /etc/patroni/patroni.yml list
+---------+--------+----------------+--------+---------+----+-----------+
| Cluster | Member |      Host      |  Role  |  State  | TL | Lag in MB |
+---------+--------+----------------+--------+---------+----+-----------+
|   otus  |  pg1   | 192.168.11.120 |        | running |  2 |         0 |
|   otus  |  pg2   | 192.168.11.121 |        | running |  3 |         0 |
|   otus  |  pg3   | 192.168.11.122 | Leader | running |  3 |           |
+---------+--------+----------------+--------+---------+----+-----------+
```
Логи переключения на трех нодах
```
Apr 01 20:37:18 pg1 patroni[605]: [patroni] 2020-04-01 20:37:18,362 INFO: Lock owner: pg2; I am pg1
Apr 01 20:37:18 pg1 patroni[605]: [patroni] 2020-04-01 20:37:18,363 INFO: does not have lock
Apr 01 20:37:18 pg1 patroni[605]: [patroni] 2020-04-01 20:37:18,377 INFO: no action.  i am a secondary and i am following a leader
Apr 01 20:37:19 pg1 patroni[605]: [patroni] 2020-04-01 20:37:19,908 INFO: Got response from pg3 http://192.168.11.122:8008/patroni: {"state": "running", "postmaster_start_time": "2020-04-01 20:29:57.945 UTC", "role": "replica", "server_version": 100012, "cluster_unlocked": true, "xlog": {"received_location": 100663448, "replayed_location": 100663448, "replayed_timestamp": "2020-04-01 20:31:45.041 UTC", "paused": false}, "timeline": 2, "database_system_identifier": "6810475096960646383", "patroni": {"version": "1.6.4", "scope": "otus"}}
Apr 01 20:37:19 pg1 patroni[605]: [patroni] 2020-04-01 20:37:19,908 INFO: manual failover: to pg3, i am pg1
Apr 01 20:37:21 pg1 patroni[605]: [patroni] 2020-04-01 20:37:21,955 INFO: Local timeline=2 lsn=0/6000098
Apr 01 20:37:21 pg1 patroni[605]: [patroni] 2020-04-01 20:37:21,972 INFO: master_timeline=3
Apr 01 20:37:21 pg1 patroni[605]: [patroni] 2020-04-01 20:37:21,974 INFO: master: history=1        0/5000098        no recovery target specified
Apr 01 20:37:21 pg1 patroni[605]: 2        0/6000098        no recovery target specified
Apr 01 20:37:22 pg1 patroni[605]: [patroni] 2020-04-01 20:37:22,024 INFO: running pg_rewind from pg3
Apr 01 20:37:27 pg1 patroni[605]: [patroni] 2020-04-01 20:37:27,162 INFO: running pg_rewind from dbname=postgres user=postgres host=192.168.11.122 port=5432
Apr 01 20:37:27 pg1 patroni[605]: servers diverged at WAL location 0/6000098 on timeline 2
Apr 01 20:37:27 pg1 patroni[605]: no rewind required
Apr 01 20:37:27 pg1 patroni[605]: [patroni] 2020-04-01 20:37:27,222 WARNING: Postgresql is not running.
Apr 01 20:37:27 pg1 patroni[605]: [patroni] 2020-04-01 20:37:27,223 INFO: Lock owner: pg3; I am pg1
Apr 01 20:37:27 pg1 patroni[605]: [patroni] 2020-04-01 20:37:27,231 INFO: pg_controldata:
Apr 01 20:37:27 pg1 patroni[605]: pg_control version number: 1002
Apr 01 20:37:27 pg1 patroni[605]: Catalog version number: 201707211
Apr 01 20:37:27 pg1 patroni[605]: Database system identifier: 6810475096960646383
Apr 01 20:37:27 pg1 patroni[605]: Database cluster state: shut down in recovery
Apr 01 20:37:27 pg1 patroni[605]: pg_control last modified: Wed Apr  1 20:37:27 2020
Apr 01 20:37:27 pg1 patroni[605]: Latest checkpoint location: 0/6000028
Apr 01 20:37:27 pg1 patroni[605]: Prior checkpoint location: 0/5000028
Apr 01 20:37:27 pg1 patroni[605]: Latest checkpoint's REDO location: 0/6000028
Apr 01 20:37:27 pg1 patroni[605]: Latest checkpoint's REDO WAL file: 000000020000000000000006
Apr 01 20:37:27 pg1 patroni[605]: Latest checkpoint's TimeLineID: 2
Apr 01 20:37:27 pg1 patroni[605]: Latest checkpoint's PrevTimeLineID: 2
Apr 01 20:37:27 pg1 patroni[605]: Latest checkpoint's full_page_writes: on
Apr 01 20:37:27 pg1 patroni[605]: Latest checkpoint's NextXID: 0:566
Apr 01 20:37:27 pg1 patroni[605]: Latest checkpoint's NextOID: 16390
Apr 01 20:37:27 pg1 patroni[605]: Latest checkpoint's NextMultiXactId: 1
Apr 01 20:37:27 pg1 patroni[605]: Latest checkpoint's NextMultiOffset: 0
Apr 01 20:37:27 pg1 patroni[605]: Latest checkpoint's oldestXID: 549
Apr 01 20:37:27 pg1 patroni[605]: Latest checkpoint's oldestXID's DB: 1
Apr 01 20:37:27 pg1 patroni[605]: Latest checkpoint's oldestActiveXID: 0
Apr 01 20:37:27 pg1 patroni[605]: Latest checkpoint's oldestMultiXid: 1
Apr 01 20:37:27 pg1 patroni[605]: Latest checkpoint's oldestMulti's DB: 1
Apr 01 20:37:27 pg1 patroni[605]: Latest checkpoint's oldestCommitTsXid: 0
Apr 01 20:37:27 pg1 patroni[605]: Latest checkpoint's newestCommitTsXid: 0
Apr 01 20:37:27 pg1 patroni[605]: Time of latest checkpoint: Wed Apr  1 20:37:19 2020
Apr 01 20:37:27 pg1 patroni[605]: Fake LSN counter for unlogged rels: 0/1
Apr 01 20:37:27 pg1 patroni[605]: Minimum recovery ending location: 0/6000098
Apr 01 20:37:27 pg1 patroni[605]: Min recovery ending loc's timeline: 2
Apr 01 20:37:27 pg1 patroni[605]: Backup start location: 0/0
Apr 01 20:37:27 pg1 patroni[605]: Backup end location: 0/0
Apr 01 20:37:27 pg1 patroni[605]: End-of-backup record required: no
Apr 01 20:37:27 pg1 patroni[605]: wal_level setting: replica
Apr 01 20:37:27 pg1 patroni[605]: wal_log_hints setting: on
Apr 01 20:37:27 pg1 patroni[605]: max_connections setting: 100
Apr 01 20:37:27 pg1 patroni[605]: max_worker_processes setting: 8
Apr 01 20:37:27 pg1 patroni[605]: max_prepared_xacts setting: 0
Apr 01 20:37:27 pg1 patroni[605]: max_locks_per_xact setting: 64
Apr 01 20:37:27 pg1 patroni[605]: track_commit_timestamp setting: off
Apr 01 20:37:27 pg1 patroni[605]: Maximum data alignment: 8
Apr 01 20:37:27 pg1 patroni[605]: Database block size: 8192
Apr 01 20:37:27 pg1 patroni[605]: Blocks per segment of large relation: 131072
Apr 01 20:37:27 pg1 patroni[605]: WAL block size: 8192
Apr 01 20:37:27 pg1 patroni[605]: Bytes per WAL segment: 16777216
Apr 01 20:37:27 pg1 patroni[605]: Maximum length of identifiers: 64
Apr 01 20:37:27 pg1 patroni[605]: Maximum columns in an index: 32
Apr 01 20:37:27 pg1 patroni[605]: Maximum size of a TOAST chunk: 1996
Apr 01 20:37:27 pg1 patroni[605]: Size of a large-object chunk: 2048
Apr 01 20:37:27 pg1 patroni[605]: Date/time type storage: 64-bit integers
Apr 01 20:37:27 pg1 patroni[605]: Float4 argument passing: by value
Apr 01 20:37:27 pg1 patroni[605]: Float8 argument passing: by value
Apr 01 20:37:27 pg1 patroni[605]: Data page checksum version: 1
Apr 01 20:37:27 pg1 patroni[605]: Mock authentication nonce: 219e38c99a0e6b51811f6c163740ccf17c965b8f2c3db07d3a7782c41e526dfd
Apr 01 20:37:27 pg1 patroni[605]: [patroni] 2020-04-01 20:37:27,242 INFO: Lock owner: pg3; I am pg1
Apr 01 20:37:27 pg1 patroni[605]: [patroni] 2020-04-01 20:37:27,243 INFO: Lock owner: pg3; I am pg1
Apr 01 20:37:27 pg1 patroni[605]: [patroni] 2020-04-01 20:37:27,283 INFO: starting as a secondary
Apr 01 20:37:27 pg1 patroni[605]: [patroni] 2020-04-01 20:37:27,288 INFO: closed patroni connection to the postgresql cluster
Apr 01 20:37:27 pg1 patroni[605]: [postgres] 2020-04-01 20:37:27.842 UTC  2020-04-01 20:37:27 UTC   0 00000: LOG:  listening on IPv4 address "192.168.11.120", port 5432
Apr 01 20:37:27 pg1 patroni[605]: [postgres] 2020-04-01 20:37:27.862 UTC  2020-04-01 20:37:27 UTC   0 00000: LOG:  listening on Unix socket "./.s.PGSQL.5432"
Apr 01 20:37:27 pg1 patroni[605]: [patroni] 2020-04-01 20:37:27,856 INFO: postmaster pid=725
Apr 01 20:37:27 pg1 patroni[605]: [postgres] 2020-04-01 20:37:27.892 UTC  2020-04-01 20:37:27 UTC   0 00000: LOG:  redirecting log output to logging collector process
Apr 01 20:37:27 pg1 patroni[605]: [postgres] 2020-04-01 20:37:27.892 UTC  2020-04-01 20:37:27 UTC   0 00000: HINT:  Future log output will appear in directory "log".
Apr 01 20:37:27 pg1 patroni[605]: 192.168.11.120:5432 - rejecting connections
Apr 01 20:37:27 pg1 patroni[605]: 192.168.11.120:5432 - accepting connections
Apr 01 20:37:27 pg1 patroni[605]: [patroni] 2020-04-01 20:37:27,948 INFO: Lock owner: pg3; I am pg1
Apr 01 20:37:27 pg1 patroni[605]: [patroni] 2020-04-01 20:37:27,948 INFO: does not have lock
Apr 01 20:37:27 pg1 patroni[605]: [patroni] 2020-04-01 20:37:27,948 INFO: establishing a new patroni connection to the postgres cluster
Apr 01 20:37:28 pg1 patroni[605]: [patroni] 2020-04-01 20:37:28,022 INFO: no action.  i am a secondary and i am following a leader
Apr 01 20:37:38 pg1 patroni[605]: [patroni] 2020-04-01 20:37:38,211 INFO: Lock owner: pg3; I am pg1
Apr 01 20:37:38 pg1 patroni[605]: [patroni] 2020-04-01 20:37:38,211 INFO: does not have lock
Apr 01 20:37:38 pg1 patroni[605]: [patroni] 2020-04-01 20:37:38,261 INFO: no action.  i am a secondary and i am following a leader
```
```
Apr 01 20:37:13 pg2 patroni[7379]: [patroni] 2020-04-01 20:37:13,173 INFO: Lock owner: pg2; I am pg2
Apr 01 20:37:13 pg2 patroni[7379]: [patroni] 2020-04-01 20:37:13,178 INFO: no action.  i am the leader with the lock
Apr 01 20:37:18 pg2 patroni[7379]: [patroni] 2020-04-01 20:37:18,720 INFO: received failover request with leader=pg2 candidate=pg3 scheduled_at=None
Apr 01 20:37:18 pg2 patroni[7379]: [patroni] 2020-04-01 20:37:18,741 INFO: Got response from pg3 http://192.168.11.122:8008/patroni: {"state": "running", "postmaster_start_time": "2020-04-01 20:29:57.945 UTC", "role": "replica", "server_version": 100012, "cluster_unlocked": false, "xlog": {"received_location": 83892400, "replayed_location": 83892400, "replayed_timestamp": "2020-04-01 20:31:45.041 UTC", "paused": false}, "timeline": 2, "database_system_identifier": "6810475096960646383", "patroni": {"version": "1.6.4", "scope": "otus"}}
Apr 01 20:37:18 pg2 patroni[7379]: [patroni] 2020-04-01 20:37:18,853 INFO: Lock owner: pg2; I am pg2
Apr 01 20:37:18 pg2 patroni[7379]: [patroni] 2020-04-01 20:37:18,871 INFO: Got response from pg3 http://192.168.11.122:8008/patroni: {"state": "running", "postmaster_start_time": "2020-04-01 20:29:57.945 UTC", "role": "replica", "server_version": 100012, "cluster_unlocked": false, "xlog": {"received_location": 83892400, "replayed_location": 83892400, "replayed_timestamp": "2020-04-01 20:31:45.041 UTC", "paused": false}, "timeline": 2, "database_system_identifier": "6810475096960646383", "patroni": {"version": "1.6.4", "scope": "otus"}}
Apr 01 20:37:18 pg2 patroni[7379]: [patroni] 2020-04-01 20:37:18,976 INFO: manual failover: demoting myself
Apr 01 20:37:19 pg2 patroni[7379]: [patroni] 2020-04-01 20:37:19,914 INFO: Leader key released
Apr 01 20:37:21 pg2 patroni[7379]: [patroni] 2020-04-01 20:37:21,939 INFO: Local timeline=2 lsn=0/6000028
Apr 01 20:37:21 pg2 patroni[7379]: [patroni] 2020-04-01 20:37:21,957 INFO: master_timeline=3
Apr 01 20:37:21 pg2 patroni[7379]: [patroni] 2020-04-01 20:37:21,960 INFO: master: history=1        0/5000098        no recovery target specified
Apr 01 20:37:21 pg2 patroni[7379]: 2        0/6000098        no recovery target specified
Apr 01 20:37:21 pg2 patroni[7379]: [patroni] 2020-04-01 20:37:21,966 INFO: closed patroni connection to the postgresql cluster
Apr 01 20:37:22 pg2 patroni[7379]: [postgres] 2020-04-01 20:37:22.463 UTC  2020-04-01 20:37:22 UTC   0 00000: LOG:  listening on IPv4 address "192.168.11.121", port 5432
Apr 01 20:37:22 pg2 patroni[7379]: [postgres] 2020-04-01 20:37:22.476 UTC  2020-04-01 20:37:22 UTC   0 00000: LOG:  listening on Unix socket "./.s.PGSQL.5432"
Apr 01 20:37:22 pg2 patroni[7379]: [patroni] 2020-04-01 20:37:22,477 INFO: postmaster pid=3628
Apr 01 20:37:22 pg2 patroni[7379]: [postgres] 2020-04-01 20:37:22.520 UTC  2020-04-01 20:37:22 UTC   0 00000: LOG:  redirecting log output to logging collector process
Apr 01 20:37:22 pg2 patroni[7379]: [postgres] 2020-04-01 20:37:22.520 UTC  2020-04-01 20:37:22 UTC   0 00000: HINT:  Future log output will appear in directory "log".
Apr 01 20:37:22 pg2 patroni[7379]: 192.168.11.121:5432 - rejecting connections
Apr 01 20:37:22 pg2 patroni[7379]: 192.168.11.121:5432 - accepting connections
Apr 01 20:37:28 pg2 patroni[7379]: [patroni] 2020-04-01 20:37:28,858 INFO: Lock owner: pg3; I am pg2
Apr 01 20:37:28 pg2 patroni[7379]: [patroni] 2020-04-01 20:37:28,859 INFO: does not have lock
Apr 01 20:37:28 pg2 patroni[7379]: [patroni] 2020-04-01 20:37:28,859 INFO: establishing a new patroni connection to the postgres cluster
Apr 01 20:37:28 pg2 patroni[7379]: [patroni] 2020-04-01 20:37:28,901 INFO: no action.  i am a secondary and i am following a leader
```
```
Apr 01 20:37:18 pg3 patroni[7378]: [patroni] 2020-04-01 20:37:18,182 INFO: Lock owner: pg2; I am pg3
Apr 01 20:37:18 pg3 patroni[7378]: [patroni] 2020-04-01 20:37:18,183 INFO: does not have lock
Apr 01 20:37:18 pg3 patroni[7378]: [patroni] 2020-04-01 20:37:18,198 INFO: no action.  i am a secondary and i am following a leader
Apr 01 20:37:19 pg3 patroni[7378]: [patroni] 2020-04-01 20:37:19,910 INFO: Cleaning up failover key after acquiring leader lock...
Apr 01 20:37:19 pg3 patroni[7378]: [patroni] 2020-04-01 20:37:19,958 INFO: promoted self to leader by acquiring session lock
Apr 01 20:37:19 pg3 patroni[7378]: server promoting
Apr 01 20:37:19 pg3 patroni[7378]: [patroni] 2020-04-01 20:37:19,971 INFO: cleared rewind state after becoming the leader
Apr 01 20:37:21 pg3 patroni[7378]: [patroni] 2020-04-01 20:37:21,002 INFO: Lock owner: pg3; I am pg3
Apr 01 20:37:21 pg3 patroni[7378]: [patroni] 2020-04-01 20:37:21,101 INFO: no action.  i am the leader with the lock
```

#### Изменение конфигурации PostgreSQL
Изменяем максимально разрешенное количество соединений к базе с 100 до 150:
```
[root@pg2 vagrant]# /usr/local/bin/patronictl -c /etc/patroni/patroni.yml list
+---------+--------+----------------+--------+---------+----+-----------+
| Cluster | Member |      Host      |  Role  |  State  | TL | Lag in MB |
+---------+--------+----------------+--------+---------+----+-----------+
|   otus  |  pg1   | 192.168.11.120 |        | running |  2 |         0 |
|   otus  |  pg2   | 192.168.11.121 |        | running |  3 |         0 |
|   otus  |  pg3   | 192.168.11.122 | Leader | running |  3 |           |
+---------+--------+----------------+--------+---------+----+-----------+
[root@pg2 vagrant]#
[root@pg2 vagrant]# /usr/local/bin/patronictl -c /etc/patroni/patroni.yml edit-config
---
+++
@@ -7,7 +7,7 @@
       archive-push -B /var/backup --instance dbdc2 --wal-file-path=%p --wal-file-name=%f
       --remote-host=10.23.1.185
     archive_mode: 'on'
-    max_connections: 100
+    max_connections: 150
     max_parallel_workers: 8
     max_wal_senders: 5
     max_wal_size: 2GB

Apply these changes? [y/N]: y
Configuration changed
[root@pg2 vagrant]# /usr/local/bin/patronictl -c /etc/patroni/patroni.yml list
+---------+--------+----------------+--------+---------+----+-----------+
| Cluster | Member |      Host      |  Role  |  State  | TL | Lag in MB |
+---------+--------+----------------+--------+---------+----+-----------+
|   otus  |  pg1   | 192.168.11.120 |        | running |  3 |         0 |
|   otus  |  pg2   | 192.168.11.121 |        | running |  3 |         0 |
|   otus  |  pg3   | 192.168.11.122 | Leader | running |  3 |           |
+---------+--------+----------------+--------+---------+----+-----------+
[root@pg2 vagrant]# /usr/local/bin/patronictl -c /etc/patroni/patroni.yml list
+---------+--------+----------------+--------+---------+----+-----------+-----------------+
| Cluster | Member |      Host      |  Role  |  State  | TL | Lag in MB | Pending restart |
+---------+--------+----------------+--------+---------+----+-----------+-----------------+
|   otus  |  pg1   | 192.168.11.120 |        | running |  3 |         0 |        *        |
|   otus  |  pg2   | 192.168.11.121 |        | running |  3 |         0 |        *        |
|   otus  |  pg3   | 192.168.11.122 | Leader | running |  3 |           |        *        |
+---------+--------+----------------+--------+---------+----+-----------+-----------------+
[root@pg2 vagrant]# /usr/local/bin/patronictl -c /etc/patroni/patroni.yml restart pg1
Error: pg1 cluster doesn't have any members
[root@pg2 vagrant]# /usr/local/bin/patronictl -c /etc/patroni/patroni.yml restart otus pg1
+---------+--------+----------------+--------+---------+----+-----------+-----------------+
| Cluster | Member |      Host      |  Role  |  State  | TL | Lag in MB | Pending restart |
+---------+--------+----------------+--------+---------+----+-----------+-----------------+
|   otus  |  pg1   | 192.168.11.120 |        | running |  3 |         0 |        *        |
|   otus  |  pg2   | 192.168.11.121 |        | running |  3 |         0 |        *        |
|   otus  |  pg3   | 192.168.11.122 | Leader | running |  3 |           |        *        |
+---------+--------+----------------+--------+---------+----+-----------+-----------------+
When should the restart take place (e.g. 2020-04-01T21:45)  [now]:
Are you sure you want to restart members pg1? [y/N]: y
Restart if the PostgreSQL version is less than provided (e.g. 9.5.2)  []:
Success: restart on member pg1
[root@pg2 vagrant]# /usr/local/bin/patronictl -c /etc/patroni/patroni.yml list
+---------+--------+----------------+--------+---------+----+-----------+-----------------+
| Cluster | Member |      Host      |  Role  |  State  | TL | Lag in MB | Pending restart |
+---------+--------+----------------+--------+---------+----+-----------+-----------------+
|   otus  |  pg1   | 192.168.11.120 |        | running |  3 |         0 |                 |
|   otus  |  pg2   | 192.168.11.121 |        | running |  3 |         0 |        *        |
|   otus  |  pg3   | 192.168.11.122 | Leader | running |  3 |           |        *        |
+---------+--------+----------------+--------+---------+----+-----------+-----------------+
[root@pg2 vagrant]# /usr/local/bin/patronictl -c /etc/patroni/patroni.yml restart otus pg2
+---------+--------+----------------+--------+---------+----+-----------+-----------------+
| Cluster | Member |      Host      |  Role  |  State  | TL | Lag in MB | Pending restart |
+---------+--------+----------------+--------+---------+----+-----------+-----------------+
|   otus  |  pg1   | 192.168.11.120 |        | running |  3 |         0 |                 |
|   otus  |  pg2   | 192.168.11.121 |        | running |  3 |         0 |        *        |
|   otus  |  pg3   | 192.168.11.122 | Leader | running |  3 |           |        *        |
+---------+--------+----------------+--------+---------+----+-----------+-----------------+
When should the restart take place (e.g. 2020-04-01T21:46)  [now]:
Are you sure you want to restart members pg2? [y/N]: y
Restart if the PostgreSQL version is less than provided (e.g. 9.5.2)  []:
Success: restart on member pg2
[root@pg2 vagrant]# /usr/local/bin/patronictl -c /etc/patroni/patroni.yml list
+---------+--------+----------------+--------+---------+----+-----------+-----------------+
| Cluster | Member |      Host      |  Role  |  State  | TL | Lag in MB | Pending restart |
+---------+--------+----------------+--------+---------+----+-----------+-----------------+
|   otus  |  pg1   | 192.168.11.120 |        | running |  3 |         0 |                 |
|   otus  |  pg2   | 192.168.11.121 |        | running |  3 |         0 |                 |
|   otus  |  pg3   | 192.168.11.122 | Leader | running |  3 |           |        *        |
+---------+--------+----------------+--------+---------+----+-----------+-----------------+
[root@pg2 vagrant]# /usr/local/bin/patronictl -c /etc/patroni/patroni.yml restart otus pg3
+---------+--------+----------------+--------+---------+----+-----------+-----------------+
| Cluster | Member |      Host      |  Role  |  State  | TL | Lag in MB | Pending restart |
+---------+--------+----------------+--------+---------+----+-----------+-----------------+
|   otus  |  pg1   | 192.168.11.120 |        | running |  3 |         0 |                 |
|   otus  |  pg2   | 192.168.11.121 |        | running |  3 |         0 |                 |
|   otus  |  pg3   | 192.168.11.122 | Leader | running |  3 |           |        *        |
+---------+--------+----------------+--------+---------+----+-----------+-----------------+
When should the restart take place (e.g. 2020-04-01T21:46)  [now]:
Are you sure you want to restart members pg3? [y/N]: y
Restart if the PostgreSQL version is less than provided (e.g. 9.5.2)  []:
Success: restart on member pg3
[root@pg2 vagrant]# /usr/local/bin/patronictl -c /etc/patroni/patroni.yml list
+---------+--------+----------------+--------+---------+----+-----------+
| Cluster | Member |      Host      |  Role  |  State  | TL | Lag in MB |
+---------+--------+----------------+--------+---------+----+-----------+
|   otus  |  pg1   | 192.168.11.120 |        | running |  3 |         0 |
|   otus  |  pg2   | 192.168.11.121 |        | running |  3 |         0 |
|   otus  |  pg3   | 192.168.11.122 | Leader | running |  3 |           |
+---------+--------+----------------+--------+---------+----+-----------+
```
## Полезная информация

* https://blogs.sungeek.net/unixwiz/2018/09/02/centos-7-postgresql-10-patroni/
* https://github.com/ansible/ansible/issues/61929