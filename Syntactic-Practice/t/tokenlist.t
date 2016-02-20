#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;
use Test::Exception;

my $grammar_ns;

BEGIN {
  use Syntactic::Practice;

  $grammar_ns = 'Syntactic::Practice::Grammar';

  use_ok( "${grammar_ns}::TokenList" ) || print "Bail out!\n";
}

diag(
"Testing ${grammar_ns}::TokenList $Syntactic::Practice::Grammar::TokenList::VERSION, Perl $], $^X"
);

Log::Log4perl->init( 'log4perl.conf' ) or die "couldn't init logger: $!";
my $logger = Log::Log4perl->get_logger();

my $tset = "${grammar_ns}::TokenSet"->new();

my @array;
my $aref = tie @array, "${grammar_ns}::TokenList", $tset;

ok( $aref, 'Array reference was returned' );

is( $aref, tied @array,
    'value returned from tied() is the value returned from tie()' );

dies_ok( sub { tie my @a, "${grammar_ns}::TokenList", undef },
         'dies when tied with undefined set' );

dies_ok( sub { tie my @a, "${grammar_ns}::TokenList" },
         'dies when tied without set' );

dies_ok( sub { push( @array, undef ) } , 'dies when a non-token is pushed' );

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

my $token =
  Syntactic::Practice::Grammar::Token->new( tree => $lexTree,
                                            set  => $tset );

ok( push( @array, $token ), 'can push token on to array' );

is( scalar @array, 1, 'one element in array' );

done_testing( 8 );
