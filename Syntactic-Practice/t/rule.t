#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

BEGIN {
  use Syntactic::Practice;

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

my @expansions = $rule->expansions();

TODO: {
  local $TODO = 'I cannot be arsed to get the expansions working right now';
  ok( @expansions, 'call to expansions returns a value' );
  $num_tests++;
  isa_ok( $expansions[0], 'ARRAY', 'first expansions list' );
  $num_tests++;
};

$rule = Syntactic::Practice::Grammar::Rule->new(label => 'NOM');

$terms = $rule->terms;

is( scalar @$terms, 2, 'Two terms for rule NOM' );
$num_tests++;

my $bnf = $rule->bnf;

ok( $bnf, 'BNF was generated' );

$num_tests++;

diag $bnf;

$rule = Syntactic::Practice::Grammar->new->rule( label => 'S' );

my $lexer = Syntactic::Practice::Lexer->new();

ok( $lexer, 'Lexer object instantiated' );
$num_tests++;

my @paragraph = $lexer->scan( 'The big brown dog with fleas watched the birds beside the hunter' );
my @sentence   = @{ $paragraph[0] };
my @token_list = @{ $sentence[0] };


my $depth = $rule->terms->[0]->factors->[0]->licenses( $token_list[5] );

ok( defined $depth, 'depth is defined' );
$num_tests++;

is( $depth, 5, 'depth is correct' );
$num_tests++;

diag $depth;

done_testing( $num_tests );
