delimiter $$
DROP PROCEDURE IF EXISTS statpack_gather$$
CREATE PROCEDURE statpack_gather(options JSON)
BEGIN
  DECLARE current DATETIME;
  DECLARE gather_status BOOLEAN DEFAULT 0;
  DECLARE gather_variable BOOLEAN DEFAULT 0;
  DECLARE gather_thread BOOLEAN DEFAULT 0;
  DECLARE gather_object BOOLEAN DEFAULT 0;

  SET current = NOW();
  SET gather_status = JSON_EXTRACT(options, "$.status");
  SET gather_variable = JSON_EXTRACT(options, "$.variable");
  SET gather_thread = JSON_EXTRACT(options, "$.thread");
  SET gather_object = JSON_EXTRACT(options, "$.object");


  SELECT current, gather_status, gather_variable, gather_thread, gather_object;

  START TRANSACTION;

  INSERT INTO log (created, stat_type)
    VALUES (current, options);

  IF gather_status = 1 THEN
    INSERT INTO status (created, name, value)
      SELECT current, VARIABLE_NAME, LEFT(VARIABLE_VALUE,100) 
      FROM performance_schema.global_status;
  END IF;

  IF gather_variable = 1 THEN
    INSERT INTO variable (created, name, value) 
      SELECT current, VARIABLE_NAME, VARIABLE_VALUE FROM performance_schema.global_variables;
  END IF;

  IF gather_thread = 1 THEN
    INSERT INTO thread_summary(created, command, cnt, max_time, cnt_info, max_info)
      SELECT current, command, count(*), MAX(time), SUM(IF(info != NULL,1,0)), MAX(LENGTH(info)) 
      FROM INFORMATION_SCHEMA.PROCESSLIST WHERE command != 'Daemon' GROUP BY command ORDER BY 2 DESC;
  END IF;


  IF gather_object = 1 THEN
    INSERT INTO object_summary(created, object_schema, object_type, object_cnt)
      SELECT MIN(current) as created, routine_schema AS object_schema, 'routine' AS object_type, COUNT(*) FROM information_schema.routines
      WHERE  routine_schema  NOT IN ('mysql','information_schema','performance_schema','sys','_doit_mysql_statpack')
      GROUP BY routine_schema
      UNION
      SELECT current as created, table_schema, 'view', COUNT(*) FROM information_schema.views
      WHERE  table_schema  NOT IN ('mysql','information_schema','performance_schema','sys','_doit_mysql_statpack')
      GROUP BY table_schema
      UNION
      SELECT current as created, trigger_schema, 'trigger', COUNT(*) from information_schema.triggers
      WHERE  trigger_schema  NOT IN ('mysql','information_schema','performance_schema','sys','_doit_mysql_statpack')
      GROUP BY trigger_schema
      UNION
      SELECT current as created, event_schema, 'event', COUNT(*) from information_schema.events
      WHERE  event_schema  NOT IN ('mysql','information_schema','performance_schema','sys','_doit_mysql_statpack')
      GROUP BY event_schema
      UNION
      SELECT current as created, table_schema, LOWER(table_type), COUNT(*) from information_schema.tables
      WHERE  table_schema  NOT IN ('mysql','information_schema','performance_schema','sys','_doit_mysql_statpack')
      AND    table_type NOT IN ('VIEW','SYSTEM VIEW')
      GROUP BY table_schema
    ORDER BY created, object_schema, object_type;
  END IF;

  COMMIT;

END $$

DROP PROCEDURE IF EXISTS status_change$$
CREATE PROCEDURE status_change(status_name VARCHAR(64))
BEGIN

  SELECT @start:=created, @prior := value
  FROM status 
  WHERE name = status_name limit 1;

  SELECT d.created, d.name, d.seconds, d.value_change 
  FROM (SELECT name, TIMESTAMPDIFF(SECOND, @start, created) AS seconds,
               value - @prior AS value_change,
               @start:=created AS created, 
               @prior := value AS value
        FROM status 
        WHERE name = status_name) d;

END $$


DROP PROCEDURE IF EXISTS statpack_truncate$$
CREATE PROCEDURE statpack_truncate()
BEGIN
  TRUNCATE TABLE log;
  TRUNCATE TABLE variable;
  TRUNCATE TABLE status;
  TRUNCATE TABLE thread_summary;
  TRUNCATE TABLE object_summary;

END $$

DROP PROCEDURE IF EXISTS statpack_sample$$
CREATE PROCEDURE statpack_sample()
BEGIN
  DECLARE stats VARCHAR(100);
  DECLARE counter INT DEFAULT 1;
  DECLARE times INT;
  DECLARE frequency INT;
  DECLARE sleeping INT;

  SELECT value INTO stats 
  FROM config
  WHERE name = 'sample';


 
  SET times = JSON_EXTRACT(stats, "$.count");
  SET frequency = JSON_EXTRACT(stats, "$.seconds");


  WHILE counter <= times 
  DO
    SELECT NOW() AS now, CONCAT(counter, ' of ', times) AS status;
    CALL statpack_gather(stats);
    SET counter = counter + 1;
    SET sleeping = SLEEP(frequency);
  END WHILE;

END $$

DROP PROCEDURE IF EXISTS statpack_wait$$
CREATE PROCEDURE statpack_wait(wait INT, options JSON)
BEGIN
  DECLARE sleeping INT;

  SET sleeping = SLEEP(wait);
  CALL statpack_gather(options);
END $$

DROP PROCEDURE IF EXISTS statpack_iterate$$
CREATE PROCEDURE statpack_iterate(times INT, wait INT, options JSON)
BEGIN
  DECLARE sleeping INT;
  DECLARE counter INT DEFAULT 1;

  CALL statpack_gather(options);

  WHILE counter < times
  DO
    CALL statpack_wait(wait, options);
    SET counter = counter + 1;
  END WHILE;
END $$

DROP PROCEDURE IF EXISTS help$$
CREATE PROCEDURE help()
BEGIN
  SELECT msg
  FROM help
  ORDER BY id;
END $$

DELIMITER ;


