#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

use Syntactic::Practice;

BEGIN {
  use_ok( 'Syntactic::Practice::Grammar::Rule' ) || print "Bail out!\n";
}

my $num_tests = 1;

diag(
"Testing Syntactic::Practice::Grammar::Rule $Syntactic::Practice::Grammar::Rule::VERSION, Perl $], $^X"
);

my $rule = Syntactic::Practice::Grammar::Rule->new(label => 'S');

ok( $rule, 'Rule instantiated' );
$num_tests++;

my $terms = $rule->terms;

ok( $terms, 'rule->terms returns terms' );
$num_tests++;

isa_ok( $terms, 'ARRAY', 'terms' );
$num_tests++;

my $num_terms = scalar @$terms;

foreach my $term ( @$terms ){
  ok( $term, 'Term is defined' );
  $num_tests++;
}

done_testing( $num_tests );
