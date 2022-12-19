[Playbooks](../../../../README.md) > [Data](../../../README.md) > 
[Databases](../../README.md) > [PostgreSQL](../../README.md) > Excessive storage 

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
      - [ ] `Archived_wal_log`, [follow this playbook](../../gcp/common-problems/pb_storage_arch_wal.md)
      - [ ] `Data` `TODO`
      - [ ] `Other` `TODO`
      - [ ] `Tmp_data` `TODO`
      - [ ] `Wal`, [follow this playbook](../../gcp/common-problems/pb_storage_wal.md)
      - [ ] If both `Wal` and `Archived_wal_log`, start with `Wal` playbook
    - [ ] If AWS, `TODO`\
    - [ ] If self-hosted (**best effort**)
    