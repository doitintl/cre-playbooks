[Playbooks](../../../../../README.md) > [Data](../../../../README.md) > 
[Databases](../../../README.md) > [MySQL](../../../README.md) > 
[Excessive storage](../../../general/common-problems/pb_storage_excessive.md) >
Data

# Data excessive space usage

This playbook is meant to help troubleshoot when Data is using an excessive amount of disk space

## Summary

Generally, when data is taking up the majority of space the issue is on the application side.   
Following this playbook, we can help to identify the problem and guide the customer to a resolution.   
Here is [an example image of the problem](../images/gcp_cloudsql_data_excessive.png) in CloudSQL using Cloud Monitoring.

## Actions
Please follow the Checklist and linked sections afterward for more details.   

### Checklist
- [ ] Confirm the version of MySQL
- [ ] Confirm if automatic storage increase is enabled (can prevent downtime if they are close to exhausting space)
- [ ] Inquire about any application/database deployments around the time the problem started
- [ ] [Find the culprit](#find-the-culprit-and-gather-more-info-from-the-customer)
  - [ ] [List schemas and tables by size](#list-schemas-by-size)
  - [ ] [Get the largest tables](#get-the-largest-tables)
- [ ] [Resolve](#resolutions)

### Find the culprit and gather more info from the customer

## MySQL Data

You can identify the underlying disk-space used by the MySQL schemas in an instance with the query:

#### List Schemas by size
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

##### Example Output

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

#### Example Output
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

#### Get the largest tables

Identify the largest tables in the database

```
SELECT NAME AS 'SCHEMA/TABLE',
      ROW_FORMAT,
      PAGE_SIZE,
      FS_BLOCK_SIZE,
      ROUND(FILE_SIZE/pow(1024,2),2) AS 'FILE_SIZE (MiB)',
      ROUND(ALLOCATED_SIZE/pow(1024,2),2) AS 'ALLOCATED_SIZE (MiB)'
FROM INFORMATION_SCHEMA.INNODB_TABLESPACES
WHERE NAME NOT REGEXP '(PERFORMANCE_SCHEMA|INFORMATION_SCHEMA|SYS|MYSQL)/.*'
ORDER BY 5 DESC
LIMIT 20;
```

### Resolutions

Generally, when data size is excessive it will be up to the customer to resolve.   
Using the previously gathered information, provide the customer with recommendations.   
For example, if there is a specific table or two taking up the majority of space - talk through how this table is used and ways to address the issue.

## Appendix A - Previous tickets
 -  [Ticket 99164 GCP - Storage for an example](https://doitintl.zendesk.com/agent/tickets/99164)
 