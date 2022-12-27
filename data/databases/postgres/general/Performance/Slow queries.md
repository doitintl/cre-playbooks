Hi! I want to start with some definitions to plan our subsequent actions correctly.

 - `VACUUM ANALYZE` performs a `VACUUM` and then an `ANALYZE` for each selected table. This is a handy combination form for **routine maintenance scripts**
 - `VACUUM` reclaims storage occupied by dead tuples. In normal PostgreSQL operation, tuples that are deleted or obsoleted by an update are not physically removed from their table; they remain present until a `VACUUM` is done
 ref: https://www.postgresql.org/docs/current/sql-vacuum.html 
 - `ANALYZE` collects statistics about the contents of tables in the database, and stores the results in the `pg_statistic` system catalog. Subsequently, the query planner uses these statistics to help determine the most efficient execution plans for queries
 ref: https://www.postgresql.org/docs/current/sql-analyze.html 
 
==> `ANALYZE` helps the query planner to find the best path to execute a query (path + use or not the index)

If the index is not healthy,  analyze will **not solve the issue** as it's only about telling the query planner what is the status of indexes, dead tuples, etc.

# Where to start ?

You can check the `ANALYS` status by running the following query `SELECT schemaname, relname, last_autoanalyze, last_analyze FROM pg_stat_all_tables`

You can check the index Health by running the following command  
`SELECT * FROM pg_class, pg_index WHERE pg_index.indisvalid = false AND pg_index.indexrelid = pg_class.oid`;  
=> If you see your index in this query it means that the index is not going to be used and you have to recreate the index. (please note the `indisvalid` condition on the where statement)

> REINDEX won’t re-create the index concurrently, it will lock the table for writes while the index is being created, if this is not affordable then the best solution is to drop the invalid index and recreate it with **CONCURRENTLY** flag

> When this option is used, PostgreSQL will rebuild the index without taking any locks that prevent concurrent inserts, updates, or deletes on the table; whereas a standard index rebuild locks out writes (but not reads) on the table until it's done

Please note that there are several caveats to be aware of when using this option. Please read this before going through this exercise => ref : https://www.postgresql.org/docs/current/sql-reindex.html#SQL-REINDEX-CONCURRENTLY

* The SQL command would be the following: `REINDEX TABLE CONCURRENTLY my_broken_table;` (available since PostgreSQL 12 ), also, you can do `DROP INDEX` and then `CREATE INDEX CONCURRENTLY.`

* How do I know that this query is finished? Using this command ?
`select * from pg_stat_progress_create_index`
ref; https://www.postgresql.org/docs/current/progress-reporting.html#CREATE-INDEX-PROGRESS-REPORTING

# What if I have a slow query ?

Whenever you see a query taking more time than it should be / more CPU than it should be, please try to explain it using `explain analyze` then force the query to hit the table directly and see if the results are any different using (`set enable_indexscan='off';`)

In a case where **there have been any bulk operations, like data load or truncate,** statistics would be out of date and this is obviously a valid reason to suspect that any trouble you are having with your database is related to statistics status / index health, therefore **The time when you must run ANALYZE manually is immediately after bulk loading data into the target table (or delete/truncate)**.
Ref: https://www.enterprisedb.com/blog/postgresql-vacuum-and-analyze-best-practice-tips

# Maintenance Tasks (`autovacuum, autoanalyze`) 

it’s not a best practice to run manual vacuums too often on the entire database; the target database could already be optimally vacuumed by the `autovacuum` process. `autovacuum` also keeps a table’s data distribution statistics up-to-date
 
Please note that `autovacuum` doesn’t rebuild statistics, it updates them. When manually run, the `ANALYZE` command actually rebuilds these statistics instead of updating them.

=> if `autovaccum` is well configured, you don't have to run `VACUUM OR ANALYZE OR BOTH` unless you are required to (aka **bulk operations, like data load or truncate)**

PostgreSQL uses two configuration parameters to decide when to kick off an auto vacuum:
-   autovacuum_vacuum_threshold: this has a default value of 50  
-   autovacuum_vacuum_scale_factor: this has a default value of 0.2  
    
Together, these parameters tell PostgreSQL to start an  `autovacuum`  based on this formula:

```scss
pg_stat_user_tables.n_dead_tup > (pg_class.reltuples x autovacuum_vacuum_scale_factor)  + autovacuum_vacuum_threshold

```
Let's do a calculation example here : 

For a table with 10.000 rows, the number of dead rows has to be over 2050 before an autovacuum kicks off
For a table with 1 million rows => 200,050 dead rows before an autovacuum starts.
 
Similar to `autovacuum`, `autoanalyze` also uses two parameters that decide when `autovacuum` will also trigger an autoanalyze:

- autovacuum_analyze_threshold: this has a default value of 50
- autovacuum_analyze_scale_factor: this has a default value of 0.1


> Like autovacuum, the autovacuum_analyze_threshold parameter can be set
> to a value that dictates the number of inserted, deleted, or updated
> tuples in a table before an autoanalyze starts. We recommend setting
> this parameter separately on large and high-transaction tables. The
> table configuration will override the postgresql.conf values.
> 
> The code snippet below shows the SQL syntax for modifying the
> autovacuum_analyze_threshold setting for a table.
> 
> **`ALTER`**  **`TABLE`**`<table_name>`**`SET`**`(autovacuum_analyze_threshold = <threshold`**`rows`**`>)`

