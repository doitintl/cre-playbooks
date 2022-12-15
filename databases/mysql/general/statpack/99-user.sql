CREATE USER doit_statpack@'10.%' IDENTIFIED BY '';
GRANT CREATE, INSERT,UPDATE,DELETE,DROP ON _doit_mysql_statpack.* TO doit_statpack@'10.%';
