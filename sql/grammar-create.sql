/* Copyright 2015 Collier Technologies LLC */

use grammar;

source syntactic_category/create-table.sql;

CREATE TABLE IF NOT EXISTS lexeme (
  id     INT AUTO_INCREMENT PRIMARY KEY,
  word   VARCHAR(64),
  pos_id INT NOT NULL,
  CONSTRAINT fk_lexeme_lexcat FOREIGN KEY (pos_id) REFERENCES _lexical_category(id)
) ENGINE=INNODB, COMMENT='Words available for use and their associated properties';

CREATE TABLE IF NOT EXISTS phrase_structure_rule (
  id        INT AUTO_INCREMENT PRIMARY KEY,
  target_id INT NOT NULL,

  CONSTRAINT fk_phstrule_pcat FOREIGN KEY (target_id) REFERENCES _phrasal_category(id)
) ENGINE=INNODB, COMMENT='Rules indicating valid grammatical constructs';

CREATE TABLE IF NOT EXISTS rule_node (
  id        INT AUTO_INCREMENT PRIMARY KEY,

  rule_id   INT NOT NULL,
  position  INT NOT NULL,

  scat_id   INT NOT NULL,

  optional  BIT NOT NULL DEFAULT b'0',
  rpt       BIT NOT NULL DEFAULT b'0', /* short for repeat, but that is a keyword */

  CONSTRAINT uniq_rule_position UNIQUE (rule_id,position),
  CONSTRAINT fk_rcp_rule FOREIGN KEY (rule_id) REFERENCES phrase_structure_rule(id),
  CONSTRAINT fk_rcp_scat FOREIGN KEY (scat_id) REFERENCES syntactic_category(id)
) ENGINE=INNODB, COMMENT='Syntactic categories and sequence numbers which make up rules';

