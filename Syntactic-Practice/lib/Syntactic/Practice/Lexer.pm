package Syntactic::Practice::Lexer;

use strict;

=head1 NAME

Syntactic::Practice::Lexer - A lexical analyzer

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use Moose;
use namespace::autoclean;
use MooseX::Params::Validate;
use MooseX::Method::Signatures;

method evaluate ( ArrayRef[HashRef] :$analysis,
                  PositiveInt :$frompos = 0,
                  SyntacticCategoryLabel :$label
                ) {
  my $element = $analysis->[$frompos];
  my $tree    = $element->{$label};
  my @s       = @{ $tree->sentence };

  my $category = $tree->category;

  my $evaluation = 0;

  foreach my $term ( map { $_->term } @{ $category->factors } ) {
    next if exists $element->{ $term->label };
    my $topos    = $tree->frompos;
    my $licensed = 1;
    my @factor   = @{ $term->factors };
    my @daughters;
    foreach my $factor ( @factor ) {
      my $f_label = $factor->label;

      if ( exists $analysis->[$topos]->{$f_label}
           && defined $analysis->[$topos]->{$f_label} )
      {
        my $t = $analysis->[$topos]->{$f_label};
        $topos = $t->topos;
        push( @daughters, $t );
        if ( $factor->repeat ) {
          while ( exists $analysis->[$topos]->{$f_label}
                  && defined $analysis->[$topos]->{$f_label} )
          {
            $t     = $analysis->[$topos]->{$f_label};
            $topos = $t->topos;
            push( @daughters, $t );
          }
        }
        next;
      } elsif ( $factor->optional ) {
        next;
      } else {
        $licensed = 0;
        $analysis->[$topos]->{$f_label} = undef;
        last;
      }
    }

    next unless $licensed;

    foreach my $l ( keys %{ $analysis->[$topos] } ) {
      next
        if $self->evaluate( analysis => $analysis,
                            label    => $l,
                            frompos  => $topos, );

      $element->{ $term->label } = undef;
      last;
    }

    next unless $licensed;

    $element->{ $term->label } =
      Syntactic::Practice::Tree::Abstract::Phrasal->new(
                                                    daughters => \@daughters,
                                                    label     => $term->label,
                                                    category => $term->category,
                                                    frompos  => $frompos,
                                                    topos    => $topos, );

    $evaluation = 1;

  }

  return $evaluation;
}

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

        my $homograph =
          Syntactic::Practice::Lexicon::Homograph->new( word => $word[$i] );
        foreach my $lexeme ( @{ $homograph->lexemes } ) {

          my $lexTree =
            Syntactic::Practice::Tree::Abstract::Lexical->new(
                                                { daughters => $lexeme,
                                                  frompos   => $i,
                                                  category => $lexeme->category,
                                                  label    => $lexeme->label,
                                                } );

          push( @tree, $lexTree );
        }
        map { $_->sentence( \@tree ) } @tree;
      }

      my @analysis = map {
        { $_->label => $_ }
      } @tree;

      $self->evaluate( analysis => \@analysis,
                       label    => $tree[0]->label,
                       frompos  => $tree[0]->frompos, );

      push( @sentence, \@tree );

    }
    push( @paragraph, \@sentence );
  }
  return @paragraph;
}

__PACKAGE__->meta->make_immutable;
