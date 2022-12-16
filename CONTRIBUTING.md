# CRE Playbook contributions
____________

Thanks for contributing to CRE playbooks!   

## Contributors FAQ
____________

### Why contribute?
Playbooks help CREs solve problems more efficiently and consistently.    
This should lead to:    
- Increased CRE productivity
- Help reduce the impact of more trivial/common/recurring requests
- Free CRE up to work on other things
- Improved customer satisfaction

### Who can contribute?
Everyone is welcome to contribute!    

### What to contribute?
All topics are welcome!    
Lowest hanging fruit/most common and recurring issues are preferred, but any content added will be of value and appreciated!    

### When to contribute?
Contributions are always welcome!    
Typically, the best time to contribute is when a topic is fresh on your mind. This makes it easier to write.  
If you follow a playbook that is out of date, please take the time to update it!

### How to contribute?
Simply create a feature branch in this repo, and start writing! Be sure to read the remaining sections of this doc.     
The feature name should resemble the goal of the playbook. EG: `feature/postgres_replication_lag`   
Please open a pull request targetting `main` when you are ready for your playbook to be reviewed, and add in 3-4 CREs that are well-versed in the topic to review.   
Again, these are meant to be iterative so the playbook just needs to be useful - not necessarily 100% complete. 

## Contributing
____________
Please follow the guidelines below for contributing to CRE Playbooks.

### Completeness
Playbooks ***do not need to be 100% complete before they are submitted***! These are meant to be iterative, so *something* is better than nothing.   
Even if your contribution is simply a link to a customer request for a given topic, that's fine too! We can always add to it later.

### Clear outcomes
Each playbook and sub-playbook should target a specific outcome.  
A higher-level parent playbook might be a starting point for "My entire database is slow".   
The goal of the higher-level playbook would be to gather information and effectively point the user toward a more specific sub-playbook.    
In the "My entire database is slow" scenario, there may be several sub-playbooks that could be followed depending on the information gathered in the parent playbook.   

### Checklist section
Include a checklist section at the top of the playbook.    
Checklists serve as a summary of steps and help walk the user through the playbook.    
This is done in markdown with `- [ ] <some text>`.    

### Call out business critical information
Be sure to call out when a solution will require downtime, data loss, or any other potential business implications.    
For example, disabling Point-in-time recovery on a database instance could cause a customer to breach their RPO/RTO requirements. 

### Supporting information, documentation, links
Checklist steps should contain links to relevant sections in the playbook (or a sub-playbook) which go into more detail.    

### Detailed sections
Detailed sections should be placed below the checklist and contain as much information as possible to help the user.   
These should contain things like supporting documentation, screenshots, command snippets and scripts.

### Playbook directory structure and layout
The general layout is hierarchical with the goal being the ability for a user to drill down from high level categories into a specific situation.   
Each subdirectory should have a `README.md` with an index of content; guiding the user to the specific issue they are facing.   
The structure looks like:   
`Topic -> Category -> Product -> General Issue -> Playbook -> Sub-Playbook`

#### Example Layout 
As an example, if a customer is reporting excessive disk space on their GCP Cloud SQL Postgres instance:
```
├── README.md   (Users clicks on "Data")
├── data
│   ├── README.md   (User clicks on "Databases"
│   ├── databases
│   │   ├── README.md   (User clicks on "Postgres")
│   │   ├── postgres
│   │   │   ├── README.md (User clicks on "Excessive disk space used or space exhausted")
│   │   │   ├── general
│   │   │       ├── common-problems
│   │   │       │   └── pb_storage_excessive.md (User follows general steps, which lands them on "Cloud SQL Archived_wal_log" playbook)
│   │   │   └── gcp
│   │   │   │   ├── common-problems
│   │   │   │   │   ├── pb_storage_arch_wal.md (User follows this sub-playbook)
│   │   │   │   │   └── pb_storage_wal.md
│   │   │   │   └── images
│   │   │   │       ├── cloud_monitoring_arch_wal.png
│   │   │   │       ├── cloud_monitoring_wal.jpg
│   │   │   │       └── system_insights_arch_wal.png
```
Excessive disk space is a general problem, so the starting point for the playbook is placed at `general/common-problems/pb_storage_execessive.md` and an index entry added in `postgres/README.md`.    
The starting point collects some information and then guides the user to GCP-focused steps found in `gcp/common-problems`.    
Images and scripts related to an article should be in an `./images` and `./scripts` folder, respectively, in the same directory as the article.

### File naming conventions   
There is no need for a super-strict naming convention, the most important piece is that the README.md documents aid the user in navigating to the proper article.   
With that being said, playbooks should be prefixed with `pb_` and the rest of the name should be helpful in identifying the goal of the article.   
Example: `pb_storage_excessive.md` paints a pretty clear picture about the topic of the article.

### Breadcrumbs    
Breadcrumbs should be created at the top of an article to help the user easily understand where they are in the hierarchy and navigate back to the previous article.   
At present, they need to be manually added to the article (sorry!), we can look at better solutions for this in the future.

Here an example breadcrumb markdown in the [Cloud SQL Wal](data/databases/postgres/gcp/common-problems/pb_storage_wal.md) playbook.

```
[Playbooks](../../../../README.md) > [Data](../../../README.md) > 
[Databases](../../README.md) > [PostgreSQL](../../README.md) > 
[Excessive storage](../../general/common-problems/pb_storage_excessive.md) >
Cloud SQL Wal
```
Which results in this at the top of the page:

[Playbooks](../../../../README.md) > [Data](../../../README.md) > 
[Databases](../../README.md) > [PostgreSQL](../../README.md) > 
[Excessive storage](../../general/common-problems/pb_storage_excessive.md) >
Cloud SQL Wal

## Suggestions, comments, feedback
____________
Please provide feedback and suggestions for improvement!    
The goal is for this to be useful and easy to contribute.