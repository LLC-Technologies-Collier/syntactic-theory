/* Copyright 2015 Collier Technologies LLC */

DELETE FROM _phrasal_category;
DELETE FROM phrasal_category_;
DELETE FROM _lexical_category;
DELETE FROM lexical_category_;
DELETE FROM syntactic_category;
DELETE FROM lexeme;

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
       ( 'Prepositional Phrase', 'PP',   ( SELECT catid_by_label('P')   ) );


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
