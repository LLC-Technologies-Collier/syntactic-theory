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

my $rule = Syntactic::Practice::Grammar::Rule->new( label => 'NOM' );

my $terms = $rule->terms;

my ( $term ) = ( grep { $_->factors->[0]->label eq 'A' } @$terms );

my ( @factors ) = @{ $term->factors };

ok( scalar @factors, q{factors returned for rule 'NOM'} );

my $adjective_factor = $factors[0];

ok( $adjective_factor, 'first factor is defined' )
  or diag Data::Printer::p @factors;

my $sym_term = $adjective_factor->term;

isa_ok( $sym_term, 'Syntactic::Practice::Grammar::Term' );

my $label = $adjective_factor->label;

is( $label, 'A', 'Adjective factor label is correct' );

ok( $sym_term->cmp( $term ) == 0, q{factor's term is as expected} );

my $lexer     = Syntactic::Practice::Lexer->new();
my @paragraph = $lexer->scan( 'big brown noisy old' );
my @tset      = @{ $paragraph[0] };
my $tokenset  = $tset[0];

my ( @tokenset ) = ( $adjective_factor->evaluate( tokenset => $tokenset ) );

is( scalar @tokenset, 5, 'four tokensets were found' );

is( $tokenset[0]->count, 1, 'first tokenset count is 1' );

isa_ok( $tokenset[0]->current->tree,
        'Syntactic::Practice::Tree::Abstract::Null',
        'tree of first token is a placeholder' ) or diag ref $tokenset[0]->current->tree;

is( $tokenset[1]->count, 1, 'second tokenset count is 1' );

is( $tokenset[2]->count, 2, 'third tokenset count is 2' );
is( $tokenset[3]->count, 3, 'fourth tokenset count is 3' );
is( $tokenset[4]->count, 4, 'fifth tokenset count is 4' );

done_testing( 13 );
