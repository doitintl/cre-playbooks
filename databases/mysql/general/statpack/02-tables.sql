CREATE TABLE config (
  name VARCHAR(20) NOT NULL,
  value JSON NOT NULL,
  PRIMARY KEY(name)
) ENGINE=InnoDB;

CREATE TABLE log (
  created DATETIME NOT NULL,
  stat_type JSON NOT NULL,
  PRIMARY KEY(created)
) ENGINE=InnoDB;

CREATE TABLE status (
  created DATETIME NOT NULL,
  name VARCHAR(64) NOT NULL,
  value VARCHAR(100) NULL,
  PRIMARY KEY (created, name)
) ENGINE=InnoDB;

CREATE TABLE variable (
  created DATETIME NOT NULL,
  name VARCHAR(64) NOT NULL,
  value VARCHAR(1024) NULL,
  PRIMARY KEY (created, name)
) ENGINE=InnoDB;

CREATE TABLE thread_summary (
  created DATETIME NOT NULL,
  command VARCHAR(16) NOT NULL,
  cnt SMALLINT UNSIGNED NOT NULL,
  max_time SMALLINT UNSIGNED NOT NULL,
  cnt_info SMALLINT UNSIGNED NOT NULL,
  max_info SMALLINT UNSIGNED NULL,
  PRIMARY KEY (created, command)
) ENGINE=InnoDB;

CREATE TABLE object_summary (
  created DATETIME NOT NULL,
  object_schema VARCHAR(64) NOT NULL,
  object_type  VARCHAR(20) NOT NULL,
  object_cnt   SMALLINT UNSIGNED NOT NULL,
  PRIMARY KEY (created, object_schema, object_type)
) ENGINE=InnoDB;

CREATE TABLE help (
  id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  msg TEXT NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB;
