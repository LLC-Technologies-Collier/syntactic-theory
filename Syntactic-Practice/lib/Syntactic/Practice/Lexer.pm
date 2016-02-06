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

with 'MooseX::Log::Log4perl';

method evaluate ( ArrayRef[HashRef] :$analysis,
                  PositiveInt :$frompos = 0,
                  SyntacticCategoryLabel :$label
                ) {
  $self->log->debug("Analyzing [$label] at position [$frompos]");
  my $element = $analysis->[$frompos];
  my $tree    = $element->{$label};
  my @s       = @{ $tree->sentence };

  my $category = $tree->category;
  my $cat_label = $category->label;
  my @cat_factors = @{ $category->factors };
  my $num_cat_factors = scalar @cat_factors;
  $self->log->debug("The category of our tree [$cat_label] is associated with $num_cat_factors factor(s)");

  my $evaluation = 0;

  for( my $i = 0; $i < $num_cat_factors; $i++ ){
    my $cat_factor = $cat_factors[$i];
    my $cat_factor_position = $cat_factor->position;
    my $term = $cat_factor->term;
    my $term_label = $term->label;
    my $term_id = $term->resultset->id;
    $self->log->debug("Factor #$i is in position #$cat_factor_position of term [$term_label($term_id)]");
    my $topos    = $tree->frompos;
    my $licensed = 1;
    my @term_factor   = @{ $term->factors };
    my $num_term_factors = scalar @term_factor;
    my @term_factor_labels = map { $_->label } @term_factor;
    $self->log->debug("Term [$term_label($term_id)] has $num_term_factors factor(s): [@term_factor_labels]");
    next if exists $element->{ $term->label };
    my @daughters;
    foreach my $factor ( @term_factor ) {
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
    $self->log->debug( "Did not find a full parse with term [$term_label] at position [$frompos].  Sad panda." );
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

    $self->log->debug( 'Full parse completed!  Yays!' );

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
