/* Copyright 2015 Collier Technologies LLC */

/* Begin stored procedures and stored functions */

DELIMITER //

DROP FUNCTION IF EXISTS catid_by_label;
CREATE FUNCTION catid_by_label ( l VARCHAR(10) )
RETURNS INT
BEGIN
  DECLARE cat_id INT;
  SELECT id INTO cat_id FROM syntactic_category WHERE label=l;
  RETURN cat_id;
END;

DROP PROCEDURE IF EXISTS assert_category_consistency;
CREATE PROCEDURE assert_category_consistency ( category_type VARCHAR(8),
                                               category_id INT )
BEGIN
  IF category_type != 'lexical' THEN
    /* TODO: Log warning if select count(*) FROM _lexical_category WHERE id=category_id */
    DELETE FROM _lexical_category WHERE id=category_id;
  ELSEIF category_type != 'phrasal' THEN
    /* TODO: Log warning if ... */
    DELETE FROM _phrasal_category WHERE id=category_id;
  END IF;
END;

DROP PROCEDURE IF EXISTS insert_syntactic_category;
CREATE PROCEDURE insert_syntactic_category ( category_type VARCHAR(8),
                                             OUT category_id INT,
                                             label VARCHAR(10),
                                             longname VARCHAR(64) )
BEGIN
  INSERT INTO syntactic_category ( `category_type`,`label`,`longname` )
                           VALUES( category_type, label, longname );
  SET category_id = LAST_INSERT_ID();
END;

//

DELIMITER ;

/* End stored procedures and stored functions */
