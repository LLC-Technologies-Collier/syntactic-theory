#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;
use Test::Exception;

BEGIN {
  use Syntactic::Practice;
  use_ok( 'Syntactic::Practice::Grammar::Category' ) || print "Bail out!\n";
}

my $ns = 'Syntactic::Practice::Grammar::Category';

diag(
    "Testing $ns $Syntactic::Practice::Grammar::Category::VERSION, Perl $], $^X"
);

my $start = "${ns}::Start"->new();
ok( $start, 'Start object was instantiated' );

ok( $start->is_terminal == 0, 'start category is not terminal' );
ok( $start->is_start,         'start category is start' );

my $validation_rx =
#  qr/Attribute \((.+?)\) .* type constraint .* '(.+?)' with value "(.+?)"/;
qr/Attribute \((.+?)\) .* type constraint .* label you provided, (.+?), is not a (.+?)\s/;

dies_ok( sub { $start->new( label => 'NP' ) }, 'dies on incorrect label' )
  or diag "Exception: [$@]";

my $exception = $@;
like( $exception, $validation_rx, 'Exception matches' ) or diag "Exception: [$@]";

my( $name, $value, $constraint ) =  ( $exception =~ m/$validation_rx/ims );

ok( $name eq 'label', 'attribute name recognized' );
ok( $constraint eq 'StartCategoryLabel', 'constraint recognized' );
ok( $value eq 'NP', 'attribute value recognized' );

my $phrcat = "${ns}::Phrasal"->new( label => 'NP' );
ok( $phrcat,                   'Phrasal category object was instantiated' );
ok( $phrcat->is_terminal == 0, 'phrasal category is not terminal' );
ok( $phrcat->is_start == 0,    'phrasal category is not start' );

dies_ok( sub { $phrcat->new( label => 'N' ) }, 'dies on incorrect label' )
  or diag "Exception: [$@]";

my $lexcat = "${ns}::Lexical"->new( label => 'D' );
ok( $lexcat,                'Lexical category object was instantiated' );
ok( $lexcat->is_terminal,   'lexical category is terminal' );
ok( $lexcat->is_start == 0, 'lexical category is not start' );

dies_ok( sub { $lexcat->new( label => 'S' ) }, 'dies on incorrect label' )
  or diag "Exception: [$@]";

done_testing( 17 );
