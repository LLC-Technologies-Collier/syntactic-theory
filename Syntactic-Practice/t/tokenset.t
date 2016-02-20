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

my $logger = Log::Log4perl->get_logger();

my $grammar = Syntactic::Practice::Grammar->new( locale => 'en_US.UTF-8' );

my $lexer = Syntactic::Practice::Lexer->new();
my @paragraph = $lexer->scan( 'The dog watched' );
my $sentence = $paragraph[0]->[0];
my $n_cat = $grammar->category( label => 'N' );

my $tree = $sentence->[0];

my $tset = Syntactic::Practice::Grammar::TokenSet->new();

my $copy = $tset->copy();

my $tmp_tset = $tset->copy();

my $token =
  Syntactic::Practice::Grammar::Token->new( tree => $tree,
                                            set  => $tmp_tset );


ok( defined $tset, 'token set constructor returned a defined value' );
is( "$tset", '', 'empty token set stringifies to empty string');
isa_ok( $tset, 'Syntactic::Practice::Grammar::TokenSet', 'token set' );
is( $tset->count, 0, 'empty set has count of zero' );
is( $tset->first, undef, 'first element of empty set is undef' );
is( $tset->last, undef, 'last element of empty set is undef' );

$logger->debug('appending token now');
$tset->append( $token );
$logger->debug('token now appended');

is( $tset->count, 1, 'token set now has count of one' );

is( $tset->first, $tset->current, 'current token is first token' );

ok( defined $copy, 'copy method returns a true value' );
is( "$copy", '', 'empty token set stringifies to empty string');
isa_ok( $copy, 'Syntactic::Practice::Grammar::TokenSet', 'token set copy' );
is( $copy->count, 0, 'copy of empty set has count of zero' );
is( $copy->first, undef, 'first element of copy of empty set is undef' );
is( $copy->last, undef, 'last element of copy of empty set is undef' );



# #$copy->append_new( $tree );
# $copy->append( $token, 0 );
# $tset->append_new( $tree );

is( $tset->count, 1, 'token set now has count of one' );
# isnt( $tset->first, undef, 'first element of token set is no longer undef' );
# isnt( $tset->last, undef, 'last element of token set is no longer undef' );

# is( $copy->count, 1, 'copy of token set now has count of one' );
# isnt( $copy->first, undef, 'first element of copy of token set is no longer undef' );
# isnt( $copy->last, undef, 'last element of copy of token set is no longer undef' );

#my $tsetRef = $tset->append( $copy, 0 );

#isnt( $copy, undef, 'appending token set B to token set A with second argument 0 does not undefine B' );


done_testing( 16 );
