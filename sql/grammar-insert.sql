/* Copyright 2015, 2016 Collier Technologies LLC */

DELETE FROM rule_node;
DELETE FROM phrase_structure_rule;
DELETE FROM _phrasal_category;
DELETE FROM phrasal_category_;
DELETE FROM lexeme;
DELETE FROM _lexical_category;
DELETE FROM lexical_category_;
DELETE FROM syntactic_category;

INSERT INTO lexical_category_ ( label, longname )
            VALUES ( 'D',   'Determiner' ),
                   ( 'A',   'Adjective' ),
                   ( 'Adv', 'Adverb' ),
                   ( 'N',   'Noun' ),
                   ( 'V',   'Verb' ),
                   ( 'P',   'Preposition' );

SET @determiner_catid  = ( SELECT catid_by_label('D') );
SET @adjective_catid   = ( SELECT catid_by_label('A') );
SET @adverb_catid      = ( SELECT catid_by_label('Adv') );
SET @noun_catid        = ( SELECT catid_by_label('N') );
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
       ( 'Sentence',             'S',    @noun_catid ); /* probably wrong... */

SET @AP_catid   = ( SELECT catid_by_label('AP') );
SET @AdvP_catid = ( SELECT catid_by_label('AdvP') );
SET @NP_catid   = ( SELECT catid_by_label('NP') );
SET @VP_catid   = ( SELECT catid_by_label('VP') );
SET @PP_catid   = ( SELECT catid_by_label('PP') );
SET @S_catid    = ( SELECT catid_by_label('S') );


INSERT INTO lexeme ( word, cat_id )
VALUES ( 'the',        @determiner_catid ),
       ( 'a',          @determiner_catid ),
       ( 'some',       @determiner_catid ),
       ( 'big',        @adjective_catid ),
       ( 'brown',      @adjective_catid ),
       ( 'old',        @adjective_catid ),
       ( 'birds',      @noun_catid ),
       ( 'fleas',      @noun_catid ),
       ( 'dog',        @noun_catid ),
       ( 'hunter',     @noun_catid ),
       ( 'I',          @noun_catid ),
       ( 'astronomer', @noun_catid ),
       ( 'telescope',  @noun_catid ),
       ( 'attack',     @verb_catid ),
       ( 'saw',        @verb_catid ),
       ( 'ate',        @verb_catid ),
       ( 'watched',    @verb_catid ),
       ( 'for',        @preposition_catid ),
       ( 'beside',     @preposition_catid ),
       ( 'with',       @preposition_catid );

INSERT INTO phrase_structure_rule ( target_id, node_count )
                           VALUES ( @PP_catid, 2 );

SET @this_rule_id = LAST_INSERT_ID();

INSERT INTO rule_node ( rule_id,       position, cat_id,             optional, rpt )
               VALUES ( @this_rule_id, '1',      @preposition_catid, 0,        0 ),
                      ( @this_rule_id, '2',      @NP_catid,          0,        0 );

INSERT INTO phrase_structure_rule ( target_id, node_count )
                           VALUES ( @VP_catid, 3 );

SET @this_rule_id = LAST_INSERT_ID();

INSERT INTO rule_node ( rule_id,       position, cat_id,      optional, rpt )
               VALUES ( @this_rule_id, '1',      @verb_catid, 0,        0 ),
                      ( @this_rule_id, '2',      @NP_catid,   1,        0 ),
                      ( @this_rule_id, '3',      @PP_catid,   1,        0 );

INSERT INTO phrase_structure_rule ( target_id, node_count )
                           VALUES ( @NP_catid, 4 );

SET @this_rule_id = LAST_INSERT_ID();

INSERT INTO rule_node ( rule_id,       position, cat_id,            optional, rpt )
               VALUES ( @this_rule_id, '1',      @determiner_catid, 1,        0 ),
                      ( @this_rule_id, '2',      @adjective_catid,  1,        1 ),
                      ( @this_rule_id, '3',      @noun_catid,       0,        0 ),
                      ( @this_rule_id, '4',      @PP_catid,         1,        1 );

INSERT INTO phrase_structure_rule ( target_id, node_count )
                           VALUES ( ( SELECT catid_by_label('S') ), 2 );

SET @this_rule_id = LAST_INSERT_ID();

INSERT INTO rule_node ( rule_id,       position, cat_id,    optional, rpt )
               VALUES ( @this_rule_id, '1',      @NP_catid, 0,        0 ),
                      ( @this_rule_id, '2',      @VP_catid, 0,        0 );
