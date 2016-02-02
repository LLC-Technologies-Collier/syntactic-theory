#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;
use Test::Exception;

BEGIN {
  use_ok( 'Syntactic::Practice::Grammar::Category' ) || print "Bail out!\n";
}

use Syntactic::Practice::Grammar::Category::Terminal;
use Syntactic::Practice::Grammar::Category::NonTerminal;
use Syntactic::Practice::Grammar::Category::Lexical;
use Syntactic::Practice::Grammar::Category::Phrasal;
use Syntactic::Practice::Grammar::Category::Start;

my $ns = 'Syntactic::Practice::Grammar::Category';

diag(
"Testing $ns $Syntactic::Practice::Grammar::Category::VERSION, Perl $], $^X"
    );

my $start = "${ns}::Start"->new();
ok( $start, 'Start object was instantiated' );

ok( $start->is_terminal == 0, 'start category is not terminal' );
ok( $start->is_start, 'start category is start' );

my $validation_rx = qr/The label you provided, (\S+), is not a (\S+)/;

dies_ok( sub { $start->new(label => 'NP') }, 'dies on incorrect label' )
  or diag "Exception: [$@]";

like( $@, $validation_rx, 'Exception matches' ) or diag "Exception: [$@]";

my $phrcat = "${ns}::Phrasal"->new( label => 'NP');
ok( $phrcat, 'Phrasal category object was instantiated' );
ok( $phrcat->is_terminal == 0, 'phrasal category is not terminal' );
ok( $phrcat->is_start == 0, 'phrasal category is not start' );


dies_ok( sub { $phrcat->new(label => 'N') }, 'dies on incorrect label' )
  or diag "Exception: [$@]";

my $lexcat = "${ns}::Lexical"->new( label => 'D');
ok( $lexcat, 'Lexical category object was instantiated' );
ok( $lexcat->is_terminal, 'lexical category is terminal' );
ok( $lexcat->is_start == 0, 'lexical category is not start' );

dies_ok( sub { $lexcat->new(label => 'S') }, 'dies on incorrect label' )
  or diag "Exception: [$@]";

done_testing( 14 );
