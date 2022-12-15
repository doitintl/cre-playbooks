# DoiT StatPack for MySQL

## Overview

These database only deployment SQL scripts enables the ability to collect
summarized information of a MySQL (AWS or GCP) instances including variables,
status, schema, and processes in a consistent and reproducible way.

Several database helpers enable a quick interactive analysis in a very
summarized way.

This data should be exported to a dump where local tools can be used to delve
into analyzing the collected information. This also enables the re-evaluation
of data from prior collection samples in future situations to confirm
repeating situations and data patterns.


## Installation

To install the underlying schema, tables, routines and configuration data used
by StatPack.

    source statpack/00-install.sql


## Sampling

You can run a full test that performs a sampling of your MySQL instance with

   source statpack/20-sample.sql

## Reset

To conveniently reset all the data stored in StatPack to enable a new iteration
of monitoring.

    source statpack/90-reset.sql

## Removal

To remove StatPack and all objects from your MySQL Instance

    source statpack/99-install.sql

## Help

To get a summary of what you can do.

    call help();

## General Usage

### To run interactively

1. Determine what stats you wish to collect (values are optional)
2. Collect these stats one time
3. Wait a defined amount of time and collect stats one more time

You can then use various routines to evaluate the differences between
the two samples.

    call statpack_truncate();
    set @stats:= '{"status": 1, "variable": 1, "thread": 1, "object": 1}';
    call statpack_gather(@stats);
    set @stats := '{"status": 1, "thread": 1}';
    call statpack_wait(60, @stats);
    call status_change('Uptime');

##  To run for a period of time

Generally you will want to collect certain statistics in a repeated means
during a test or period of system analysis.  You can run the collection
of stats for an iteration of 'n' times every 'x' seconds.

    set @stats := '{"status": 1, "thread": 1}';
    # Collect 4 samples every 15 seconds for given stats
    call statpack_iterate(4, 15, @stats);

## Customization

There are many ways you can customize the installation as needed. By default
StatPack is installed in specific schema `_doit_statpack_mysql`. This is
completely configurable.  All tables, data and routines are self contained
for easy extraction and removal. The general installation runs a number
of encapsulated scripts.

    source statpack/01-schema.sql
    USE _doit_statpack_mysql;
    source statpack/02-tables.sql
    source statpack/03-data.sql
    source statpack/10-gather.sql

## Help

Refer to the installation README for setup of StatPack for MySQL.

To reset all data to the system defaults use `statpack_truncate`

    call statpack_truncate();

To collect a short sample to validate your setup use `statpack_sample`.
It is recommended you use the previous function to clear the sample before
detailed monitoring.

    call statpack_sample();

The available statistics at this time are.

- `variable` - This collects information on the global variables
- `status`  - This collects information on the global status
- `thread` - This collects information on the running threads
- `object` - This collects information on the size and volume of your objects

To collect one sample of statistics use `statpack_gather`.

    set @stats:= '{"status": 1, "variable": 1, "thread": 1, "object": 1}';
    call statpack_gather(@stats);

All types of statistics are optional, if you do not wish to collect them
you can either set to false (0) or not specify.

    set @stats := '{"status": 1, "thread": 1}';
    call statpack_gather(@stats);

If you wish to wait a certain number of seconds before collecting the
statistics use `statpack_wait`

    set @stats := '{"status": 1, "thread": 1}';
    set @wait := 60;
    call statpack_wait(@wait, @stats);

To collect a set of statistics over a period of time with regular intervals
use `statpack_iterate`

    # Collect 4 samples every 15 seconds for the given stats
    set @stats := '{"status": 1, "thread": 1}';
    set @cnt := 4;
    set @wait := 15;
    call statpack_iterate(@cnt, @wait, @stats);

To get a summary of the change of status for a given attribute for
all sample times.

    call status_change('Questions');

This will produce the following output which provides the change of the
given status (both the time and value).  Using the prior example of
executing 4 samples every 15 seconds, we see that the change in the value
from the first execution to the last execution.

NOTE: Some MySQL status values are not incremental so this does not function
as expected.

    +---------------------+-----------+---------+--------------+
    | created             | name      | seconds | value_change |
    +---------------------+-----------+---------+--------------+
    | 2022-12-15 14:20:23 | Questions |       0 |            0 |
    | 2022-12-15 14:20:38 | Questions |      15 |          118 |
    | 2022-12-15 14:20:53 | Questions |      15 |          105 |
    | 2022-12-15 14:21:08 | Questions |      15 |          105 |
    +---------------------+-----------+---------+--------------+

Some other examples include:

    call status_change('Innodb_rows_inserted');
    call status_change('Innodb_data_fsyncs');
    call status_change('Innodb_buffer_pool_write_requests');


## Further development

- At this time only a summary of threads are collection. The goal is to collect detailed thread information, generally triggered by an event.  
This however presents a PII situation.
- Collect more information on the schemas and tables in the largest or specific schemas.
