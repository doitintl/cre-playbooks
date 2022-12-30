[Playbooks](../../../../../README.md) > [Data](../../../../README.md) > 
[Databases](../../../README.md) > [MySQL](../../../README.md) > 
[Excessive storage](../../../general/common-problems/pb_storage_excessive.md) >
Binary logs

# Binary logs excessive space usage

This playbook is meant to help troubleshoot when Binlog is using an excessive amount of disk space

## Summary

`TODO` Some general blurb about binlog, and when this is usually a problem.     

## Actions
Please follow the Checklist and linked sections afterward for more details.   

### Checklist
- [ ] Confirm the version of MySQL
- [ ] Confirm if automatic storage increase is enabled (can prevent downtime if they are close to exhausting space)
- [ ] Inquire about any application/database deployments or infrastructure changes around the time the problem started
- [ ] [Find the culprit](#find-the-culprit-and-gather-more-info-from-the-customer)
  - [ ] [Gather Binlog information](#gather-binlog-information)
- [ ] [Resolve](#resolutions) `TODO`

### Find the culprit and gather more info from the customer

#### Gather Binlog information

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

### Resolutions

`TODO` More information to be added here. 