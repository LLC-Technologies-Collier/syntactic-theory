/* Copyright 2015, 2016 Collier Technologies LLC */

use grammar;

source syntactic_category/create-table.sql;
source syntactic_category/create-routine.sql;
source syntactic_category/create-view.sql;
source syntactic_category/create-trigger.sql;

CREATE TABLE IF NOT EXISTS rule (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  target_id  INT NOT NULL,

  CONSTRAINT fk_rule_pcat FOREIGN KEY (target_id) REFERENCES _phrasal_category(id)
) ENGINE=INNODB, COMMENT='Rules indicating valid grammatical constructs';

CREATE TABLE IF NOT EXISTS term (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  rule_id    INT NOT NULL,

  fact_count INT NOT NULL,

  CONSTRAINT fk_term_rule FOREIGN KEY (rule_id) REFERENCES rule(id)
) ENGINE=INNODB, COMMENT='Terms representing different forms of rules';


CREATE TABLE IF NOT EXISTS factor (
  id        INT AUTO_INCREMENT PRIMARY KEY,

  term_id   INT NOT NULL,
  position  INT NOT NULL,

  cat_id    INT NOT NULL,

  optional  TINYINT NOT NULL DEFAULT 0,
  rpt       TINYINT NOT NULL DEFAULT 0, /* short for repeat, but that is a keyword */

  CONSTRAINT uniq_rule_position UNIQUE (term_id,position),
  CONSTRAINT fk_fact_term FOREIGN KEY (term_id) REFERENCES term(id),
  CONSTRAINT fk_fact_scat FOREIGN KEY (cat_id) REFERENCES syntactic_category(id)
) ENGINE=INNODB, COMMENT='Syntactic categories and sequence numbers which make up terms';
