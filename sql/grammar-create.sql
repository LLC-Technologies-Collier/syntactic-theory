/* Copyright 2015 Collier Technologies LLC */

CREATE DATABASE IF NOT EXISTS grammar;

CREATE USER 'grammaradm'@'localhost' IDENTIFIED BY 'password';
GRANT ALL ON grammar.* TO 'grammaradm'@'localhost';

CREATE TABLE IF NOT EXISTS syntactic_category (
  id INT AUTO_INCREMENT PRIMARY KEY,

  category_type ENUM('lexical','phrasal'),
  
) ENGINE=INNODB, COMMENT='A syntactic category, be it lexical or phrasal';

CREATE TABLE IF NOT EXISTS lexical_category (
  id INT PRIMARY KEY,
  CONSTRAINT fk_lcat_scat (id) REFERENCES syntactic_category(id)
) ENGINE=INNODB, COMMENT='A grammatical category for lexemes';

CREATE TABLE IF NOT EXISTS phrasal_category (
  id INT PRIMARY KEY,
  CONSTRAINT fk_pcat_scat (id) REFERENCES syntactic_category(id)
) ENGINE=INNODB, COMMENT='A grammatical category for phrases';

CREATE TABLE IF NOT EXISTS lexeme (
  id     INT AUTO_INCREMENT PRIMARY KEY,
  word   VARCHAR(64),
  pos_id INT,
  CONSTRAINT fk_lexeme_lexcat (pos_id) REFERENCES lexical_category(id)
) ENGINE=INNODB, COMMENT='Words available for use and their associated properties';

CREATE TABLE IF NOT EXISTS phrase_structure_rule (
  id        INT AUTO_INCREMENT PRIMARY KEY,
  target_id INT NOT NULL,

  CONSTRAINT fk_phstrule_pcat FOREIGN KEY (target_id) REFERENCES phrasal_category(id)
) ENGINE=INNODB, COMMENT='Rules indicating valid grammatical constructs';

CREATE TABLE IF NOT EXISTS rule_cat_position (
  id        INT AUTO_INCREMENT PRIMARY KEY,

  rule_id   INT NOT NULL,
  position  INT NOT NULL,

  scat_id   INT DEFAULT NULL,

  optional  BIT(1) NOT NULL DEFAULT b'0',
  repeat    BIT(1) NOT NULL DEFAULT b'0',

  CONSTRAINT uniq_rule_cat_position UNIQUE (rule_id,position),
  CONSTRAINT fk_rcp_rule FOREIGN KEY (rule_id) REFERENCES phrase_structure_rule(id),
  CONSTRAINT fk_rcp_scat FOREIGN KEY (scat_id) REFERENCES syntactic_category(id)
) ENGINE=INNODB, COMMENT='Syntactic categories and sequence numbers which make up rules';

