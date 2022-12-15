START TRANSACTION;
SELECT @current := NOW();
INSERT INTO log (created, stat_type) VALUES (@current, '{"status": 1, "variable": 1}');
INSERT INTO status (created, name, value) SELECT @current, VARIABLE_NAME, LEFT(VARIABLE_VALUE,100) FROM performance_schema.global_status;
COMMIT;




SELECT COUNT(*) FROM INFORMATION_SCHEMA.SCHEMATA 
  WHERE SCHEMA_NAME NOT IN ('mysql','information_schema','performance_schema','sys','_doit_mysql_statpack');


SELECT   @current, 
         table_schema,
         SUM(data_length+index_length)/1024/1024 AS total_mb,
         SUM(data_length)/1024/1024 AS data_mb,
         SUM(index_length)/1024/1024 AS index_mb,
         COUNT(*) AS table_cnt,
	 GROUP_CONCAT(DISTINCT engine) AS engines
FROM     information_schema.tables
WHERE    table_schema NOT IN ('mysql','information_schema','performance_schema','sys','_doit_mysql_statpack')
GROUP BY table_schema
ORDER BY 2 DESC;


INSERT INTO object_summary(created, object_schema, object_type, object_cnt)
SELECT MIN(@current) as created, routine_schema AS object_schema, 'routine' AS object_type, COUNT(*) FROM information_schema.routines 
WHERE  routine_schema  NOT IN ('mysql','information_schema','performance_schema','sys','_doit_mysql_statpack')
GROUP BY routine_schema
UNION
SELECT @current as created, table_schema, 'view', COUNT(*) FROM information_schema.views 
WHERE  table_schema  NOT IN ('mysql','information_schema','performance_schema','sys','_doit_mysql_statpack')
GROUP BY table_schema
UNION
SELECT @current as created, trigger_schema, 'trigger', COUNT(*) from information_schema.triggers 
WHERE  trigger_schema  NOT IN ('mysql','information_schema','performance_schema','sys','_doit_mysql_statpack')
GROUP BY trigger_schema
UNION
SELECT @current as created, event_schema, 'event', COUNT(*) from information_schema.events
WHERE  event_schema  NOT IN ('mysql','information_schema','performance_schema','sys','_doit_mysql_statpack')
GROUP BY event_schema
UNION
SELECT @current as created, table_schema, LOWER(table_type), COUNT(*) from information_schema.tables
WHERE  table_schema  NOT IN ('mysql','information_schema','performance_schema','sys','_doit_mysql_statpack')
AND    table_type NOT IN ('VIEW','SYSTEM VIEW')
GROUP BY table_schema
ORDER BY created, object_schema, object_type
;


delimiter $$
DROP PROCEDURE IF EXISTS statpack_gather$$
CREATE PROCEDURE statpack_gather(options JSON)
BEGIN

  START TRANSACTION;

  SELECT @current := NOW();

  INSERT INTO log (created, stat_type)
    VALUES (@current, options);

  INSERT INTO status (created, name, value)
    SELECT @current, VARIABLE_NAME, LEFT(VARIABLE_VALUE,100) 
    FROM performance_schema.global_status;

  INSERT INTO variable (created, name, value) 
    SELECT @current, VARIABLE_NAME, VARIABLE_VALUE FROM performance_schema.global_variables;

  INSERT INTO thread_summary(created, command, cnt, max_time, cnt_info, max_info)
    SELECT @current, command, count(*), MAX(time), SUM(IF(info != NULL,1,0)), MAX(LENGTH(info)) 
    FROM INFORMATION_SCHEMA.PROCESSLIST WHERE command != 'Daemon' GROUP BY command ORDER BY 2 DESC;


  INSERT INTO object_summary(created, object_schema, object_type, object_cnt)
    SELECT MIN(@current) as created, routine_schema AS object_schema, 'routine' AS object_type, COUNT(*) FROM information_schema.routines
    WHERE  routine_schema  NOT IN ('mysql','information_schema','performance_schema','sys','_doit_mysql_statpack')
    GROUP BY routine_schema
    UNION
    SELECT @current as created, table_schema, 'view', COUNT(*) FROM information_schema.views
    WHERE  table_schema  NOT IN ('mysql','information_schema','performance_schema','sys','_doit_mysql_statpack')
    GROUP BY table_schema
    UNION
    SELECT @current as created, trigger_schema, 'trigger', COUNT(*) from information_schema.triggers
    WHERE  trigger_schema  NOT IN ('mysql','information_schema','performance_schema','sys','_doit_mysql_statpack')
    GROUP BY trigger_schema
    UNION
    SELECT @current as created, event_schema, 'event', COUNT(*) from information_schema.events
    WHERE  event_schema  NOT IN ('mysql','information_schema','performance_schema','sys','_doit_mysql_statpack')
    GROUP BY event_schema
    UNION
    SELECT @current as created, table_schema, LOWER(table_type), COUNT(*) from information_schema.tables
    WHERE  table_schema  NOT IN ('mysql','information_schema','performance_schema','sys','_doit_mysql_statpack')
    AND    table_type NOT IN ('VIEW','SYSTEM VIEW')
    GROUP BY table_schema
    ORDER BY created, object_schema, object_type;

  COMMIT;

END $$

DELIMITER ;
