#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

use Syntactic::Practice;

BEGIN {
  use_ok( 'Syntactic::Practice::Parser' ) || print "Bail out!\n";
}

diag(
"Testing Syntactic::Practice::Parser $Syntactic::Practice::Parser::VERSION, Perl $], $^X"
);

my $content = "The dog";

my $lexer = Syntactic::Practice::Lexer->new();

my @paragraph = $lexer->scan( 'The dog' );

my $np_cat =
  'Syntactic::Practice::Grammar::Category::Phrasal'->new( label => 'NP' );

my $parser =
  Syntactic::Practice::Parser->new( sentence => $paragraph[0]->[0] );

ok( $parser, 'Parser instantiated with short NP' );

my @tree = $parser->ingest( category => $np_cat,
                            frompos  => 0 );

is( scalar @tree, 1, 'only one parse found' );

my $tree = $tree[0];
ok( $tree->label eq 'NP', 'Parse tree is rooted by a NP' );

my $s_cat = 'Syntactic::Practice::Grammar::Category::Start'->new;

@paragraph = $lexer->scan( 'The dog watched' );

$parser = Syntactic::Practice::Parser->new( sentence => $paragraph[0]->[0] );

ok( $parser, 'Parser instantiated with short S' );

@tree = $parser->ingest( category => $s_cat,
                         frompos  => 0 );

is( scalar @tree, 1, 'only one parse found' );

$tree = $tree[0];
ok( $tree->label eq 'S', 'Parse tree is rooted by an S' );
is( $tree->frompos, 0, 'from position is 0' ) or diag $tree->frompos;
is( $tree->topos, 3, 'to position is 3' ) or diag $tree->topos;
my @daughters = $tree->daughters;

@paragraph = $lexer->scan( 'The big brown dog with fleas watched the birds beside the hunter' );

$parser = Syntactic::Practice::Parser->new( sentence => $paragraph[0]->[0] );

ok( $parser, 'Parser instantiated with ambiguous S' );

@tree = $parser->ingest( category => $s_cat,
                         frompos  => 0 );

is( scalar @tree, 2, 'two parses found' );

$tree = $tree[0];
ok( $tree->label eq 'S', 'Parse tree is rooted by an S' );
is( $tree->frompos, 0, 'from position is 0' ) or diag $tree->frompos;
is( $tree->topos, 12, 'to position is 12' ) or diag $tree->topos;

done_testing( 14 );
