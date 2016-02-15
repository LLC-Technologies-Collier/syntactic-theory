#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

BEGIN {
  use Syntactic::Practice;

  use_ok( 'Syntactic::Practice::Grammar::Token' ) || print "Bail out!\n";
}

diag(
"Testing Syntactic::Practice::Grammar::Token $Syntactic::Practice::Grammar::Token::VERSION, Perl $], $^X"
);

my $homograph = Syntactic::Practice::Lexicon::Homograph->new( word => 'Dog' );

my $lexeme = $homograph->lexemes->[0];

my $sentence = [];

my $tree_class = 'Syntactic::Practice::Tree::Abstract::Lexical';

my $lexTree = $tree_class->new(
                                { daughters => $lexeme,
                                  frompos   => 0,
                                  category  => $lexeme->category,
                                  sentence  => $sentence,
                                } );

my $tset = Syntactic::Practice::Grammar::TokenSet->new();

is( $tset->count, 0, 'token set is empty' );

my $token =
  Syntactic::Practice::Grammar::Token->new( tree => $lexTree,
                                            set  => $tset );

push(@{$tset->tokens}, $token);

is( $tset->count, 1, 'token set has one element' )
  or diag join( ',', map { "$_" } @{ $tset->tokens } );

is( $tset->first, $token, 'token is first in set' );

is( $tset->last, $token, 'token is last in set' );

ok( defined $token->tree, q{Token's tree is defined} );

is( $token->tree <=> $lexTree, 0, q{Token's tree is $lexTree} );

is( $token->set <=> $tset, 0, q{token's set is $tset} );

ok( defined $token, 'token constructor returns a true value' );

like( $token->string, qr/dog/i, 'Token string renders correctly' );

like( "$token", qr/dog/i, 'Token string renders correctly' );

is( $tset->first, $token, 'First token of token set is $token' );
is( $tset->last,  $token, 'Last token of token set is $token' );

is( $token->next, undef, 'next token is undefined' );
is( $token->prev, undef, 'previous token is undefined' );

done_testing( 15 );
