/* Copyright 2015 Collier Technologies LLC */

use grammar;

source syntactic_category/create-table.sql;
source syntactic_category/create-routine.sql;
source syntactic_category/create-view.sql;
source syntactic_category/create-trigger.sql;

CREATE TABLE IF NOT EXISTS lexeme (
  id     INT AUTO_INCREMENT PRIMARY KEY,
  word   VARCHAR(64),
  cat_id INT NOT NULL,
  CONSTRAINT fk_lexeme_lexcat FOREIGN KEY (cat_id) REFERENCES _lexical_category(id)
) ENGINE=INNODB, COMMENT='Words available for use and their associated properties';

CREATE TABLE IF NOT EXISTS phrase_structure_rule (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  target_id  INT NOT NULL,

  node_count INT NOT NULL,

  CONSTRAINT fk_phstrule_pcat FOREIGN KEY (target_id) REFERENCES _phrasal_category(id)
) ENGINE=INNODB, COMMENT='Rules indicating valid grammatical constructs';

CREATE TABLE IF NOT EXISTS rule_node (
  id        INT AUTO_INCREMENT PRIMARY KEY,

  rule_id   INT NOT NULL,
  position  INT NOT NULL,

  cat_id    INT NOT NULL,

  optional  TINYINT NOT NULL DEFAULT 0,
  rpt       TINYINT NOT NULL DEFAULT 0, /* short for repeat, but that is a keyword */

  CONSTRAINT uniq_rule_position UNIQUE (rule_id,position),
  CONSTRAINT fk_rcp_rule FOREIGN KEY (rule_id) REFERENCES phrase_structure_rule(id),
  CONSTRAINT fk_rcp_scat FOREIGN KEY (cat_id) REFERENCES syntactic_category(id)
) ENGINE=INNODB, COMMENT='Syntactic categories and sequence numbers which make up rules';

