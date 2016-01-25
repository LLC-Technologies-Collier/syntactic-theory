package Syntactic::Practice::Lexer;

use strict;
use Syntactic::Practice::Tree::Lexical;
use Moose;

sub scan {
  my ( $self, $input ) = @_;

  chomp $input;

  my @paragraph;
  foreach my $paragraph ( split( /\n\n+/, $input ) ) {
    my @sentence;
    foreach my $sentence ( split( /\.\s+/, $paragraph ) ) {
      chomp $sentence;

      # TODO: account for abbreviations such as Mt., Mr., Mrs., etc.
      my @_word = split( /\s+/, $sentence );
      my @word;
      for ( my $i = 0; $i < scalar( @_word ); $i++ ) {

        my $lexTree =
          Syntactic::Practice::Tree::Lexical->new( { daughters => $_word[$i],
                                                     frompos => $i, }
                                                 );

        push( @word, $lexTree );
      }
      push( @sentence, \@word );
    }
    push( @paragraph, \@sentence );
  }
  return @paragraph;
}

no Moose;
__PACKAGE__->meta->make_immutable;
