#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

use Data::Dumper;

use Syntactic::Practice;

BEGIN {
  use_ok( 'Syntactic::Practice::Grammar::Symbol' ) || print "Bail out!\n";
}

diag(
"Testing Syntactic::Practice::Grammar::Symbol $Syntactic::Practice::Grammar::Symbol::VERSION, Perl $], $^X"
);

my $rule = Syntactic::Practice::Grammar::Rule->new( label => 'NP' );

my $terms = $rule->terms;

my $term = $terms->[0];

my @symbols = @{ $term->symbols };

ok( scalar @symbols, q{symbols returned for rule 'NP'} );

my $symbol = $symbols[0];

ok( $symbol, 'first symbol is defined' ) or diag Data::Dumper::Dumper \@symbols;

my $sym_term = $symbol->term;

isa_ok( $sym_term, 'Syntactic::Practice::Grammar::Term' );

my $label = $symbol->label;

ok( $sym_term->cmp( $term ) == 0, q{symbol's term is as expected} );

done_testing( 5 );
