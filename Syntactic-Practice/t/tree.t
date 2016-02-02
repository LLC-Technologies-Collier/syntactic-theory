#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

BEGIN {
  use_ok( 'Syntactic::Practice::Tree' ) || print "Bail out!\n";
}

use Syntactic::Practice::Grammar::Category::Terminal;
use Syntactic::Practice::Grammar::Category::NonTerminal;
use Syntactic::Practice::Grammar::Category::Lexical;
use Syntactic::Practice::Grammar::Category::Phrasal;
use Syntactic::Practice::Grammar::Category::Start;

use Syntactic::Practice::Tree::Terminal;
use Syntactic::Practice::Tree::NonTerminal;
use Syntactic::Practice::Tree::Lexical;
use Syntactic::Practice::Tree::Phrasal;
use Syntactic::Practice::Tree::Start;
use Syntactic::Practice::Tree::Null;

use Syntactic::Practice::Tree::Abstract::Terminal;
use Syntactic::Practice::Tree::Abstract::NonTerminal;
use Syntactic::Practice::Tree::Abstract::Lexical;
use Syntactic::Practice::Tree::Abstract::Phrasal;
use Syntactic::Practice::Tree::Abstract::Start;
use Syntactic::Practice::Tree::Abstract::Null;

use Syntactic::Practice::Lexicon::Homograph;

my $ns      = 'Syntactic::Practice';
my $tree_ns = "${ns}::Tree";
my $cat_ns  = "${ns}::Grammar::Category";

diag( "Testing ${ns}::Tree $Syntactic::Practice::Tree::VERSION, Perl $], $^X" );

my $np_cat = "${cat_ns}::Phrasal"->new( label => 'NP' );
my $n_cat  = "${cat_ns}::Lexical"->new( label => 'N' );
my $s_cat = "${cat_ns}::Start"->new( label => 'S' );

my $np_tree = "${tree_ns}::Abstract::Phrasal"->new( category => $np_cat );
ok( $np_tree, 'Abstract Noun Phrase tree instantiated' );

my $s_tree = "${tree_ns}::Abstract::Start"->new();
ok( $s_tree, 'Abstract Start tree instantiated' );

my $homograph = Syntactic::Practice::Lexicon::Homograph->new( word => 'Dog' );

my $lexemes = $homograph->lexemes;

my $l_tree =
  "${tree_ns}::Abstract::Lexical"->new( category  => $n_cat,
                                        daughters => $lexemes->[0] );

ok( $l_tree, 'lexical tree instantiated' );

my $null_tree = "${tree_ns}::Abstract::Null"->new( category  => $n_cat );

ok( $null_tree, 'null tree instantiated' );

done_testing( 5 );
