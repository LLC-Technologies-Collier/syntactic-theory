#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;
use Test::Exception;

my $grammar_ns;

BEGIN {
  use Syntactic::Practice;

  $grammar_ns = 'Syntactic::Practice::Grammar';

  use_ok( "${grammar_ns}::TokenList" ) || print "Bail out!\n";
}

diag(
"Testing ${grammar_ns}::TokenList $Syntactic::Practice::Grammar::TokenList::VERSION, Perl $], $^X"
);

my $tset = "${grammar_ns}::TokenSet"->new();

my @array;
my $aref = tie @array, "${grammar_ns}::TokenList", $tset;

ok( $aref, 'Array reference was returned' );

is( $aref, tied @array,
    'value returned from tied() is the value returned from tie()' );

dies_ok( sub { tie my @a, "${grammar_ns}::TokenList", undef },
         'dies when called with undefined set' );

dies_ok( sub { tie my @a, "${grammar_ns}::TokenList" },
         'dies when called without set' );

done_testing( 5 );
