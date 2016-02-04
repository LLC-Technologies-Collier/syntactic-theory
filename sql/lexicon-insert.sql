/* Copyright 2015, 2016 Collier Technologies LLC */
DELETE FROM lexeme;

SET @determiner_catid  = ( SELECT catid_by_label('D') );
SET @adjective_catid   = ( SELECT catid_by_label('A') );
SET @adverb_catid      = ( SELECT catid_by_label('Adv') );
SET @noun_catid        = ( SELECT catid_by_label('N') );
SET @conj_catid        = ( SELECT catid_by_label('CONJ') );
SET @verb_catid        = ( SELECT catid_by_label('V') );
SET @preposition_catid = ( SELECT catid_by_label('P') );

INSERT INTO lexeme ( word,         cat_id )
            VALUES ( 'a',          @determiner_catid ),
                   ( 'no',         @determiner_catid ),
                   ( 'some',       @determiner_catid ),
                   ( 'the',        @determiner_catid ),
                   ( 'this',       @determiner_catid ),
                   ( 'most',       @determiner_catid ),
                   ( 'my',         @determiner_catid ),

                   ( 'and',        @conj_catid ),
                   ( 'or',         @conj_catid ),
                   ( 'but',        @conj_catid ),

                   ( 'big',        @adjective_catid ),
                   ( 'brown',      @adjective_catid ),
                   ( 'noisy',      @adjective_catid ),
                   ( 'old',        @adjective_catid ),
                   ( 'small',      @adjective_catid ),

                   ( 'never',      @adverb_catid ),

                   ( 'astronomer', @noun_catid ),
                   ( 'animals',    @noun_catid ),
                   ( 'birds',      @noun_catid ),
                   ( 'bone',       @noun_catid ),
                   ( 'children',   @noun_catid ),
                   ( 'cat',        @noun_catid ),
                   ( 'cats',       @noun_catid ),
                   ( 'disease',    @noun_catid ),
                   ( 'dog',        @noun_catid ),
                   ( 'dogs',       @noun_catid ),
                   ( 'drawing',    @noun_catid ),
                   ( 'drugs',      @noun_catid ),
                   ( 'fleas',      @noun_catid ),
                   ( 'fool',       @noun_catid ),
                   ( 'hunter',     @noun_catid ),
                   ( 'I',          @noun_catid ),
                   ( 'Klee',       @noun_catid ),
                   ( 'Leslie',     @noun_catid ),
                   ( 'life',       @noun_catid ),
                   ( 'love',       @noun_catid ),
                   ( 'Miro',       @noun_catid ),
                   ( 'movie',      @noun_catid ),
                   ( 'museum',     @noun_catid ),
                   ( 'neighbor',   @noun_catid ),
                   ( 'painting',   @noun_catid ),
                   ( 'people',     @noun_catid ),
                   ( 'protest',    @noun_catid ),
                   ( 'room',       @noun_catid ),
                   ( 'Rome',       @noun_catid ),
                   ( 'tail',       @noun_catid ),
                   ( 'telescope',  @noun_catid ),
                   ( 'tourist',    @noun_catid ),
                   ( 'wombat',     @noun_catid ),

                   ( 'ate',        @verb_catid ),
                   ( 'attack',     @verb_catid ),
                   ( 'be',         @verb_catid ),
                   ( 'chase',      @verb_catid ),
                   ( 'chased',     @verb_catid ),
                   ( 'displayed',  @verb_catid ),
                   ( 'filled',     @verb_catid ),
                   ( 'gave',       @verb_catid ),
                   ( 'locked',     @verb_catid ),
                   ( 'saw',        @verb_catid ),
                   ( 'use',        @verb_catid ),
                   ( 'watched',    @verb_catid ),
                   ( 'was',        @verb_catid ),
                   ( 'would',      @verb_catid ),
                   ( 'yelled',     @verb_catid ),

                   ( 'at',         @preposition_catid ),
                   ( 'by',         @preposition_catid ),
                   ( 'beside',     @preposition_catid ),
                   ( 'for',        @preposition_catid ),
                   ( 'of',         @preposition_catid ),
                   ( 'on',         @preposition_catid ),
                   ( 'in',         @preposition_catid ),
                   ( 'with',       @preposition_catid );
