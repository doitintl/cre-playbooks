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
      - [ ] `Redo_log` `TODO`
      - [ ] `Relaylog` `TODO`
      - [ ] `Binlog` `TODO`
      - [ ] `Cloudsql_mysql_audit_log` `TODO`
      - [ ] `General_log` `TODO`
      - [ ] `Data` See ticket [see 99164 for an example](https://doitintl.zendesk.com/agent/tickets/99164)
      - [ ] `Other` `TODO`
      - [ ] `Tmp_data` `TODO`
    - [ ] If AWS, `TODO`\
    - [ ] If self-hosted (**best effort**)
    