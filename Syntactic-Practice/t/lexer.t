#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

BEGIN {
    use_ok( 'Syntactic::Practice::Lexer' ) || print "Bail out!\n";
}

diag( "Testing Syntactic::Practice::Lexer $Syntactic::Practice::Lexer::VERSION, Perl $], $^X" );

my $content = "The dog";

my $lexer     = Syntactic::Practice::Lexer->new();

my @paragraph = $lexer->scan( $content );
my @sentence  = @{ $paragraph[0] };
my @word_list = @{ $sentence[0] };

is( scalar @word_list, 2 );

isa_ok( $word_list[0], 'Syntactic::Practice::Tree' );

is( $word_list[0]->label, 'D' );


done_testing( 4 );
