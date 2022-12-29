[Playbooks](../../../../README.md) > [Data](../../../README.md) >
[Databases](../../README.md) > [MySQL](../../README.md) > Excessive storage

# Excessive storage usage playbook   

Typically, disk space will be exhausted for one of the following reasons.   
1. Transaction/Redo logs are not being truncated/reused
2. Large data manipulation (insert/update/delete) has happened, and space was not appropriately allocated
3. Large temporary disk space usage (bad queries, db maintenance, etc)
4. Internal database issue (more rare)

## Playbook



### Identify the problem

- [ ] Identify the type of data taking up an unexpected amount of space
    - [ ] If GCP, view `disk/bytes_used_by_data_type` metric type in [System Insights](https://cloud.google.com/sql/docs/postgres/use-system-insights#metrics-pg) or `database/disk/bytes_used_by_data_type` in [Cloud Monitoring Metrics Explorer](https://cloud.google.com/monitoring/charts/metrics-explorer)
      - [ ] 1. `Data`
      - [ ] 2. `Redo log`
      - [ ] 3. `Binary log`
      - [ ] `Relaylog` `TODO`
      - [ ] `Cloudsql_mysql_audit_log` `TODO`
      - [ ] `General log` `TODO`
      - [ ] `Slow Query Log` `TODO`    
      - [ ] `Tmp_data` `TODO`
      - [ ] `Other` `TODO`
    - [ ] If AWS, `TODO`\
    - [ ] If self-hosted (**best effort**)



## 1. MySQL Data

You can identify the underlying disk-space used by the MySQL schemas in an instance with the query:

### List Schemas by size
```
SELECT   table_schema,
         ROUND(SUM(data_length+index_length)/1024/1024,0) AS total_mb,
         ROUND(SUM(data_length)/1024/1024,0) AS data_mb,
         ROUND(SUM(index_length)/1024/1024,0) AS index_mb,
         COUNT(*) AS tables,
         CURDATE() AS today
FROM     information_schema.tables
WHERE    table_schema NOT IN ('mysql','information_schema','performance_schema','sys','_statpack_mysql')
GROUP BY table_schema
ORDER BY 2 DESC;
```
Original Source: https://gist.github.com/ronaldbradford/daf1a53e25feff5e2b6e81b46d6fc276

### Example Output

```
+--------------+----------+---------+----------+--------+------------+
| TABLE_SCHEMA | total_mb | data_mb | index_mb | tables | today      |
+--------------+----------+---------+----------+--------+------------+
| imdb         |    11368 |    7351 |     4017 |      5 | 2022-12-29 |
| airportdb    |     7531 |    2395 |     5136 |     15 | 2022-12-29 |
| postcodes    |      625 |     372 |      253 |      2 | 2022-12-29 |
| employees    |      163 |     158 |        6 |      8 | 2022-12-29 |
| sakila       |        6 |       4 |        2 |     23 | 2022-12-29 |
| world        |        1 |       1 |        0 |      3 | 2022-12-29 |
| menagerie    |        0 |       0 |        0 |      2 | 2022-12-29 |
+--------------+----------+---------+----------+--------+------------+
7 rows in set (0.06 sec)
```

Historically, MySQL INFORMATION_SCHEMA.TABLES (data_length and index_length) have been rather accurate figures.

A note from Google in #99164](https://doitintl.zendesk.com/agent/tickets/99164) <i>The Cloud SQL product team do not recommend data_length: “Usage stats fetched from the data_length and index_length columns of information_schema.tables can be out-of-sync as MySQL periodically refreshes the data at irregular intervals based on how often InnoDB statistics are updated. Fetching similar stats from information_schema.innodb_sys_tablespaces table is more reliable.”</i>

This may be attributed to a new variable in MySQL 8.0 [information_schema_stats_expiry](https://dev.mysql.com/doc/refman/8.0/en/server-system-variables.html#sysvar_information_schema_stats_expiry) which will by default calculate these columns on a per day basis (reported in seconds).
```
SHOW GLOBAL VARIABLES LIKE 'information_schema_stats_expiry';
+---------------------------------+-------+
| Variable_name                   | Value |
+---------------------------------+-------+
| information_schema_stats_expiry | 86400 |
+---------------------------------+-------+
```
Documentation states you can get an accurate value for a table using the `ANALYZE TABLE <table>` command or setting `information_schema_stats_expiry=0`.  It would seem in GCP Cloud SQL you cannot alter this database flag.

This variable has session state. In AWS you can at least set this dynamically.

```
mysql-aws> SET SESSION information_schema_stats_expiry=0;
```


We should run both commands as a litmus test for comparison for tickets.  AWS and GCP will allocate default space for table growth differently.

This query will give you a per schema size using `INNODB_TABLESPACES`.

```
SELECT SUBSTRING_INDEX(NAME,'/',1) AS TABLE_SCHEMA,
      ROW_FORMAT,
      SUM(ROUND(FILE_SIZE/POW(1024,2),2)) AS 'FILE_SIZE (MiB)',
      SUM(ROUND(ALLOCATED_SIZE/POW(1024,2),2)) AS 'ALLOCATED_SIZE (MiB)'
FROM INFORMATION_SCHEMA.INNODB_TABLESPACES
WHERE NAME NOT REGEXP '(PERFORMANCE_SCHEMA|INFORMATION_SCHEMA|SYS|MYSQL)/.*'
GROUP BY TABLE_SCHEMA, ROW_FORMAT
ORDER BY 3 DESC;
```

### Example Output
```
+------------------+----------------------+-----------------+----------------------+
| TABLE_SCHEMA     | ROW_FORMAT           | FILE_SIZE (MiB) | ALLOCATED_SIZE (MiB) |
+------------------+----------------------+-----------------+----------------------+
| imdb             | Dynamic              |           11704 |                11704 |
| airportdb        | Dynamic              |            8036 |                 8036 |
| innodb_undo_001  | Undo                 |            1200 |                 1200 |
| innodb_undo_002  | Undo                 |             832 |                  832 |
| postcodes        | Dynamic              |             692 |                  692 |
| employees        | Dynamic              |             544 |                  544 |
| sakila           | Dynamic              |             124 |                  124 |
| mysql            | Any                  |              32 |                   32 |
| innodb_temporary | Compact or Redundant |              12 |                   12 |
| world            | Dynamic              |              12 |                   12 |
| menagerie        | Dynamic              |               8 |                    8 |
+------------------+----------------------+-----------------+----------------------+
11 rows in set (0.00 sec)
```

## 2. Redo Log

MySQL InnoDB uses a circular series of Redo Log Files. These are a fixed size and do not grow.  You can verify the configuration with.

```
SELECT ROUND((s.variable_value * c.variable_value)/1024/1024) as redo_mb
FROM performance_schema.global_variables s,
     performance_schema.global_variables c
WHERE s.variable_name = 'innodb_log_file_size'
AND   c.variable_name = 'innodb_log_files_in_group';


# Legacy Means
SELECT variable_name, variable_value
FROM performance_schema.global_variables
WHERE variable_name LIKE 'innodb_log_file%';

SHOW GLOBAL VARIABLES LIKE 'innodb_log_file%';
```

### Example

```
+---------+
| redo_mb |
+---------+
|      96 |
+---------+

+---------------------------+----------------+
| variable_name             | variable_value |
+---------------------------+----------------+
| innodb_log_file_size      | 50331648       |
| innodb_log_files_in_group | 2              |
+---------------------------+----------------+

+---------------------------+----------+
| Variable_name             | Value    |
+---------------------------+----------+
| innodb_log_file_size      | 50331648 |
| innodb_log_files_in_group | 2        |
+---------------------------+----------+

```

## 3. MySQL Binary Log

To get the footprint of the size of the binary logs.

```
  SHOW BINARY LOGS
```

Example

```
> show binary logs;
+----------------------------+-----------+-----------+
| Log_name                   | File_size | Encrypted |
+----------------------------+-----------+-----------+
| mysql-bin-changelog.000001 |      3361 | No        |
| mysql-bin-changelog.000002 | 746768901 | No        |
| mysql-bin-changelog.000003 | 208066326 | No        |
| mysql-bin-changelog.000004 | 188040573 | No        |
| mysql-bin-changelog.000005 | 172571630 | No        |
| mysql-bin-changelog.000006 |       156 | No        |
+----------------------------+-----------+-----------+
```

NOTE: File Size is bytes. There is not underlying table you can easily query to sum the total size.

or

```
ERROR 1381 (HY000): You are not using binary logging
```

In AWS the following setting defines how long Binary Logs are retained
```
call mysql.rds_show_configuration();
+------------------------+-------+------------------------------------------------------------------------------------------------------+
| name                   | value | description                                                                                          |
+------------------------+-------+------------------------------------------------------------------------------------------------------+
| binlog retention hours | NULL  | binlog retention hours specifies the duration in hours before binary logs are automatically deleted. |
+------------------------+-------+------------------------------------------------------------------------------------------------------+
1 row in set (0.01 sec)
```

NOTE: AWS Aurora MySQL by default does not use MySQL native binary log replication for Clusters, while for AWS RDS it does.

## Temporary Data

The following queries can show the configuration and size of InnoDB temporary files.

```
SELECT @@innodb_temp_data_file_path;
SELECT FILE_NAME,
       TABLESPACE_NAME,
       ENGINE,
       INITIAL_SIZE,
       TOTAL_EXTENTS*EXTENT_SIZE AS TotalSizeBytes,
       DATA_FREE,
       MAXIMUM_SIZE
FROM INFORMATION_SCHEMA.FILES
WHERE TABLESPACE_NAME = 'innodb_temporary';

SELECT * FROM INFORMATION_SCHEMA.INNODB_SESSION_TEMP_TABLESPACES;

SELECT * FROM INFORMATION_SCHEMA.INNODB_TEMP_TABLE_INFO;
```
Cite: https://dev.mysql.com/doc/refman/8.0/en/innodb-temporary-tablespace.html

### Example Output
```
SELECT @@innodb_temp_data_file_path;
+------------------------------+
| @@innodb_temp_data_file_path |
+------------------------------+
| ibtmp1:12M:autoextend        |
+------------------------------+
1 row in set (0.00 sec)

+-----------+------------------+--------+--------------+----------------+-----------+--------------+
| FILE_NAME | TABLESPACE_NAME  | ENGINE | INITIAL_SIZE | TotalSizeBytes | DATA_FREE | MAXIMUM_SIZE |
+-----------+------------------+--------+--------------+----------------+-----------+--------------+
| ./ibtmp1  | innodb_temporary | InnoDB |     12582912 |       12582912 |   6291456 |         NULL |
+-----------+------------------+--------+--------------+----------------+-----------+--------------+
1 row in set (0.00 sec)

+-------+------------+-------------+-------+----------+-----------+
| ID    | SPACE      | PATH        | SIZE  | STATE    | PURPOSE   |
+-------+------------+-------------+-------+----------+-----------+
|  6058 | 4294502284 | temp_28.ibt | 98304 | ACTIVE   | INTRINSIC |
| 14488 | 4294502286 | temp_30.ibt | 98304 | ACTIVE   | INTRINSIC |
|     0 | 4294502277 | temp_21.ibt | 81920 | INACTIVE | NONE      |
|     0 | 4294502278 | temp_22.ibt | 81920 | INACTIVE | NONE      |
|     0 | 4294502279 | temp_23.ibt | 81920 | INACTIVE | NONE      |
|     0 | 4294502280 | temp_24.ibt | 81920 | INACTIVE | NONE      |
|     0 | 4294502281 | temp_25.ibt | 81920 | INACTIVE | NONE      |
|     0 | 4294502282 | temp_26.ibt | 81920 | INACTIVE | NONE      |
|     0 | 4294502283 | temp_27.ibt | 81920 | INACTIVE | NONE      |
|     0 | 4294502285 | temp_29.ibt | 81920 | INACTIVE | NONE      |
+-------+------------+-------------+-------+----------+-----------+
10 rows in set (0.00 sec)

Empty set (0.00 sec)
```

## Other References
 -  [Ticket 99164 GCP - Storage for an example](https://doitintl.zendesk.com/agent/tickets/99164)
