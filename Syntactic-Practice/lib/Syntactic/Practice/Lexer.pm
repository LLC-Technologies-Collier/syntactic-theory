package Syntactic::Practice::Lexer;

use strict;
use Syntactic::Practice::Lexeme;
use Syntactic::Practice::Parser::Constituent;
use Moose;
use Moose::Util::TypeConstraints;

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
        confess( "strange word: [$_word[$i]]\n"
                   . Data::Dumper::Dumper(
                                           { word     => $_word[$i],
                                             word_idx => $i,
                                             sentence => $sentence,
                                           }
                   ) )
          if ref $_word[$i]
          or $_word[$i] =~ /ARRAY/;

        my $lexeme =
          Syntactic::Practice::Lexeme->new( word     => $_word[$i],
                                            sentence => \@_word,
                                            frompos  => $i,
                                            cat_type => 'lexical' );
        push( @word, $lexeme );
      }
      push( @sentence, \@word );
    }
    push( @paragraph, \@sentence );
  }
  return @paragraph;
}

no Moose;
__PACKAGE__->meta->make_immutable;
