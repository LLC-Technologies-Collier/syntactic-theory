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

my $ruleset = Syntactic::Practice::Grammar::RuleSet->new( label => 'NP' );

my $rules = $ruleset->rules;

my $rule = $rules->[0];

my @symbols = @{ $rule->symbols };

ok( scalar @symbols, q{symbols returned for rule 'NP'} );

my $symbol = $symbols[0];

ok( $symbol, 'first symbol is defined' ) or diag Data::Dumper::Dumper \@symbols;

my $sym_rule = $symbol->rule;

isa_ok( $sym_rule, 'Syntactic::Practice::Grammar::Rule' );

my $label = $symbol->label;

ok( $sym_rule->cmp( $rule ) == 0, q{symbol's rule is as expected} );

done_testing( 5 );
