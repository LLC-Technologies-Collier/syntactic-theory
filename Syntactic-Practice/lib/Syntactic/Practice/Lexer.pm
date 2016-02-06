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

my $max_depth = 10;

#method check_term ( ArrayRef[HashRef] :$analysis,
#                    Term :$term,
#                    PositiveInt :$frompos,
#                    SyntacticCategoryLabel :$label,
#                    PositiveInt :$depth = 0
#                  ) {

sub check_term {

  my ( $self, %args ) = @_;
  my ( $analysis, $term, $frompos, $label, $depth ) =
    @args{qw(analysis term frompos label depth)};

  return unless ( $depth <= $max_depth );

  my $element = $analysis->[$frompos];

  my $term_label = $term->label;
  my $term_id    = $term->resultset->id;

  my $topos         = $frompos;
  my $licensed      = 1;
  my @factors       = @{ $term->factors };
  my $num_factors   = scalar @factors;
  my @factor_labels = map { $_->label } @factors;
  $self->log->debug(
     "Term [$term_label($term_id)] has $num_factors factor(s): [@factor_labels]"
  );

  if ( exists $element->{$term_label} ) {
    if ( $element->{$term_label} ) {
      $self->log->debug(
         "We have checked and there IS a [$term_label] at position $frompos." );
    } else {
      $self->log->debug(
        "We have checked and there IS NOT a [$term_label] at position $frompos."
      );
    }
    return $element->{$term_label};
  }
  $self->log->debug(
"We have not yet checked whether there is a [$term_label] at position $topos.  proceeding."
  );
  my @daughters;

  foreach my $factor ( @factors ) {
    my $f_label = $factor->label;
    unless ( $factor->is_terminal ) {
      $self->log->debug(
         "This factor is not terminal.  Diving in!  Depth currently [$depth]" );

      my $rule = Syntactic::Practice::Grammar->new->rule( label => $f_label );
      my @subterm      = @{ $rule->terms };
      my $num_subterms = scalar @subterm;
      for ( my $i = 0; $i < $num_subterms; $i++ ) {
        my $sub_term      = $subterm[$i];
        my $subterm_label = $sub_term->label;
        my $subterm_id    = $sub_term->resultset->id;

        $self->log->debug(
          "Now checking term [$subterm_label($subterm_id)] at position [$topos]"
        );

        my $res = $self->check_term( analysis => $analysis,
                                     frompos  => $topos,
                                     term     => $sub_term,
                                     label    => $f_label,
                                     depth    => ( $depth + 1 ) );

        $self->log->debug( "Term [$subterm_label($subterm_id)] at [$topos]: ",
                           $res ? 'Yes' : 'No' );
      }
    }

    $self->log->debug( "Now proceeding with check of [$f_label] at [$topos]" );

    if ( exists $analysis->[$topos]->{$f_label}
         && defined $analysis->[$topos]->{$f_label} )
    {
      my $str = $analysis->[$topos]->{$f_label}->string;
      $self->log->debug( "There is a [$f_label] ($str) at position $topos!" );
      my $t = $analysis->[$topos]->{$f_label};
      $topos = $t->topos;
      push( @daughters, $t );
      if ( $factor->repeat ) {
        $self->log->debug( "This is a repeat element" );
        while ( exists $analysis->[$topos]->{$f_label}
                && defined $analysis->[$topos]->{$f_label} )
        {
          $t = $analysis->[$topos]->{$f_label};
          my $nextpos = $t->topos;
          $self->log->debug( "repeated element found.  Advancing to $topos" );

          $topos = $t->topos;
          push( @daughters, $t );
        }
      } else {
        $self->log->debug( "not a repeat element" );
      }
      next;
    } elsif ( $factor->optional ) {
      $self->log->debug(
"There is not an $f_label at position $topos, but the factor is optional!" );
      next;
    } else {
      $self->log->debug(
"There is not an $f_label at position $topos, and the factor is not optional.  Sad panda."
      );
      $licensed = 0;
      $analysis->[$topos]->{$f_label} = undef;
      last;
    }
  }
  $self->log->debug(
"Did not find a full parse with term [$term_label] at position [$frompos].  Sad panda."
  ) unless $licensed;
  return unless $licensed;

  foreach my $l ( keys %{ $analysis->[$topos] } ) {
    next
      if $self->evaluate( analysis  => $analysis,
                          frompos   => $topos,
                          completed => [], );

    $element->{ $term->label } = undef;
    $licensed = 0;
    last;
  }

  return unless $licensed;

  $element->{ $term->label } =
    Syntactic::Practice::Tree::Abstract::Phrasal->new(
                                                    daughters => \@daughters,
                                                    label     => $term->label,
                                                    category => $term->category,
                                                    frompos  => $frompos,
                                                    topos    => $topos, );

  $self->log->debug( 'Full parse completed!  Yays!' );

  return $element->{ $term->label };

}

#method evaluate ( ArrayRef[HashRef] :$analysis,
#                  PositiveInt :$frompos = 0,
#                 ArrayRef[SyntacticCategoryLabel] :$completed = []
#             ) {
sub evaluate {
  my ( $self, %args ) = @_;
  my ( $analysis, $frompos, $completed ) =
    @args{qw(analysis frompos completed)};
  my $element = $analysis->[$frompos];

  return unless %$element;
  my @trees = grep { defined $_ } values %$element;

  return unless scalar @trees;
  my @s = @{ $trees[0]->sentence };
  my $s_size = scalar @s;

  my $topos = 0;

  while ( $topos < $s_size ) {
    foreach my $label ( keys %$element ) {
      $self->log->debug( "Analyzing [$label] at position [$frompos]" );
      next if grep { $_ eq $label } @$completed;

      my $tree = $element->{$label};

      unless( defined $tree ){
        push(@$completed, $label);
        next;
      }

      my $category        = $tree->category;
      my $cat_label       = $category->label;
      my @cat_factors     = @{ $category->factors };
      my $num_cat_factors = scalar @cat_factors;
      $self->log->debug(
"The category of our tree [$cat_label] is associated with $num_cat_factors factor(s)"
      );

      for ( my $i = 0; $i < $num_cat_factors; $i++ ) {
        my $cat_factor          = $cat_factors[$i];
        my $cat_factor_position = $cat_factor->position;

        my $res = $self->check_term( analysis => $analysis,
                                     term     => $cat_factor->term,
                                     frompos  => $frompos,
                                     label    => $label,
                                     depth    => 0 );

        if ( $res ) {
          $topos = $res->topos;
          $self->log->debug("Result was successful!  To position is [$topos], sentence size is $s_size");
          if( $res->topos < $s_size ){
            $self->evaluate( analysis  => $analysis,
                             frompos   => $res->topos,
                             completed => [] );
          }else{
            return;
          }
        }
      }

    }
  }
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

      $self->evaluate( analysis  => \@analysis,
                       frompos   => $tree[0]->frompos,
                       completed => [], );

      push( @sentence, \@tree );

    }
    push( @paragraph, \@sentence );
  }
  return @paragraph;
}

__PACKAGE__->meta->make_immutable;
