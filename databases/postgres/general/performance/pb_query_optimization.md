# Query optimization (slow/timing out) playbook 

This playbook is meant to be followed in a "query is slow" or "my query is timing out" scenario.    
The assumption is that the query is known, and it's not just a generic "my database is slow" scenario.

## Summary   

There are many things to consider when optimizing an individual query.     
Generally, Database instances do not cancel queries if they are taking a while to execute.   
If a query timeout is reported, it's usually being canceled on the application/database driver side.

## Actions
Please follow the Checklist and linked sections afterward for more details.   

### Checklist

- [ ] Gather information from the customer, including:
  - [ ] Business impact the issue is having
  - [ ] The actual error message being received (if there is one)
  - [ ] The PostgreSQL instance information ( instance name, version, primary or read replica?)
  - [ ] The problematic query SQL and explain plan (`EXPLAIN (FORMAT JSON, ANALYZE, BUFFERS) {problematic query}`)
  - [ ] The DDL (including indexes) of the tables the statement is referencing
  - [ ] The size of the tables involved and indexes, can ask to run the [largest tables query](../scripts/table_size_info.sql)
  - [ ] Table and index bloat information, can ask to run the [table_index_bloat query](../scripts/table_index_bloat.sql)
  - [ ] Is routine database maintenance being performed? (ANALYZE, VACUUM, REINDEX), ask to run [table_last_maintenance query](../scripts/table_last_maintenance.sql)
  - [ ] The language the application is written in 
  - [ ] The database driver version, and any connection or session level settings
  - [ ] Request access to the customer's project/account
  - [ ] When did the problem start?
  - [ ] How often is it happening? 
  - [ ] Has there been a code deployment around the time this started?
- [ ] Investigate the issue
  - [ ] Instance information
    - [ ] CPU/RAM
    - [ ] Storage used vs allocated
    - [ ] Overall CPU and RAM utilization
  - [ ] If GCP (assumes concedify access): 
    - [ ] Record any configured database flags
    - [ ] Use Performance Insights to try and find the problematic query, if found, review the query plan
    - [ ] Use Cloud Logging to try and find the reported error
      - [ ] Check Cloud SQL logs for the instance to see if the error is there, or potentially query information (if auto_explain is configured)
      - [ ] Check application logs, if known (eg: GKE logs for the application)
  - [ ] If AWS: `TODO`
- [ ] Resolve `TODO`

 
     