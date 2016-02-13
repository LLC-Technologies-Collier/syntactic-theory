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

my $token =
  Syntactic::Practice::Grammar::Token->new( tree => $lexTree,
                                            set  => $tset );

ok( defined $token, 'token constructor returns a true value' );

like( $token->string, qr/dog/i, 'Token string renders correctly' );

#is( $token->next, undef, 'next token is undefined' );
#is( $token->prev, undef, 'previous token is undefined' );

done_testing( 3 );
