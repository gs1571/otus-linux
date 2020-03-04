# MySQL

## Домашнее задание

Стенд разворачивается через [vagrantfile](vagrantfile).

Логи консоли mysql на мастере
```
mysql> select * from bookmaker;
+----+----------------+
| id | bookmaker_name |
+----+----------------+
|  4 | betway         |
|  5 | bwin           |
|  6 | ladbrokes      |
|  3 | unibet         |
+----+----------------+
4 rows in set (0.00 sec)

mysql> insert into bookmaker (id,bookmaker_name) values(1,'1xbet');
Query OK, 1 row affected (0.00 sec)

mysql> select * from bookmaker;
+----+----------------+
| id | bookmaker_name |
+----+----------------+
|  1 | 1xbet          |
|  4 | betway         |
|  5 | bwin           |
|  6 | ladbrokes      |
|  3 | unibet         |
+----+----------------+
5 rows in set (0.00 sec)
```
Логи консоли на слейве:
```
mysql> show slave status\G
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 192.168.11.150
                  Master_User: repl
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: mysql-bin.000002
          Read_Master_Log_Pos: 119864
               Relay_Log_File: slave-relay-bin.000006
                Relay_Log_Pos: 750
        Relay_Master_Log_File: mysql-bin.000002
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
              Replicate_Do_DB:
          Replicate_Ignore_DB:
           Replicate_Do_Table:
       Replicate_Ignore_Table: bet.events_on_demand,bet.v_same_event
      Replicate_Wild_Do_Table:
  Replicate_Wild_Ignore_Table:
                   Last_Errno: 0
                   Last_Error:
                 Skip_Counter: 0
          Exec_Master_Log_Pos: 119864
              Relay_Log_Space: 1257
              Until_Condition: None
               Until_Log_File:
                Until_Log_Pos: 0
           Master_SSL_Allowed: No
           Master_SSL_CA_File:
           Master_SSL_CA_Path:
              Master_SSL_Cert:
            Master_SSL_Cipher:
               Master_SSL_Key:
        Seconds_Behind_Master: 0
Master_SSL_Verify_Server_Cert: No
                Last_IO_Errno: 0
                Last_IO_Error:
               Last_SQL_Errno: 0
               Last_SQL_Error:
  Replicate_Ignore_Server_Ids:
             Master_Server_Id: 1
                  Master_UUID: 69abfb78-5e50-11ea-896a-5254008afee6
             Master_Info_File: /var/lib/mysql/master.info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
      Slave_SQL_Running_State: Slave has read all relay log; waiting for more updates
           Master_Retry_Count: 86400
                  Master_Bind:
      Last_IO_Error_Timestamp:
     Last_SQL_Error_Timestamp:
               Master_SSL_Crl:
           Master_SSL_Crlpath:
           Retrieved_Gtid_Set: 69abfb78-5e50-11ea-896a-5254008afee6:1-40
            Executed_Gtid_Set: 361061c7-5e52-11ea-9d63-5254008afee6:1-3,
69abfb78-5e50-11ea-896a-5254008afee6:1-40
                Auto_Position: 1
         Replicate_Rewrite_DB:
                 Channel_Name:
           Master_TLS_Version:
1 row in set (0.00 sec)

mysql> select * from bookmaker;
+----+----------------+
| id | bookmaker_name |
+----+----------------+
|  1 | 1xbet          |
|  4 | betway         |
|  5 | bwin           |
|  6 | ladbrokes      |
|  3 | unibet         |
+----+----------------+
5 rows in set (0.00 sec)
```
Кусок binlog со слейва:
```
# at 113858
#200304 20:19:05 server id 1  end_log_pos 113923 CRC32 0xab5fdfd7 	GTID	last_committed=40	sequence_number=41	rbr_only=no
SET @@SESSION.GTID_NEXT= '69abfb78-5e50-11ea-896a-5254008afee6:40'/*!*/;
# at 113923
#200304 20:19:05 server id 1  end_log_pos 113996 CRC32 0x1964d764 	Query	thread_id=9	exec_time=0	error_code=0
SET TIMESTAMP=1583353145/*!*/;
BEGIN
/*!*/;
# at 113996
#200304 20:19:05 server id 1  end_log_pos 114123 CRC32 0xc30173fe 	Query	thread_id=9	exec_time=0	error_code=0
SET TIMESTAMP=1583353145/*!*/;
insert into bookmaker (id,bookmaker_name) values(1,'1xbet')
/*!*/;
# at 114123
#200304 20:19:05 server id 1  end_log_pos 114154 CRC32 0xea7ad216 	Xid = 76
COMMIT/*!*/;
SET @@SESSION.GTID_NEXT= 'AUTOMATIC' /* added by mysqlbinlog */ /*!*/;
DELIMITER ;
# End of log file
/*!50003 SET COMPLETION_TYPE=@OLD_COMPLETION_TYPE*/;
/*!50530 SET @@SESSION.PSEUDO_SLAVE_MODE=0*/;
```

## Полезная информация
