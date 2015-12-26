/* Copyright 2015 Collier Technologies LLC */

DELIMETER «

CREATE PROCEDURE insertSyntacticCategory( IN type VARCHAR(8), INOUT category_id )
BEGIN
  INSERT INTO syntactic_category ( category_type ) VALUES( type );
  SET category_id = LAST_INSERT_ID();
END;

CREATE TRIGGER trigger_ins_lcat BEFORE INSERT ON lexical_category
FOR EACH ROW
BEGIN
  DECLARE category_id INT;
  CALL insertSyntacticCategory( 'lexical', category_id );
  SET NEW.id = category_id;
END;

CREATE TRIGGER trigger_ins_pcat BEFORE INSERT ON phrasal_category
FOR EACH ROW
BEGIN
  DECLARE category_id INT;
  CALL insertSyntacticCategory( 'phrasal', category_id );
  SET NEW.id = category_id;
END;


«

delimeter ;
