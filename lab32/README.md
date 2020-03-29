# PostreSQL

## Домашнее задание

### Описание стенда
Стенд разворачивается через [Vagrantfile](Vagrantfile) в котором при провижиненге последней VM запускается ansible-playbook.
Запускается три машины:
* pg - основной сервер БД
* backup - нода barman
* replica - сервер куда реплицируются данные с основного сервера

В качестве базы загружается демонстрационная база с ресурса - https://postgrespro.ru/education/demodb.

### Проверка стенда

pg:
```
[root@pg vagrant]# su - postgres
-bash-4.2$ psql
psql (10.12)
Type "help" for help.

postgres=# select * from pg_stat_replication;
-[ RECORD 1 ]----+------------------------------
pid              | 7570
usesysid         | 16385
usename          | replica
application_name | walreceiver
client_addr      | 192.168.50.200
client_hostname  |
client_port      | 34076
backend_start    | 2020-03-29 15:23:27.836415+00
backend_xmin     |
state            | streaming
sent_lsn         | 0/12000060
write_lsn        | 0/12000060
flush_lsn        | 0/12000060
replay_lsn       | 0/12000060
write_lag        |
flush_lag        |
replay_lag       |
sync_priority    | 0
sync_state       | async
-[ RECORD 2 ]----+------------------------------
pid              | 7985
usesysid         | 16384
usename          | barman
application_name | barman_receive_wal
client_addr      | 192.168.50.100
client_hostname  |
client_port      | 38568
backend_start    | 2020-03-29 15:25:02.810066+00
backend_xmin     |
state            | streaming
sent_lsn         | 0/12000060
write_lsn        | 0/12000060
flush_lsn        | 0/12000000
replay_lsn       |
write_lag        | 00:00:02.632234
flush_lag        | 00:03:42.841885
replay_lag       | 00:07:11.040153
sync_priority    | 0
sync_state       | async
```
barman:
```
[root@backup vagrant]# su - barman
-bash-4.2$ barman check pg
Server pg:
	PostgreSQL: OK
	is_superuser: OK
	PostgreSQL streaming: OK
	wal_level: OK
	replication slot: OK
	directories: OK
	retention policy settings: OK
	backup maximum age: OK (no last_backup_maximum_age provided)
	compression settings: OK
	failed backups: OK (there are 0 failed backups)
	minimum redundancy requirements: OK (have 0 backups, expected at least 0)
	pg_basebackup: OK
	pg_basebackup compatible: OK
	pg_basebackup supports tablespaces mapping: OK
	systemid coherence: OK (no system Id stored on disk)
	pg_receivexlog: OK
	pg_receivexlog compatible: OK
	receive-wal running: OK
	archive_mode: OK
	archive_command: OK
	archiver errors: OK
```

## Полезная информация

# Демо БД
* https://postgrespro.ru/education/demodb

# Установка
* https://www.digitalocean.com/community/tutorials/how-to-install-and-use-postgresql-on-centos-7

# Репликация БД
* https://the-bosha.ru/2016/06/01/backup-restore-postgresql-bazy-dannykh-s-pg_dump/
* https://nixman.info/?p=2828
* https://romantelychko.com/blog/1583/

# Barman
* http://docs.pgbarman.org/release/2.10/  
* https://medium.com/coderbunker/implement-backup-with-barman-bb0b44af71f9
