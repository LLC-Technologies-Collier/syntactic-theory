#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

BEGIN {
  use Syntactic::Practice;

  use_ok( 'Syntactic::Practice::Grammar::TokenSet' ) || print "Bail out!\n";
}

diag(
"Testing Syntactic::Practice::Grammar::TokenSet $Syntactic::Practice::Grammar::TokenSet::VERSION, Perl $], $^X"
);

my $lexer = Syntactic::Practice::Lexer->new();

done_testing( 1 );
