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

sub check_rule {
  my ( $self, %args ) = @_;
  my ( $analysis, $rule, $frompos, $alto ) =
    @args{qw(analysis rule frompos alto)};

  my $label = $rule->label;

  return unless ( $alto >= 1 );    # only terminal nodes on level 0

  $analysis->[$frompos]->[$alto] //= {};
  my $tree_list = ( $analysis->[$frompos]->[$alto]->{$label} //= [] );

  foreach my $term ( @{ $rule->terms } ) {
    my $term_label = $term->label;
    my $term_id    = $term->id;
    my $term_alto  = $alto - 1;

    $self->log->debug(
             "Now checking term [$term_id] at position [$frompos,$term_alto]" );

    my $res = $self->check_term( analysis => $analysis,
                                 frompos  => $frompos,
                                 term     => $term,
                                 alto     => $term_alto );

    $self->log->debug( "Term [$term_id] at [$frompos,$alto]: ",
                       $res ? 'Yes' : 'No' );

    push( @$tree_list, { $term_id => $res } ) if ( $res );
  }
}

#method check_term ( ArrayRef[HashRef] :$analysis,
#                    Term :$term,
#                    PositiveInt :$frompos,
#                    PositiveInt :$alto
#                  ) {

sub check_term {

  my ( $self, %args ) = @_;
  my ( $analysis, $term, $frompos, $alto ) =
    @args{qw(analysis term frompos alto)};

  return unless ( $alto >= 0 );

  $analysis->[$frompos]->[$alto] //= {};

  my $element = $analysis->[$frompos]->[$alto];

  my $label   = $term->label;
  my $term_id = $term->id;

  my $licensed      = 1;
  my @factors       = @{ $term->factors };
  my $num_factors   = scalar @factors;
  my @factor_labels = map { $_->label } @factors;
  my @factor_ids    = map { $_->id } @factors;
  $self->log->debug(
       "Term [$label($term_id)] has $num_factors factor(s): [@factor_labels]" );

  if ( exists $element->{term}->{$term_id} ) {
    if ( $element->{term}->{$term_id} ) {
      $self->log->debug(
         "We have checked and there IS a [$term_id] at position $frompos,$alto."
      );
    } else {
      $self->log->debug(
"We have checked and there IS NOT a [$term_id] at position $frompos,$alto." );
    }
    return $element->{term}->{$label};
  }
  $self->log->debug(
"We have not yet checked whether there is a [$term_id] at position $frompos,$alto.  proceeding."
  );
  my @daughters;

  my @frompos = ( $frompos );
  for ( my $i = 0; $i < scalar @factors; $i++ ) {
    my $factor = $factors[$i];

    my @topos;
    while ( my $pos = shift( @frompos ) ) {
      my @pos = $self->check_factor( analysis => $analysis,
                                     frompos  => $pos,
                                     factor   => $factor,
                                     alto     => $alto );
      push( @topos, @pos );
    }

    if ( @topos ) {
      if ( $i == $#factors ) {
        foreach my $topos ( @topos ) {

        }
      }
      @frompos = @topos;
    } else {
      $licensed = 0;
      $self->log->debug(
"Did not find a full parse with term [$label] at position [$frompos].  Sad panda."
      );
      last;
    }

  }

  return unless $licensed;

  while ( my ( $term_id, $tree ) = keys %{ $analysis->[$frompos]->[$alto] } ) {
    next
      if $self->evaluate( analysis => $analysis,
                          frompos  => $frompos,
                          alto     => $alto,
                          term_id  => $term_id, );

    $element->{ $term->label } = undef;
    $licensed = 0;
    last;
  }

  return unless $licensed;

  # $element->{ $term->id } =
  #   Syntactic::Practice::Tree::Abstract::Phrasal->new(
  #                                                daughters => \@daughters,
  #                                                label     => $term->label,
  #                                                category  => $term->category,
  #                                                frompos   => $frompos,
  #                                                topos => $daughters[-1]->topos,
  #   );

  $self->log->debug( 'Full parse completed!  Yays!' );

  return $element->{ $term->id };

}

sub process_tree_list {
  my ( $self, %args ) = @_;
  my ( $analysis, $factor, $frompos, $alto ) =
    @args{qw(analysis factor frompos alto )};

  my $sentence = $analysis->[0]->[0]->{factor}->{0}->sentence;
  my $lastpos  = $sentence->[-1]->topos;

  return $frompos if $frompos == $lastpos;

  my $label     = $factor->label;
  my $tree_list = [];
  if ( $factor->is_terminal ) {
    $tree_list = $analysis->[$frompos]->[$alto]->{$label};
  } else {
    my $rule = Syntactic::Practice::Grammar->new->rule( label => $label );
    foreach my $term ( @{ $rule->terms } ) {
      my $tree = $self->check_term( analysis => $analysis,
                                    term     => $term,
                                    frompos  => $frompos,
                                    alto     => $alto );
      if ( $tree ) {
        push( @$tree_list, { $term->id, $tree } );
      }
    }
  }

  if ( !scalar @$tree_list ) {
    my $msg = "There is not a(n) $label at position [$frompos,$alto], ";
    unless ( $factor->optional ) {
      $self->log->debug( $msg,
                         "and the factor is not optional.  Not licensed." );
      $analysis->[$frompos]->[$alto]->{factor}->{ $factor->id } = undef;
      return ();
    }

    $self->log->debug( $msg, "but the factor is optional.  Inserting Null." );
    my $null_tree =
      Syntactic::Practice::Tree::Abstract::Null->new(
                                                  term     => $factor->term,
                                                  category => $factor->category,
                                                  factor   => $factor,
                                                  frompos  => $frompos,
                                                  topos    => $frompos,
                                                  sentence => $sentence,
                                                  label    => $label, );

    $analysis->[$frompos]->[$alto]->{factor}->{ $factor->id } = $null_tree;
    push( @$tree_list, { $factor->id => $null_tree } );
    return ( $frompos );
  }

  my $num_trees = scalar @$tree_list;
  my $str       = join( ',',
                  map { my ( $term_id, $t ) = each %$_; $t->string }
                  grep { values( %$_ ) } @$tree_list );
  $self->log->debug( "There are ${num_trees} [$label] tree(s) ",
                     "with strings(s) ($str) at position $frompos,$alto!" );
  my @topos;
  foreach my $tuple ( @$tree_list ) {
    my ( $factor_id, $t ) = each %$tuple;

    next unless $t;
    next if $t->isa( 'Syntactic::Practice::Tree::Abstract::Null' );

    my $topos = $t->topos;

    if ( $factor->repeat ) {
      $self->log->debug( "This is a repeat element" );

      my $nextpos = $t->topos;
      while ( my $next_tree_list = $analysis->[$nextpos]->[$alto]->{$label} ) {
        $self->log->debug( "repeated element found.  Advancing to $nextpos" );

        $topos = $nextpos;

        $nextpos =
          $self->process_tree_list( factor   => $factor,
                                    analysis => $analysis,
                                    frompos  => $nextpos,
                                    alto     => $alto, );

        last if $nextpos == $lastpos;
      }

    } else {
      $self->log->debug( "not a repeat element" );
    }
    push( @topos, $topos );
  }
  return @topos;
}

sub check_factor {
  my ( $self, %args ) = @_;
  my ( $analysis, $factor, $frompos, $alto ) =
    @args{qw(analysis factor frompos alto)};

  return unless ( $alto >= 0 );

  my $label = $factor->label;

  unless ( $factor->is_terminal ) {
    $self->log->debug(
      "This factor is not terminal.  Checking rule [$label] at [$frompos,$alto]"
    );

    $self->check_rue(
             analysis => $analysis,
             frompos  => $frompos,
             rule => Syntactic::Practice::Grammar->new->rule( label => $label ),
             alto => $alto );

    $self->log->debug( 'Rule check complete.  ',
      "Continuing our proceedings with check of [$label] at [$frompos,$alto]" );
  }

  my $tree_list = ( $analysis->[$frompos]->[$alto]->{$label} //= [] );

  return unless scalar @$tree_list;

  return
    $self->process_tree_list( factor   => $factor,
                              analysis => $analysis,
                              frompos  => $frompos,
                              alto     => $alto, );
}

#method evaluate ( ArrayRef[HashRef] :$analysis,
#                  PositiveInt :$frompos = 0,
#                 PositiveInt :$alto = 0
#                 PositiveInt :$term_id = 0
#             ) {
sub evaluate {
  my ( $self,     %args )    = @_;
  my ( $analysis, $frompos ) = @args{qw(analysis frompos )};
  $frompos = 0 unless $frompos;
  my $alto = 0;

  my @s      = @{ $analysis->[0]->[0]->{factor}->{0}->sentence };
  my $s_size = scalar @s;
  my $tree   = $s[$frompos];

  my $topos   = 0;
  my $element = $analysis->[$frompos]->[$alto];

  $self->log->debug( 'Element: ', Data::Printer::p $element );
  $self->log->debug( 'Factors: ', Data::Printer::p $element->{factor} );

  while ( my ( $factor_id, $tree ) = each( %{ $element->{factor} } ) ) {
    $self->log->debug( Data::Printer::p $tree );

    my $tree_name = $tree->name;

    my $category    = $tree->category;
    my $cat_label   = $category->label;
    my @factors     = @{ $category->factors };
    my $num_factors = scalar @factors;
    $self->log->debug(
"The category of our tree [$tree_name] is associated with [$num_factors] factor(s)"
    );

    for ( my $i = 0; $i < $num_factors; $i++ ) {
      my $factor          = $factors[$i];
      my $factor_position = $factor->position;

      my $res = $self->check_term( analysis => $analysis,
                                   term     => $factor->term,
                                   frompos  => $frompos,
                                   alto     => $alto );

#       if ( $res ) {
#         $topos = $res->topos;
#         $self->log->debug(
# "Result was successful!  To position is [$topos], sentence size is $s_size" );
#         if ( $res->topos < $s_size ) {
#           $self->evaluate( analysis  => $analysis,
#                            frompos   => $res->topos,
#                            completed => [],
#                            term_id => $res->term->id
#                          );
#         } else {
#           return;
#         }

      #       }

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
        my $f_set = { 0 => $_ };
        [
          { factor    => $f_set,
            term      => { 0 => [$f_set] },
            $_->label => [$f_set]
          } ]
      } @tree;

      $self->evaluate( analysis => \@analysis,
                       frompos  => $tree[0]->frompos,
                       alto     => 0, );

      push( @sentence, \@tree );

    }
    push( @paragraph, \@sentence );
  }
  return @paragraph;
}

__PACKAGE__->meta->make_immutable;
