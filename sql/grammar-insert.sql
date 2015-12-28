/* Copyright 2015 Collier Technologies LLC */

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

INSERT INTO phrasal_category_
       ( longname, label, head_lcat_id )
VALUES ( 'Adjective Phrase',     'AP',   ( SELECT catid_by_label('A')   ) ),
       ( 'Adverb Phrase',        'AdvP', ( SELECT catid_by_label('Adv') ) ),
       ( 'Noun Phrase',          'NP',   ( SELECT catid_by_label('N')   ) ),
       ( 'Verb Phrase',          'VP',   ( SELECT catid_by_label('V')   ) ),
       ( 'Prepositional Phrase', 'PP',   ( SELECT catid_by_label('P')   ) ),
       ( 'Sentence',             'S',    ( SELECT catid_by_label('N')   ) );


INSERT INTO lexeme ( word, pos_id )
            VALUES ( 'the',     ( SELECT catid_by_label('D') ) ),
	           ( 'some',    ( SELECT catid_by_label('D') ) ),
		   ( 'big',     ( SELECT catid_by_label('A') ) ),
		   ( 'brown',   ( SELECT catid_by_label('A') ) ),
		   ( 'old',     ( SELECT catid_by_label('A') ) ),
		   ( 'birds',   ( SELECT catid_by_label('N') ) ),
		   ( 'fleas',   ( SELECT catid_by_label('N') ) ),
		   ( 'dog',     ( SELECT catid_by_label('N') ) ),
		   ( 'hunter',  ( SELECT catid_by_label('N') ) ),
		   ( 'attack',  ( SELECT catid_by_label('V') ) ),
		   ( 'ate',     ( SELECT catid_by_label('V') ) ),
		   ( 'watched', ( SELECT catid_by_label('V') ) ),
		   ( 'for',     ( SELECT catid_by_label('P') ) ),
		   ( 'beside',  ( SELECT catid_by_label('P') ) ),
		   ( 'with',    ( SELECT catid_by_label('P') ) );

INSERT INTO phrase_structure_rule ( target_id, node_count )
                           VALUES ( ( SELECT catid_by_label('PP') ), 2 );

SET @this_rule_id = LAST_INSERT_ID();

INSERT INTO rule_node ( rule_id,       position, scat_id,                         optional, rpt )
               VALUES ( @this_rule_id, '1',      ( SELECT catid_by_label('P')  ), b'0',     b'0' ),
                      ( @this_rule_id, '2',      ( SELECT catid_by_label('NP') ), b'0',     b'0' );

INSERT INTO phrase_structure_rule ( target_id, node_count )
                           VALUES ( ( SELECT catid_by_label('VP') ), 3 );

SET @this_rule_id = LAST_INSERT_ID();

INSERT INTO rule_node ( rule_id,       position, scat_id,                         optional, rpt )
               VALUES ( @this_rule_id, '1',      ( SELECT catid_by_label('V')  ), b'0',     b'0' ),
                      ( @this_rule_id, '2',      ( SELECT catid_by_label('NP') ), b'1',     b'0' ),
                      ( @this_rule_id, '3',      ( SELECT catid_by_label('PP') ), b'1',     b'0' );

INSERT INTO phrase_structure_rule ( target_id, node_count )
                           VALUES ( ( SELECT catid_by_label('NP') ), 4 );

SET @this_rule_id = LAST_INSERT_ID();

INSERT INTO rule_node ( rule_id,       position, scat_id,                         optional, rpt )
               VALUES ( @this_rule_id, '1',      ( SELECT catid_by_label('D')  ), b'1',     b'0' ),
                      ( @this_rule_id, '2',      ( SELECT catid_by_label('A')  ), b'1',     b'1' ),
                      ( @this_rule_id, '3',      ( SELECT catid_by_label('N')  ), b'0',     b'0' ),
                      ( @this_rule_id, '4',      ( SELECT catid_by_label('PP') ), b'1',     b'1' );

INSERT INTO phrase_structure_rule ( target_id, node_count )
                           VALUES ( ( SELECT catid_by_label('S') ), 2 );

SET @this_rule_id = LAST_INSERT_ID();

INSERT INTO rule_node ( rule_id,       position, scat_id,                         optional, rpt )
               VALUES ( @this_rule_id, '1',      ( SELECT catid_by_label('NP') ), b'0',     b'0' ),
                      ( @this_rule_id, '2',      ( SELECT catid_by_label('VP') ), b'0',     b'0' );
