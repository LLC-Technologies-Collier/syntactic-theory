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

  is( $l_tree->label,
      $lexemes->[0]->label,
      'Lexeme label was transferred to tree' );

  my @daughters = $l_tree->daughters;
  is( scalar @daughters, 1, 'one daughter of lexical tree' );

  push( @$sentence, $l_tree );

  my $copy = $l_tree->copy;
  ok( $copy, 'copy of lexical tree is defined' );
  isa_ok( $copy, "${tree_ns}::Abstract::Lexical", 'copy of tree' );
  @daughters = $copy->daughters;

  is( scalar @daughters, 1, 'one daughter of copy of lexical tree' );

  $treeByWord{$word} = $l_tree;
}

is( $sentence->[0]->label, 'D', 'First word recognized as a determiner' );
is( $sentence->[1]->label, 'N', 'Second word recognized as a noun' );
is( $sentence->[2]->label, 'V', 'Third word recognized as a verb' );

dies_ok( sub { "${tree_ns}::Abstract::Phrasal"->new( category => $np_cat ) },
         'dies when instantiated without a sentence' );

my $nom_tset = $tset->copy();
$nom_tset->append_new( $treeByWord{'dog'} );

my $nom_tree =
  "${tree_ns}::Abstract::Phrasal"->new( category     => $nom_cat,
                                        sentence     => $sentence,
                                        constituents => $nom_tset,
                                        daughters    => [ $treeByWord{'dog'} ],
  );

ok( $treeByWord{'dog'}->mother,
    q{mother of lexical tree for 'dog' has been set} );

ok( $treeByWord{'dog'}->factor,
    q{factor of lexical tree for 'dog' has been set} );

ok( $nom_tree, 'Abstract NOM tree instantiated' );
is( $nom_tree->label, 'NOM', 'NOM tree has NOM label' );

# TODO: ensure that trees' daughters are a valid combination for this category

my $np_tset = $tset->copy();
$np_tset->append_new( $treeByWord{'The'} );
$np_tset->append_new( $nom_tree );

my $np_tree =
  "${tree_ns}::Abstract::Phrasal"->new(
                                 category     => $np_cat,
                                 sentence     => $sentence,
                                 constituents => $np_tset,
                                 daughters => [ $treeByWord{'The'}, $nom_tree ],
  );

ok( $treeByWord{'dog'}->mother,
    q{mother of lexical tree for 'dog' has been set} );

ok( $treeByWord{'dog'}->factor,
    q{factor of lexical tree for 'dog' has been set} );

my $sisters;

lives_ok( sub { $sisters = $treeByWord{'The'}->sisters },
          'sisters method does not throw exception' );

ok( $sisters, q{sisters of lexical tree for 'The' has been set} );
ok( $np_tree, 'Abstract NP tree instantiated' );
is( $np_tree->label, 'NP', 'NP tree has NP label' );

my $vp_tset = $tset->copy();
$vp_tset->append_new( $treeByWord{'watched'} );

my $vp_tree =
  "${tree_ns}::Abstract::Phrasal"->new( category  => $vp_cat,
                                        sentence  => $sentence,
                                        constituents => $vp_tset,
                                        daughters => [ $treeByWord{'watched'} ],
  );
ok( $vp_tree, 'Abstract VP tree instantiated' );
is( $vp_tree->label, 'VP', 'VP tree has VP label' );

my $s_tset = $tset->copy();
$s_tset->append_new( $np_tree );
$s_tset->append_new( $vp_tree );


my $s_tree =
  "${tree_ns}::Abstract::Start"->new( sentence  => $sentence,
                                      daughters => [ $np_tree, $vp_tree ], );
ok( $s_tree, 'Abstract Start tree instantiated' );
is( $s_tree->label, 'S', 'S tree has S label' );

my $null_tree =
  "${tree_ns}::Abstract::Null"->new( category => $n_cat,
                                     sentence => $sentence );

ok( $null_tree, 'null tree instantiated' );

foreach my $tree ( @$sentence ) {
  my $concrete_lex_tree;
  lives_ok( sub { $concrete_lex_tree = $tree->to_concrete() },
            'to_concrete does not throw exception' );
  ok( $concrete_lex_tree,
      'abstract tree was successfully converted to concrete' );
}

done_testing( 47 );
