#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

BEGIN {
  use Syntactic::Practice;

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
                            frompos  => 0,
                            mother => undef
                          );

is( scalar @tree, 1, 'one parse found' );

my $tree = $tree[0];
ok( $tree && $tree->label eq 'NP', 'Parse tree is rooted by a NP' );

is( $tree->frompos, 0, 'frompos is 0') or diag Data::Printer::p $tree;

my $s_cat = 'Syntactic::Practice::Grammar::Category::Start'->new;

@paragraph = $lexer->scan( 'The dog watched' );

$parser = Syntactic::Practice::Parser->new( sentence => $paragraph[0]->[0] );

ok( $parser, 'Parser instantiated with short S' );

@tree = $parser->ingest( category => $s_cat,
                         frompos  => 0,
                         mother => undef,
                       );

is( scalar @tree, 1, 'only one parse found' );

$tree = $tree[0];
ok( $tree && $tree->label eq 'S', 'Parse tree is rooted by an S' );
is( $tree && $tree->frompos, 0, 'from position is 0' ) or diag Data::Printer::p $tree;
is( $tree && $tree->topos, 3, 'to position is 3' ) or diag Data::Printer::p $tree;
my @daughters = $tree->daughters if $tree;

@paragraph = $lexer->scan( 'The big brown dog with fleas watched the birds beside the hunter' );

$parser = Syntactic::Practice::Parser->new( sentence => $paragraph[0]->[0] );

ok( $parser, 'Parser instantiated with ambiguous S' );

@tree = $parser->ingest( category => $s_cat,
                         frompos  => 0,
                         mother => undef
                       );

is( scalar @tree, 2, 'two parses found' );

$tree = $tree[0];
ok( $tree && $tree->label eq 'S', 'Parse tree is rooted by an S' );
is( $tree && $tree->frompos, 0, 'from position is 0' ) or diag Data::Printer::p $tree;
is( $tree && $tree->topos, 12, 'to position is 12' ) or diag Data::Printer::p $tree;

done_testing( 15 );
