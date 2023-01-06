[Playbooks](../../../../README.md) > [Data](../../../README.md) > 
[Databases](../../README.md) > [PostgreSQL](../../README.md) > Replication Lag

# PostgreSQL replication lag

This playbook is meant to help troubleshoot problems with Replication lag in a PostgreSQL database instance.    

## Summary

`TODO`

## Actions
Please follow the Checklist and linked sections afterward for more details.   

### Checklist
- [ ] Confirm GCP or AWS
  - [ ] Request access to the customer environment
- [ ] Confirm the version of PostgreSQL
- [ ] Confirm type of replication in use
  - [ ] Cloud-managed read-replica (native replication)
  - [ ] pglogical
- [ ] [Find the culprit](#find-the-culprit-and-gather-more-info-from-the-customer)
  - [ ] [Check for an obvious culprit](#use-available-cloud-tooling-to-look-for-an-obvious-culprit)
- [ ] [Resolve](#resolutions)
  - [ ] `TODO`

### Find the culprit and gather more info from the customer

#### Use available cloud tooling to look for an obvious culprit
Please see this example [ticket 98902](https://doitintl.zendesk.com/agent/tickets/98902) for GCP CloudSQL replication lag due to inefficient DML

### Resolutions

#### `TODO` 

## Appendix A - Images
