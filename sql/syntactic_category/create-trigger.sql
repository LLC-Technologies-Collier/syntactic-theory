/* Copyright 2015 Collier Technologies LLC */

/* Begin insert, update, delete triggers */

DELIMITER //

DROP TRIGGER IF EXISTS trigger_ins_lcat;
CREATE TRIGGER trigger_ins_lcat BEFORE INSERT ON lexical_category_writer
FOR EACH ROW
BEGIN
  DECLARE ctype VARCHAR(8);

  SET ctype = 'lexical';

  INSERT INTO syntactic_category ( `ctype`,`label`,`longname` )
                           VALUES( ctype, NEW.label, NEW.longname );
  SET NEW.id = LAST_INSERT_ID();

  INSERT INTO _lexical_category ( id )
                         VALUES ( NEW.id );

  CALL assert_category_consistency( ctype, NEW.id );
END;

DROP TRIGGER IF EXISTS trigger_upd_lcat;
CREATE TRIGGER trigger_upd_lcat BEFORE UPDATE ON lexical_category_writer
FOR EACH ROW
BEGIN
  /* no support for updates yet */
  CALL assert_category_consistency( 'lexical', NEW.id );
END;

DROP TRIGGER IF EXISTS trigger_ins_pcat;
CREATE TRIGGER trigger_ins_pcat BEFORE INSERT ON phrasal_category_writer
FOR EACH ROW
BEGIN
  DECLARE ctype VARCHAR(8);
  SET ctype = 'phrasal';

  INSERT INTO syntactic_category ( `ctype`,`label`,`longname` )
                           VALUES( ctype, NEW.label, NEW.longname );
  SET NEW.id = LAST_INSERT_ID();
  
  INSERT INTO _phrasal_category ( id, head_cat_id )
                         VALUES ( NEW.id, NEW.head_cat_id );

  CALL assert_category_consistency( ctype, NEW.id );
END;

DROP TRIGGER IF EXISTS trigger_upd_pcat;
CREATE TRIGGER trigger_upd_pcat BEFORE UPDATE ON phrasal_category_writer
FOR EACH ROW
BEGIN
  /* no support for updates yet */
  CALL assert_category_consistency('phrasal', NEW.id);
END;

//

DELIMITER ;

/* End insert, update, delete triggers */
