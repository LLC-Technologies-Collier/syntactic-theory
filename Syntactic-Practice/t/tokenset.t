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

my $tset = Syntactic::Practice::Grammar::TokenSet->new();

ok( $tset, 'token set constructor returned a true value' );
isa_ok( $tset, 'Syntactic::Practice::Grammar::TokenSet', 'token set' );
is( $tset->count, 0, 'empty set has count of zero' );
is( $tset->first, undef, 'first element of empty set is undef' );
is( $tset->last, undef, 'last element of empty set is undef' );

my $copy = $tset->copy();

ok( $copy, 'copy method returns a true value' );
isa_ok( $copy, 'Syntactic::Practice::Grammar::TokenSet', 'token set copy' );
is( $copy->count, 0, 'copy of empty set has count of zero' );
is( $copy->first, undef, 'first element of copy of empty set is undef' );
is( $copy->last, undef, 'last element of copy of empty set is undef' );

my $lexer = Syntactic::Practice::Lexer->new();
my @paragraph = $lexer->scan( 'Dog' );
my $grammar = Syntactic::Practice::Grammar->new( locale => 'en_US.UTF-8' );
my $sentence = $paragraph[0]->[0];
my $n_cat = $grammar->category( label => 'N' );

my $tree = $sentence->[0];

my $tk = Syntactic::Practice::Grammar::Token->new( set  => $tset,
                                                   tree => $tree
                                                 );

is( $tset->count, 1, 'token set now has count of one' );
isnt( $tset->first, undef, 'first element of token set is no longer undef' );
isnt( $tset->last, undef, 'last element of token set is no longer undef' );

done_testing( 14 );
