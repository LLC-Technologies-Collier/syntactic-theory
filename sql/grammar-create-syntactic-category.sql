/* Copyright 2015 Collier Technologies LLC */

/* Begin syntactic category and subclass table definitions */

CREATE TABLE IF NOT EXISTS syntactic_category (
  id INT AUTO_INCREMENT PRIMARY KEY,

  label    VARCHAR(10),
  longname VARCHAR(64),

  category_type ENUM('lexical','phrasal'),
  
) ENGINE=INNODB, COMMENT='A syntactic category of class lexical or phrasal';

CREATE TABLE IF NOT EXISTS _lexical_category (
  id INT PRIMARY KEY,
  CONSTRAINT fk_lcat_scat (id) REFERENCES syntactic_category(id)
) ENGINE=INNODB, COMMENT='A syntactic category for lexemes';

CREATE VIEW lexical_category AS
  SELECT sc.id           as id,
  	 sc.label        as label,
	 sc.longname     as longname,
  FROM syntactic_category sc
  LEFT JOIN _lexical_category lc
  ON sc.id = lc.id;

CREATE TABLE IF NOT EXISTS _phrasal_category (
  id          INT PRIMARY KEY,

  head_lcat_id INT NOT NULL,

  CONSTRAINT fk_pcat_scat (id) REFERENCES syntactic_category(id),
  CONSTRAINT fk_pcat_lcat (head_lcat_id) REFERENCES lexical_category(id)
) ENGINE=INNODB, COMMENT='A syntactic category for phrases';

CREATE VIEW phrasal_category AS
  SELECT sc.id           as id,
  	 sc.label        as label,
	 sc.longname     as longname,
	 pc.head_lcat_id as head
  FROM syntactic_category sc
  LEFT JOIN _phrasal_category pc
  ON sc.id = pc.id;

/* End syntactic category and subclass table definitions */

/* Begin stored procedures and insert, update, delete triggers */

DELIMETER «

CREATE PROCEDURE insertSyntacticCategory( IN category_type VARCHAR(8),
                                          INOUT category_id INT)
BEGIN
  INSERT INTO syntactic_category ( `category_type` ) VALUES( category_type );
  SET category_id = LAST_INSERT_ID();
END;

CREATE PROCEDURE assert_category_validity( IN category_type VARCHAR(8),
                                           IN category_id INT)
BEGIN
  IF( category_type != 'lexical' ) THEN
    /* TODO: Log warning if select count(*) FROM _lexical_category WHERE id=category_id */
    DELETE FROM _lexical_category WHERE id=category_id;
  END IF;
  IF( category_type != 'phrasal' ) THEN
    /* TODO: Log warning */
    DELETE FROM _phrasal_category WHERE id=category_id;
  END IF;
END;

CREATE TRIGGER trigger_ins_lcat BEFORE INSERT ON _lexical_category
FOR EACH ROW
BEGIN
  DECLARE category_id INT;
  DECLARE category_type VARCHAR(8);

  SET category_type = 'lexical';

  CALL insertSyntacticCategory( category_type, category_id );
  SET NEW.id = category_id;

  CALL assert_category_validity( category_type, NEW.id );
END;

CREATE TRIGGER trigger_upd_lcat BEFORE UPDATE ON _lexical_category
FOR EACH ROW
BEGIN
  CALL assert_category_validity( 'lexical', NEW.id );
END;

CREATE TRIGGER trigger_ins_pcat BEFORE INSERT ON _phrasal_category
FOR EACH ROW
BEGIN
  DECLARE category_id INT;
  DECLARE category_type VARCHAR(8);
  SET category_type = 'phrasal';

  CALL insertSyntacticCategory( category_type, category_id );
  SET NEW.id = category_id;

  CALL assert_category_validity( category_type, category_id );
END;

CREATE TRIGGER trigger_upd_pcat BEFORE UPDATE ON _phrasal_category
FOR EACH ROW
BEGIN
  CALL assert_category_validity('phrasal', NEW.id);
END;

«

delimeter ;

/* End stored procedures and insert, update, delete triggers */
