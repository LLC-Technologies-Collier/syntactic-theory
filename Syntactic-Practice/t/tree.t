#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;
use Test::Exception;

BEGIN {
  use Syntactic::Practice;

  use_ok( 'Syntactic::Practice::Tree' ) || print "Bail out!\n";
}

my $num_tests = 1;

my $ns      = 'Syntactic::Practice';
my $tree_ns = "${ns}::Tree";
my $cat_ns  = "${ns}::Grammar::Category";

diag( "Testing ${ns}::Tree $Syntactic::Practice::Tree::VERSION, Perl $], $^X" );

my $np_cat  = "${cat_ns}::Phrasal"->new( label => 'NP' );
my $vp_cat  = "${cat_ns}::Phrasal"->new( label => 'VP' );
my $nom_cat = "${cat_ns}::Phrasal"->new( label => 'NOM' );
my $n_cat   = "${cat_ns}::Lexical"->new( label => 'N' );

my $sentence = [];

my $tset = Syntactic::Practice::Grammar::TokenSet->new();

my %treeByWord = ();

foreach my $word ( qw( The dog watched ) ) {

  my $lex_tset = $tset->copy();

  my $homograph = Syntactic::Practice::Lexicon::Homograph->new( word => $word );

  my $lexemes = $homograph->lexemes;

  my %params = ( category     => $lexemes->[0]->category,
                 daughters    => $lexemes->[0],
                 constituents => $tset->copy, );

  dies_ok( sub { "${tree_ns}::Abstract::Lexical"->new( %params ) },
           'dies when instantiated without a sentence' );

  my $l_tree =
    "${tree_ns}::Abstract::Lexical"->new( %params, sentence => $sentence );

  ok( $l_tree, 'lexical tree instantiated' );

  push( @$sentence, $l_tree );

  $treeByWord{$word} = $l_tree;
}

is( $sentence->[0]->label, 'D', 'First word recognized as a determiner' );
is( $sentence->[1]->label, 'N', 'Second word recognized as a noun' );
is( $sentence->[2]->label, 'V', 'Third word recognized as a verb' );

dies_ok( sub { "${tree_ns}::Abstract::Phrasal"->new( category => $np_cat ) },
         'dies when instantiated without a sentence' );

my $nom_tree =
  "${tree_ns}::Abstract::Phrasal"->new( category  => $nom_cat,
                                        sentence  => $sentence,
                                        daughters => [ $treeByWord{'dog'} ], );

ok( $nom_tree, 'Abstract NOM tree instantiated' );
is( $nom_tree->label, 'NOM', 'NOM tree has NOM label' );

# TODO: ensure that trees' daughters are a valid combination for this category

my $np_tree =
  "${tree_ns}::Abstract::Phrasal"->new(
                                  category  => $np_cat,
                                  sentence  => $sentence,
                                  daughters => [ $treeByWord{'The'}, $nom_tree ]
  );
ok( $np_tree, 'Abstract NP tree instantiated' );
is( $np_tree->label, 'NP', 'NP tree has NP label' );

my $vp_tree =
  "${tree_ns}::Abstract::Phrasal"->new( category  => $vp_cat,
                                        sentence  => $sentence,
                                        daughters => [ $treeByWord{'watched'} ],
  );
ok( $vp_tree, 'Abstract VP tree instantiated' );
is( $vp_tree->label, 'VP', 'VP tree has VP label' );

my $s_tree =
  "${tree_ns}::Abstract::Start"->new( sentence  => $sentence,
                                      daughters => [ $np_tree, $vp_tree ], );
ok( $s_tree, 'Abstract Start tree instantiated' );
is( $s_tree->label, 'S', 'S tree has S label' );

my $null_tree =
  "${tree_ns}::Abstract::Null"->new( category => $n_cat,
                                     sentence => $sentence );

ok( $null_tree, 'null tree instantiated' );

done_testing( 20 );
