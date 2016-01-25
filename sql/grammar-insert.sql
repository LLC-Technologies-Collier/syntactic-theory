/* Copyright 2015, 2016 Collier Technologies LLC */
DELETE FROM lexeme;

DELETE FROM rule_node;
DELETE FROM phrase_structure_rule;
DELETE FROM _phrasal_category;
DELETE FROM phrasal_category_;
DELETE FROM _lexical_category;
DELETE FROM lexical_category_;
DELETE FROM syntactic_category;

INSERT INTO lexical_category_ ( label, longname )
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

INSERT INTO phrasal_category_
       ( longname,               label,  head_cat_id )
VALUES ( 'Determiner Phrase',    'DP',   @determiner_catid ),
       ( 'Adjective Phrase',     'AP',   @adjective_catid ),
       ( 'Adverb Phrase',        'AdvP', @adverb_catid ),
       ( 'Noun Phrase',          'NP',   @noun_catid ),
       ( 'Verb Phrase',          'VP',   @verb_catid ),
       ( 'Prepositional Phrase', 'PP',   @preposition_catid ),
       ( 'Nominal',              'NOM',  @noun_catid ),
       ( 'Wildcard',             'X',    NULL ),
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
INSERT INTO phrase_structure_rule ( target_id, node_count )
                           VALUES ( @PP_catid, 2 );
SET @this_rule_id = LAST_INSERT_ID();
INSERT INTO rule_node ( rule_id,       position, cat_id,             optional, rpt )
               VALUES ( @this_rule_id, '1',      @preposition_catid, 0,        0 ),
                      ( @this_rule_id, '2',      @NP_catid,          0,        0 );

/* VP -> V (NP) (PP) */
INSERT INTO phrase_structure_rule ( target_id, node_count )
                           VALUES ( @VP_catid, 3 );
SET @this_rule_id = LAST_INSERT_ID();
INSERT INTO rule_node ( rule_id,       position, cat_id,      optional, rpt )
               VALUES ( @this_rule_id, '1',      @verb_catid, 0,        0 ),
                      ( @this_rule_id, '2',      @NP_catid,   1,        0 ),
                      ( @this_rule_id, '3',      @PP_catid,   1,        0 );

/* VP -> VP PP */
INSERT INTO phrase_structure_rule ( target_id, node_count )
                           VALUES ( @VP_catid, 2 );
SET @this_rule_id = LAST_INSERT_ID();
INSERT INTO rule_node ( rule_id,       position, cat_id,      optional, rpt )
               VALUES ( @this_rule_id, '1',      @VP_catid,   0,        0 ),
                      ( @this_rule_id, '2',      @PP_catid,   0,        0 );

/* NOM -> N */
INSERT INTO phrase_structure_rule ( target_id, node_count )
                           VALUES ( @NOM_catid, 1 );
SET @this_rule_id = LAST_INSERT_ID();
INSERT INTO rule_node ( rule_id,       position, cat_id,            optional, rpt )
               VALUES ( @this_rule_id, '1',      @noun_catid,       1,        0 );

/* NOM -> NOM PP */
INSERT INTO phrase_structure_rule ( target_id, node_count )
                           VALUES ( @NOM_catid, 2 );
SET @this_rule_id = LAST_INSERT_ID();
INSERT INTO rule_node ( rule_id,       position, cat_id,            optional, rpt )
               VALUES ( @this_rule_id, '1',      @NOM_catid,        0,        0 ),
                      ( @this_rule_id, '2',      @PP_catid,         0,        0 );

/* NP -> (D) A* N P* */
INSERT INTO phrase_structure_rule ( target_id, node_count )
                           VALUES ( @NP_catid, 4 );
SET @this_rule_id = LAST_INSERT_ID();
INSERT INTO rule_node ( rule_id,       position, cat_id,            optional, rpt )
               VALUES ( @this_rule_id, '1',      @determiner_catid, 1,        0 ),
                      ( @this_rule_id, '2',      @adjective_catid,  1,        1 ),
                      ( @this_rule_id, '3',      @noun_catid,       0,        0 ),
                      ( @this_rule_id, '4',      @PP_catid,         1,        1 );

/* NP -> (D) NOM */
INSERT INTO phrase_structure_rule ( target_id, node_count )
                           VALUES ( @NP_catid, 2 );
SET @this_rule_id = LAST_INSERT_ID();
INSERT INTO rule_node ( rule_id,       position, cat_id,            optional, rpt )
               VALUES ( @this_rule_id, '1',      @determiner_catid, 1,        0 ),
                      ( @this_rule_id, '2',      @NOM_catid,        0,        0 );

/* X -> X+ CONJ X */
INSERT INTO phrase_structure_rule ( target_id, node_count )
                           VALUES ( @X_catid, 3 );
SET @this_rule_id = LAST_INSERT_ID();
INSERT INTO rule_node ( rule_id,       position, cat_id,            optional, rpt )
               VALUES ( @this_rule_id, '1',      @X_catid,          0,        1 ),
                      ( @this_rule_id, '2',      @CONJ_catid,       0,        0 ),
                      ( @this_rule_id, '3',      @X_catid,          0,        0 );

/* S -> NP VP */
INSERT INTO phrase_structure_rule ( target_id, node_count )
                           VALUES ( ( SELECT catid_by_label('S') ), 2 );
SET @this_rule_id = LAST_INSERT_ID();
INSERT INTO rule_node ( rule_id,       position, cat_id,    optional, rpt )
               VALUES ( @this_rule_id, '1',      @NP_catid, 0,        0 ),
                      ( @this_rule_id, '2',      @VP_catid, 0,        0 );
