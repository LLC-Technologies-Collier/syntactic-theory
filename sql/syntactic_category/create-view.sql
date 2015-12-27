/* Copyright 2015 Collier Technologies LLC */

/* Begin syntactic category subclass view definitions */

CREATE VIEW lexical_category AS
  SELECT sc.id           as id,
  	 sc.label        as label,
	 sc.longname     as longname
  FROM syntactic_category sc
  LEFT JOIN _lexical_category lc
  ON sc.id = lc.id;

CREATE VIEW phrasal_category AS
  SELECT sc.id           as id,
  	 sc.label        as label,
	 sc.longname     as longname,
	 pc.head_lcat_id as head
  FROM syntactic_category sc
  LEFT JOIN _phrasal_category pc
  ON sc.id = pc.id;

/* Begin syntactic category subclass view definitions */
