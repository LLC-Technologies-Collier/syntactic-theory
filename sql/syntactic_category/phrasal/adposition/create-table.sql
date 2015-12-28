/* Copyright 2015 Collier Technologies LLC */

/* Begin adpositional phrase and subclass table definitions */

CREATE TABLE IF NOT EXISTS _adpositional_phrase (
  id INT PRIMARY KEY,

  phrase_type ENUM('prepositional','postpositional','circumpositional'),

  CONSTRAINT fk_adposp_pcat (id) REFERENCES phrasal_category(id)
) ENGINE=INNODB, COMMENT='An adpositional phrase of a specified type';

CREATE TABLE IF NOT EXISTS _prepositional_phrase (
  id INT PRIMARY KEY,
  CONSTRAINT fk_prep_pp (id) REFERENCES adpositional_phrase(id)
) ENGINE=INNODB, COMMENT='A phrase specification for preposition-headed phrases';

CREATE TABLE IF NOT EXISTS _postpositional_phrase (
  id INT PRIMARY KEY,
  CONSTRAINT fk_postp_pp (id) REFERENCES adpositional_phrase(id)
) ENGINE=INNODB, COMMENT='A phrase specification for postposition-headed phrases';

CREATE TABLE IF NOT EXISTS _circumpositional_phrase (
  id INT PRIMARY KEY,
  CONSTRAINT fk_circump_pp (id) REFERENCES adpositional_phrase(id)
) ENGINE=INNODB, COMMENT='A phrase specification for circumposition-headed phrases';

/* End adpositional phrase and subclass table definitions */

/* Begin stored procedures and insert, update, delete triggers */

DELIMETER «

CREATE PROCEDURE assert_adpos_phrase_consistency( IN phrase_type VARCHAR(8),
                                                  IN phrase_id INT)
BEGIN
  IF( phrase_type != 'preposition' ) THEN
    /* TODO: Log warning if select count(*) FROM _prepositional_phrase WHERE id=category_id */
    DELETE FROM _prepositional_phrase WHERE id=phrase_id;
  END IF;
  IF( phrase_type != 'postposition' ) THEN
    /* TODO: Log warning if ... */
    DELETE FROM _postpositional_phrase WHERE id=category_id;
  END IF;
  IF( phrase_type != 'circumposition' ) THEN
    /* TODO: Log warning if ... */
    DELETE FROM _circumpositional_phrase WHERE id=category_id;
  END IF;
END;

CREATE PROCEDURE insertAdpositionalPhrase( IN phrase_type VARCHAR(16), INOUT phrase_id )
BEGIN
  INSERT INTO _adpositional_phrase ( phrase_type ) VALUES( type );
  SET phrase_id = LAST_INSERT_ID();
  CALL assert_adpos_phrase_consistency( phrase_type, category_id );
END;

CREATE TRIGGER trigger_ins_adp BEFORE INSERT ON _adpositional_phrase
FOR EACH ROW
BEGIN
  DECLARE category_id INT;
  DECLARE ctype VARCHAR(8);

  SET ctype = 'phrasal';

  CALL insertSyntacticCategory( ctype, category_id );
  SET NEW.id = category_id;

  CALL assert_category_consistency( ctype, NEW.id );
END;

CREATE TRIGGER trigger_ins_prep BEFORE INSERT ON _prepositional_phrase
FOR EACH ROW
BEGIN
  DECLARE phrase_id INT;
  DECLARE phrase_type VARCHAR(16);
  SET phrase_type = 'preposition';
  CALL insertAdpositionalPhrase( phrase_type, phrase_id );
  SET NEW.id = phrase_id;
  CALL assert_adpos_phrase_consistency( phrase_type, phrase_id );
END;

CREATE TRIGGER trigger_ins_postp BEFORE INSERT ON _postpositional_phrase
FOR EACH ROW
BEGIN
  DECLARE phrase_type VARCHAR(16);
  SET phrase_type = 'postposition';
  CALL insertAdpositionalPhrase( 'postposition', phrase_id );
  SET NEW.id = phrase_id;
  CALL assert_adpos_phrase_consistency( phrase_type, phrase_id );
END;

CREATE TRIGGER trigger_ins_circump BEFORE INSERT ON _circumpositional_phrase
FOR EACH ROW
BEGIN
  DECLARE phrase_id INT;
  DECLARE phrase_type VARCHAR(16);
  SET phrase_type = 'circumposition';
  CALL insertAdpositionalPhrase( phrase_type, phrase_id );
  SET NEW.id = phrase_id;
  CALL assert_adpos_phrase_consistency( phrase_type, phrase_id );
END;

«

delimeter ;

/* End stored procedures and insert, update, delete triggers */
