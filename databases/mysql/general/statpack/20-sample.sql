SELECT "This runs a sampling of all possible statistics based on the 'sample' config" AS msg;
SELECT * FROM config WHERE name='sample';

call statpack_sample();
SELECT * FROM log;

call status_change('Questions');
call status_change('Innodb_rows_inserted');
