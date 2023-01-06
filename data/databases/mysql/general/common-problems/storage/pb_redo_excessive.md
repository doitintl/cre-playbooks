[Playbooks](../../../../../README.md) > [Data](../../../../README.md) > 
[Databases](../../../README.md) > [MySQL](../../../README.md) > 
[Excessive storage](../../../general/common-problems/pb_storage_excessive.md) >
Redo Logs

# Redo Logs excessive space usage
This playbook is meant to help troubleshoot when Redo Logs are using an excessive amount of disk space

## Summary
`TODO` Some general blurb about usual suspects causing unexpected Redo Log usage      

## Actions
Please follow the Checklist and linked sections afterward for more details.   

### Checklist
- [ ] Confirm the version of MySQL
- [ ] Confirm if automatic storage increase is enabled (can prevent downtime if they are close to exhausting space)
- [ ] Inquire about any application/database deployments around the time the problem started
- [ ] [Find the culprit](#find-the-culprit-and-gather-more-info-from-the-customer)
  - [ ] [Gather Redo log information](#gather-redo-log-information)
- [ ] [Resolve](#resolutions) `TODO`

### Find the culprit and gather more info from the customer

#### Gather Redo Log information

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

### Resolutions

`TODO` More information to be added here. 