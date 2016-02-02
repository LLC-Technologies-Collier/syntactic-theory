#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

use Syntactic::Practice::Grammar::RuleSet;

BEGIN {
  use_ok( 'Syntactic::Practice::Grammar::Rule' ) || print "Bail out!\n";
}

diag(
"Testing Syntactic::Practice::Grammar::Rule $Syntactic::Practice::Grammar::Rule::VERSION, Perl $], $^X"
);

my $ruleset = Syntactic::Practice::Grammar::RuleSet->new(label => 'S');

ok( $ruleset, 'RuleSet instantiated' );

my $rules = $ruleset->rules;

ok( $rules, 'ruleset->rules returns rules' );

isa_ok( $rules, 'ARRAY' );

ok( $rules->[0], 'First rule is defined' );

done_testing( 5 );
