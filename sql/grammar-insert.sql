/* Copyright 2015, 2016 Collier Technologies LLC */
DELETE FROM lexeme;

DELETE FROM rule;
DELETE FROM term;
DELETE FROM factor;
DELETE FROM _phrasal_category;
DELETE FROM phrasal_category_writer;
DELETE FROM _lexical_category;
DELETE FROM lexical_category_writer;
DELETE FROM syntactic_category;

INSERT INTO lexical_category_writer ( label, longname )
            VALUES ( 'D',    'Determiner' ),
                   ( 'A',    'Adjective' ),
                   ( 'Adv',  'Adverb' ),
                   ( 'N',    'Noun' ),
                   ( 'V',    'Verb' ),
                   ( 'CONJ', 'Conjunction' ),
                   ( 'P',    'Preposition' );

SET @determiner_catid  = ( SELECT catid_by_label('D') );
SET @adjective_catid   = ( SELECT catid_by_label('A') );
SET @adverb_catid      = ( SELECT catid_by_label('Adv') );
SET @noun_catid        = ( SELECT catid_by_label('N') );
SET @conj_catid        = ( SELECT catid_by_label('CONJ') );
SET @verb_catid        = ( SELECT catid_by_label('V') );
SET @preposition_catid = ( SELECT catid_by_label('P') );

INSERT INTO phrasal_category_writer
       ( longname,               label,  head_cat_id )
VALUES ( 'Determiner Phrase',    'DP',   @determiner_catid ),
       ( 'Adjective Phrase',     'AP',   @adjective_catid ),
       ( 'Adverb Phrase',        'AdvP', @adverb_catid ),
       ( 'Noun Phrase',          'NP',   @noun_catid ),
       ( 'Verb Phrase',          'VP',   @verb_catid ),
       ( 'Prepositional Phrase', 'PP',   @preposition_catid ),
       ( 'Nominal',              'NOM',  @noun_catid ),
       ( 'Conjunctive Phrase',   'X',    NULL ),
       ( 'Sentence',             'S',    NULL );

SET @AP_catid   = ( SELECT catid_by_label('AP') );
SET @AdvP_catid = ( SELECT catid_by_label('AdvP') );
SET @NP_catid   = ( SELECT catid_by_label('NP') );
SET @VP_catid   = ( SELECT catid_by_label('VP') );
SET @PP_catid   = ( SELECT catid_by_label('PP') );
SET @NOM_catid  = ( SELECT catid_by_label('NOM') );
SET @X_catid    = ( SELECT catid_by_label('X') );
SET @S_catid    = ( SELECT catid_by_label('S') );


/* PP -> P NP */
INSERT INTO rule ( target_id ) VALUES ( @PP_catid );
SET @this_rule_id = LAST_INSERT_ID();

INSERT INTO term ( rule_id, fact_count ) VALUES ( @this_rule_id, 2 );
SET @this_term_id = LAST_INSERT_ID();

INSERT INTO factor ( term_id,       position, optional, rpt )
            VALUES ( @this_term_id, '1',      0,        0 ),
                   ( @this_term_id, '2',      0,        0 );

/* VP -> V (NP) (PP) */
INSERT INTO rule ( target_id ) VALUES ( @VP_catid );
SET @this_rule_id = LAST_INSERT_ID();

INSERT INTO term ( rule_id, fact_count ) VALUES ( @this_rule_id, 3 );
SET @this_term_id = LAST_INSERT_ID();

INSERT INTO factor ( term_id,       position, optional, rpt )
            VALUES ( @this_term_id, '1',      0,        0 ),
                   ( @this_term_id, '2',      1,        0 ),
                   ( @this_term_id, '3',      1,        0 );

INSERT INTO term ( rule_id, fact_count ) VALUES ( @this_rule_id, 2 );
SET @this_term_id = LAST_INSERT_ID();

INSERT INTO factor ( term_id,       position, optional, rpt )
            VALUES ( @this_term_id, '1',      0,        0 ),
                   ( @this_term_id, '2',      0,        0 );

/* NOM -> N */
INSERT INTO rule ( target_id ) VALUES ( @NOM_catid );
SET @this_rule_id = LAST_INSERT_ID();

INSERT INTO term ( rule_id, fact_count ) VALUES ( @this_rule_id, 1 );
SET @this_term_id = LAST_INSERT_ID();

INSERT INTO factor ( term_id,       position, optional, rpt )
            VALUES ( @this_term_id, '1',      1,        0 );

/* NOM -> NOM PP */
INSERT INTO term ( rule_id, fact_count ) VALUES ( @this_rule_id, 2 );
SET @this_term_id = LAST_INSERT_ID();

INSERT INTO factor ( term_id,       position, optional, rpt )
            VALUES ( @this_term_id, '1',      0,        0 ),
                   ( @this_term_id, '2',      0,        0 );

/* NP -> (D) A* N P* */
INSERT INTO rule ( target_id ) VALUES ( @NP_catid );
SET @this_rule_id = LAST_INSERT_ID();

INSERT INTO term ( rule_id, fact_count ) VALUES ( @this_rule_id, 4 );
SET @this_term_id = LAST_INSERT_ID();

INSERT INTO factor ( term_id,       position, optional, rpt )
            VALUES ( @this_term_id, '1',      1,        0 ),
                   ( @this_term_id, '2',      1,        1 ),
                   ( @this_term_id, '3',      0,        0 ),
                   ( @this_term_id, '4',      1,        1 );

/* NP -> (D) NOM */
INSERT INTO term ( rule_id, fact_count ) VALUES ( @this_rule_id, 2 );
SET @this_term_id = LAST_INSERT_ID();

INSERT INTO factor ( term_id,       position, optional, rpt )
            VALUES ( @this_term_id, '1',      1,        0 ),
                   ( @this_term_id, '2',      0,        0 );

/* X -> X+ CONJ X */
INSERT INTO rule ( target_id ) VALUES ( @X_catid );
SET @this_rule_id = LAST_INSERT_ID();

INSERT INTO term ( rule_id, fact_count ) VALUES ( @this_rule_id, 3 );
SET @this_term_id = LAST_INSERT_ID();

INSERT INTO factor ( term_id,       position, optional, rpt )
            VALUES ( @this_term_id, '1',      0,        1 ),
                   ( @this_term_id, '2',      0,        0 ),
                   ( @this_term_id, '3',      0,        0 );

/* S -> NP VP */
INSERT INTO rule ( target_id ) VALUES ( @S_catid );
SET @this_rule_id = LAST_INSERT_ID();

INSERT INTO term ( rule_id, fact_count ) VALUES ( @this_rule_id, 2 );
SET @this_term_id = LAST_INSERT_ID();

INSERT INTO factor ( term_id,       position, optional, rpt )
            VALUES ( @this_term_id, '1',      0,        0 ),
                   ( @this_term_id, '2',      0,        0 );
