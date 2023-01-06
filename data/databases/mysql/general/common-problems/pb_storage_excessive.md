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

- [ ] Request Concedify or Sauron access
  - [ ] If access is not provided, customer will need to gather this information for us
- [ ] Identify the type of data taking up an unexpected amount of space
    - [ ] If GCP, view `disk/bytes_used_by_data_type` metric type in [System Insights](https://cloud.google.com/sql/docs/postgres/use-system-insights#metrics-pg) or `database/disk/bytes_used_by_data_type` in [Cloud Monitoring Metrics Explorer](https://cloud.google.com/monitoring/charts/metrics-explorer)
      - [ ] `Data` [follow this playbook](storage/pb_data_excessive.md)
      - [ ] `Redo_log` [follow this playbook](storage/pb_redo_excessive.md)
      - [ ] `Binlog` [follow this playbook](storage/pb_binlog_excessive.md)
      - [ ] `Tmp_data` [follow this playbook](storage/pb_tmp_excessive.md)
      - [ ] `Relaylog` `TODO`
      - [ ] `Cloudsql_mysql_audit_log` `TODO`
      - [ ] `General log` `TODO`
      - [ ] `Slow Query Log` `TODO`    
      - [ ] `Other` `TODO`
    - [ ] If AWS: 
      - [ ] If we have Sauron, we can use [Cloudwatch](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/rds-metrics.html) to check: 
        - [ ] `BinLogDiskUsage` [follow this playbook](storage/pb_binlog_excessive.md)
        - [ ] `SwapUsage` `TODO`
      - [ ] Cloudwatch does not provide granular space information, gather information from each playbook:
        - [ ] [Data](storage/pb_data_excessive.md)
        - [ ] [Redo](storage/pb_redo_excessive.md)
        - [ ] [Temporary data](storage/pb_tmp_excessive.md)
        - [ ] If no Sauron, then also the [BinLog](storage/pb_binlog_excessive.md) playbook
    - [ ] If self-hosted (**best effort, follow each sub-playbook under [storage](storage)**)
