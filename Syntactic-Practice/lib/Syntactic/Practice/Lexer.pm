package Syntactic::Practice::Lexer;

use strict;

=head1 NAME

Syntactic::Practice::Lexer - A lexical analyzer

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

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
      my @word = split( /\s+/, $sentence );
      my @tree;
      for ( my $i = 0; $i < scalar( @word ); $i++ ) {

        my $homograph = Syntactic::Practice::Lexicon::Homograph->new( word => $word[$i] );
        foreach my $lexeme ( @{ $homograph->lexemes } ){

          my $lexTree =
            Syntactic::Practice::Tree::Abstract::Lexical->new(
                                                              { daughters => $lexeme,
                                                                frompos   => $i,
                                                                label     => $lexeme->label,
                                                              } );

          push( @tree, $lexTree );
        }
        map { $_->sentence( \@tree ) } @tree;
      }
      push( @sentence, \@tree );
    }
    push( @paragraph, \@sentence );
  }
  return @paragraph;
}

no Moose;
__PACKAGE__->meta->make_immutable;
