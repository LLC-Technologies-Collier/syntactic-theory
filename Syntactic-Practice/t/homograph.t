#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

BEGIN {
  use Syntactic::Practice;

  use_ok( 'Syntactic::Practice::Lexicon::Homograph' ) || print "Bail out!\n";
}

my $homograph = Syntactic::Practice::Lexicon::Homograph->new( word => 'dog' );

ok( $homograph, 'homograph object instantiated' );

my $lexemes = $homograph->lexemes;

ok( $lexemes, 'lexemes attribute returns lexemes object' );

isa_ok( $lexemes, 'ARRAY' );

done_testing( 4 );
