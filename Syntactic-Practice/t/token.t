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

my $lexer = Syntactic::Practice::Lexer->new();

done_testing( 1 );
