/* Copyright 2015 Collier Technologies LLC */

/* Begin syntactic category subclass view definitions */

CREATE OR REPLACE VIEW
lexical_category AS
  SELECT sc.id           as id,
  	 sc.label        as label,
	 sc.longname     as longname
  FROM _lexical_category lc
  LEFT JOIN syntactic_category sc
  ON sc.id = lc.id;

CREATE OR REPLACE VIEW
phrasal_category AS
  SELECT sc.id           as id,
  	 sc.label        as label,
	 sc.longname     as longname,
	 pc.head_lcat_id as head
  FROM _phrasal_category pc
  LEFT JOIN syntactic_category sc
  ON pc.id = sc.id;

/* Begin syntactic category subclass view definitions */
