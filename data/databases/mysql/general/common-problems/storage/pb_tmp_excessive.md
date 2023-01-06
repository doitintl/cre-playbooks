[Playbooks](../../../../../README.md) > [Data](../../../../README.md) > 
[Databases](../../../README.md) > [MySQL](../../../README.md) > 
[Excessive storage](../../../general/common-problems/pb_storage_excessive.md) >
Temporary Data

# Temporary Data excessive space usage

This playbook is meant to help troubleshoot when Temporary data is using an excessive amount of disk space

## Summary

`TODO` Some general blurb about usual suspects causing unexpected Temp data usage     

## Actions
Please follow the Checklist and linked sections afterward for more details.   

### Checklist
- [ ] Confirm the version of MySQL
- [ ] Confirm if automatic storage increase is enabled (can prevent downtime if they are close to exhausting space)
- [ ] Inquire about any application/database deployments or infrastructure changes around the time the problem started
- [ ] [Find the culprit](#find-the-culprit-and-gather-more-info-from-the-customer)
  - [ ] [Gather Temporary data information](#gather-temporary-data-information)
- [ ] [Resolve](#resolutions) `TODO`

### Find the culprit and gather more info from the customer

## Gather Temporary Data information

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

### Resolutions

`TODO` More information to be added here. 