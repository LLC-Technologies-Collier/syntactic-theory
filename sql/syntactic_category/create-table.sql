/* Copyright 2015 Collier Technologies LLC */

/* Begin syntactic category and subclass table definitions */

CREATE TABLE IF NOT EXISTS syntactic_category (
  id INT AUTO_INCREMENT PRIMARY KEY,

  label    VARCHAR(10) UNIQUE NOT NULL,
  longname VARCHAR(64) UNIQUE NOT NULL,

  category_type ENUM('lexical','phrasal') NOT NULL
  
) ENGINE=INNODB, COMMENT='A syntactic category of class lexical or phrasal';

CREATE TABLE IF NOT EXISTS _lexical_category (
  id INT PRIMARY KEY,
  CONSTRAINT fk_lcat_scat FOREIGN KEY (id) REFERENCES syntactic_category(id)
) ENGINE=INNODB, COMMENT='A syntactic category for lexemes';

CREATE TABLE IF NOT EXISTS lexical_category_ (
  id       INT PRIMARY KEY,

  label    VARCHAR(10) UNIQUE NOT NULL,
  longname VARCHAR(64) UNIQUE NOT NULL

) ENGINE=MEMORY, COMMENT='An abstract table for use in triggering updates to the _lexical_category and syntactic_category tables';

CREATE TABLE IF NOT EXISTS _phrasal_category (
  id           INT PRIMARY KEY,

  head_lcat_id INT NOT NULL,

  CONSTRAINT fk_pcat_scat FOREIGN KEY (id) REFERENCES syntactic_category(id),
  CONSTRAINT fk_pcat_lcat FOREIGN KEY (head_lcat_id) REFERENCES _lexical_category(id)
) ENGINE=INNODB, COMMENT='A syntactic category for phrases';

CREATE TABLE IF NOT EXISTS phrasal_category_ (
  id           INT PRIMARY KEY,

  label        VARCHAR(10) NOT NULL,
  longname     VARCHAR(64) NOT NULL,

  head_lcat_id INT NOT NULL

) ENGINE=MEMORY, COMMENT='An abstract table for use in triggering updates to the _phrasal_category and syntactic_category tables';


/* End syntactic category and subclass table definitions */
