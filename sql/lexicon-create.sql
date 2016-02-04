/* Copyright 2015, 2016 Collier Technologies LLC */

use grammar;

CREATE TABLE IF NOT EXISTS lexeme (
  id     INT AUTO_INCREMENT PRIMARY KEY,
  word   VARCHAR(64),
  cat_id INT NOT NULL,
  CONSTRAINT fk_lexeme_lexcat FOREIGN KEY (cat_id) REFERENCES _lexical_category(id)
) ENGINE=INNODB, COMMENT='Words available for use and their associated properties';
