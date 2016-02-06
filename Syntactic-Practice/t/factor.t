#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

use Data::Dumper;

BEGIN {
  use Syntactic::Practice;

  use_ok( 'Syntactic::Practice::Grammar::Factor' ) || print "Bail out!\n";
}

diag(
"Testing Syntactic::Practice::Grammar::Factor $Syntactic::Practice::Grammar::Factor::VERSION, Perl $], $^X"
);

my $rule = Syntactic::Practice::Grammar::Rule->new( label => 'NP' );

my $terms = $rule->terms;

my $term = $terms->[0];

my @factors = @{ $term->factors };

ok( scalar @factors, q{factors returned for rule 'NP'} );

my $factor = $factors[0];

ok( $factor, 'first factor is defined' ) or diag Data::Printer::p @factors;

my $sym_term = $factor->term;

isa_ok( $sym_term, 'Syntactic::Practice::Grammar::Term' );

my $label = $factor->label;

ok( $sym_term->cmp( $term ) == 0, q{factor's term is as expected} );

done_testing( 5 );
