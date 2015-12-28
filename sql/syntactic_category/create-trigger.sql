/* Copyright 2015 Collier Technologies LLC */

/* Begin insert, update, delete triggers */

DELIMITER //

DROP TRIGGER IF EXISTS trigger_ins_lcat;
CREATE TRIGGER trigger_ins_lcat BEFORE INSERT ON lexical_category_
FOR EACH ROW
BEGIN
  DECLARE category_type VARCHAR(8);

  SET category_type = 'lexical';

  INSERT INTO syntactic_category ( `category_type`,`label`,`longname` )
                           VALUES( category_type, NEW.label, NEW.longname );
  SET NEW.id = LAST_INSERT_ID();

  INSERT INTO _lexical_category ( id )
                         VALUES ( NEW.id );

  CALL assert_category_consistency( category_type, NEW.id );
END;

DROP TRIGGER IF EXISTS trigger_upd_lcat;
CREATE TRIGGER trigger_upd_lcat BEFORE UPDATE ON lexical_category_
FOR EACH ROW
BEGIN
  /* no support for updates yet */
  CALL assert_category_consistency( 'lexical', NEW.id );
END;

DROP TRIGGER IF EXISTS trigger_ins_pcat;
CREATE TRIGGER trigger_ins_pcat BEFORE INSERT ON phrasal_category_
FOR EACH ROW
BEGIN
  DECLARE category_type VARCHAR(8);
  SET category_type = 'phrasal';

  INSERT INTO syntactic_category ( `category_type`,`label`,`longname` )
                           VALUES( category_type, NEW.label, NEW.longname );
  SET NEW.id = LAST_INSERT_ID();
  
  INSERT INTO _phrasal_category ( id, head_lcat_id )
                         VALUES ( NEW.id, NEW.head_lcat_id );

  CALL assert_category_consistency( category_type, NEW.id );
END;

DROP TRIGGER IF EXISTS trigger_upd_pcat;
CREATE TRIGGER trigger_upd_pcat BEFORE UPDATE ON phrasal_category_
FOR EACH ROW
BEGIN
  /* no support for updates yet */
  CALL assert_category_consistency('phrasal', NEW.id);
END;

//

DELIMITER ;

/* End insert, update, delete triggers */
