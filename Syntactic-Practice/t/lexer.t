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

ok( $lexer, 'Lexer object instantiated' );

my @paragraph = $lexer->scan( $content );
my @sentence  = @{ $paragraph[0] };
my @token_list = @{ $sentence[0] };

is( scalar @token_list, 2, 'two tokens emitted by the lexer' );

isa_ok( $token_list[0], 'Syntactic::Practice::Tree' );

is( $token_list[0]->label, 'D', 'first token has label D' );


done_testing( 5 );
