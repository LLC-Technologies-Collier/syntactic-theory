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
  my ( $analysis, $rule, $frompos, $alto, $target ) =
    @args{qw(analysis rule frompos alto target)};

  my $label = $target->label;

  my $r_label = $rule->label;
  $self->log->debug( "Checking rule [$r_label] at [$frompos,$alto]" );

  return
    unless ( $alto >= 0 );    # only terminal nodes on level 0 - aside from NOM

  $analysis->[$frompos]->{$alto} //= {};
  my $tree_list = ( $analysis->[$frompos]->{$alto}->{$label} //= [] );

  my @terms     = @{ $rule->terms };
  my $num_terms = scalar @terms;

  $self->log->debug( "Rule [$r_label] has $num_terms term(s)" );

  foreach my $term ( @terms ) {
    my $term_label = $term->label;
    my $term_id    = $term->id;
    my $term_alto  = $alto - 1;
    my $term_bnf   = $term->bnf;

    my @factor_labels = map { $_->label } @{ $term->factors };

    $self->log->debug(
"Now checking term [$term_label($term_id)] $term_bnf at position [$frompos,$term_alto]"
    );

    my $res = $self->check_term( analysis => $analysis,
                                 frompos  => $frompos,
                                 term     => $term,
                                 alto     => $term_alto,
                                 target   => $target, );

    $self->log->debug(
"Term [$term_label($term_id)] $term_bnf at position [$frompos,$term_alto]: ",
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
  my ( $analysis, $term, $frompos, $alto, $target ) =
    @args{qw(analysis term frompos alto target)};

  my $label = $target->label;

  if ( $alto < 0 ) {
    $self->log->debug( "Opting not to check a term with a negative height" );
    return;
  }

  my $element = ( $analysis->[$frompos]->{$alto} //= {} );

  my $t_label  = $term->label;
  my $term_id  = $term->id;
  my $term_bnf = $term->bnf;

  my $licensed    = 1;
  my @factors     = @{ $term->factors };
  my $num_factors = scalar @factors;
  my @factor_ids  = map { $_->id } @factors;
  $self->log->debug(
            "Term [$t_label($term_id)] has $num_factors factor(s): $term_bnf" );

  if ( exists $element->{$label}->[0]
       && $element->{$label}->[0]->frompos )
  {
    if ( $element->{term}->{$term_id} ) {
      $self->log->debug(
"We have checked and there IS a [$t_label($term_id)] at position $frompos,$alto."
      );
    } else {
      $self->log->debug(
"We have checked and there IS NOT a [$t_label($term_id)] at position $frompos,$alto."
      );
    }
    return $element->{term}->{$term_id};
  }
  $self->log->debug(
"We have not yet checked whether there is a(n) [$t_label($term_id)] at position [$frompos,$alto].  proceeding."
  );
  my @daughters;
  my @frompos = ( $frompos );
  $self->log->debug( "Investigating factors..." );

  for ( my $i = 0; $i < $num_factors; $i++ ) {
    $self->log( "Investigating factor #${i}" );

    my $factor     = $factors[$i];
    my $fact_label = $factor->label;
    my $fact_id    = $factor->id;

    my $depth =
      $factor->licenses( $analysis->[$frompos]->{$alto}->{$label}->[0] );
    unless ( defined $depth ) {
      $self->log->debug(
                "it seems that a [$fact_label] will never license a [$label]" );
      return;
    }
    $self->log->debug(
        "There are $depth generations between the factor and our destination" );

    my @topos;
    my $pos;
    my $height = $alto - 1;
    $self->log->debug( "Checking Factor number [$i]" );
    while ( scalar @frompos ) {
      my $pos = shift @frompos;
      $self->log->debug(
           "Checking for [$fact_label($fact_id)] at position ($pos,$height])" );

      my @pos =
        $self->check_factor( analysis => $analysis,
                             frompos  => $pos,
                             factor   => $factor,
                             alto     => $height,
                             target   => $target, );

      $self->log->debug(
           "Factor #${i} [$fact_label($fact_id)] at position ($pos,$height]): ",
           scalar @pos ? 'Yes' : 'No' );

      push( @topos, @pos );
    }

    if ( scalar @topos ) {
      if ( $i == $#factors ) {
        $self->log->debug(
'All factors found.  This is where we should create a tree and insert it into the analysis'
        );
        foreach my $topos ( @topos ) {

        }
      }
      @frompos = @topos;
    } elsif ( $factor->optional ) {
      $self->log->debug(
"Did not find optional term [$t_label] at position [$frompos,$height].  Inserting Null."
      );

      my ( $f_id, $lextree ) = each %{ $analysis->[0]->{0}->{factor} };
      my $sentence = $lextree->sentence;

      my $null_tree =
        Syntactic::Practice::Tree::Abstract::Null->new(
                                                  term     => $factor->term,
                                                  category => $factor->category,
                                                  factor   => $factor,
                                                  frompos  => $frompos,
                                                  topos    => $frompos,
                                                  sentence => $sentence,
                                                  label    => $label, );

      $analysis->[$frompos]->{$alto}->{factor}->{ $factor->id } = $null_tree;
      next;

    } else {

      $licensed = 0;
      $analysis->[$frompos]->{$alto}->{term}->{$term_id} = undef;
      $self->log->debug(
"Did not find a required term [$label] at position [$frompos,$alto].  Sad panda."
      );
      last;
    }
  }

  return unless $licensed;

#  while ( my ( $term_id, $tree ) = keys %{ $analysis->[$frompos]->{$alto} } ) {
#    next
#      if $self->evaluate( analysis => $analysis,
#                          frompos  => $frompos,
#                          alto     => $alto,
#                          term_id  => $term_id, );

  #    $element->{ $term->label } = undef;
  #    $licensed = 0;
  #    last;
  #  }

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
  my ( $analysis, $factor, $frompos, $alto, $label ) =
    @args{qw(analysis factor frompos alto label )};

  my ( $lextree ) = values( %{ $analysis->[0]->{0}->{term} } );

  my $sentence = $lextree->sentence;

  my $lastpos = $sentence->[-1]->topos;

  return $frompos if $frompos == $lastpos;

  my $f_label   = $factor->label;
  my $tree_list = $analysis->[$frompos]->{$alto}->{$label};

  if ( !scalar @$tree_list ) {
    my $msg = "There is not a(n) $f_label at position [$frompos,$alto], ";
    unless ( $factor->optional ) {
      $self->log->debug( $msg,
                         "and the factor is not optional.  Not licensed." );
      $analysis->[$frompos]->{$alto}->{factor}->{ $factor->id } = undef;
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

    $analysis->[$frompos]->{$alto}->{factor}->{ $factor->id } = $null_tree;
    push( @$tree_list, { $factor->id => $null_tree } );
    return ( $frompos );
  }

  my $num_trees = scalar @$tree_list;
  my $str       = join( ',',
                  map { my ( $term_id, $t ) = each %$_; $t->string }
                  grep { values( %$_ ) } @$tree_list );
  $self->log->debug( "There be ${num_trees} [$f_label] tree(s) ",
                     "with strings(s) ($str) at position $frompos,$alto!" );

  my @topos;
  foreach my $tuple ( @$tree_list ) {
    my ( $factor_id ) = keys %$tuple;
    my ( $t )         = values %$tuple;

    $self->log->debug( "Factor ID is undefined" ) unless defined $factor_id;
    $self->log->debug( "Tree is undefined" )      unless defined $t;

    next unless $t;
    next if $t->isa( 'Syntactic::Practice::Tree::Abstract::Null' );

    if ( $factor_id == 0 ) {

    }

    my $topos     = $t->topos;
    my $t_frompos = $t->frompos;

    my $f_id = $factor->id;
    $self->log->debug(
                     "ID of Factor which we passed to this method is [$f_id]" );

    # my $tree = $self->check_term( analysis => $analysis,
    #                               term     => $term,
    #                               frompos  => $frompos,
    #                               alto     => $alto );
    # if ( $tree ) {
    #   push( @$tree_list, { $term->id, $tree } );
    # }

    $self->log->debug(
          "Tree's Frompos and specified Frompos differ: [$frompos,$t_frompos]" )
      if $frompos != $t_frompos;
    $self->log->debug( "Tree's Frompos and Topos: [$t_frompos,$topos]" );

    if ( $factor->repeat ) {
      $self->log->debug( "This is a repeat element" );

      my $nextpos = $t->topos;
      while ( my $next_tree_list = $analysis->[$nextpos]->{$alto}->{$label} ) {
        $self->log->debug( "repeated element found.  Advancing to $nextpos" );

        $topos = $nextpos;

        $nextpos =
          $self->process_tree_list( factor   => $factor,
                                    analysis => $analysis,
                                    frompos  => $nextpos,
                                    alto     => $alto,
                                    label    => $label, );

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
  my ( $analysis, $factor, $frompos, $alto, $target ) =
    @args{qw(analysis factor frompos alto target)};

  my $label = $target->label;

  my $f_label = $factor->label;
  my $f_id    = $factor->id;

  $self->log->debug(
                    "Checking factor [${f_label}($f_id)] at [$frompos,$alto]" );

  if ( $alto < 0 ) {
    $self->log->debug( "Opting not to check a term with a negative height" );
    return;
  }

  $self->log->debug( "Testing for $label at position [$frompos,$alto]" );

  my $depth = $factor->licenses( $target );
  if ( !defined $depth ) {
    $self->log->debug(
                   "it seems that a [$f_label] will never license a [$label]" );
    return undef;
  } elsif ( $depth > 0 ) {
    $self->log->debug(
               "There are $depth generations between the factor and [$label]" );
  } else {
    $self->log->debug( "Factor [$f_label] directly licenses tree [$label]" );
    $analysis->[$frompos]->{$alto}->{factor}->{$f_id} = $target;
    return 1;
  }
}

#method evaluate ( ArrayRef[HashRef] :$analysis,
#                  PositiveInt :$frompos = 0,
#                 PositiveInt :$alto = 0
#                 PositiveInt :$term_id = 0
#             ) {
sub evaluate {
  my ( $self,     %args )    = @_;
  my ( $analysis, $frompos ) = @args{qw( analysis frompos )};
  $frompos = 0 unless $frompos;
  my $alto = 0;

  my ( $lextree ) = values %{ $analysis->[0]->{0}->{factor} };
  my $s = $lextree->sentence;

  my $s_size = scalar @$s;
  my $tree   = $s->[$frompos];

  my $topos   = 0;
  my $element = $analysis->[$frompos]->{$alto};

  my $tree_name = $tree->name;
  my $category  = $tree->category;
  my $label     = $category->label;
  my @factors   = @{ $category->factors };

  my @factor_labels = map { $_->bnf } @factors;
  my $num_factors = scalar @factors;
  $self->log->debug(
"The category of our tree [$tree_name] is associated with [$num_factors] factor(s): @factor_labels"
  );

  for ( my $i = 0; $i < $num_factors; $i++ ) {
    my $factor          = $factors[$i];
    my $factor_position = $factor->position;

    my $res = $self->check_factor( analysis => $analysis,
                                   factor   => $factor,
                                   frompos  => $frompos,
                                   alto     => $alto,
                                   target   => $tree );

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

sub scan {
  my ( $self, $input ) = @_;

  chomp $input;

  my $tree_class = 'Syntactic::Practice::Tree::Abstract::Lexical';
  my $tkset_class = 'Syntactic::Practice::Grammar::TokenSet';
  my $sentence_class = 'Syntactic::Practice::Grammar::Sentence';

  my @paragraph;
  foreach my $paragraph ( split( /\n\n+/, $input ) ) {
    my @sentence;
    foreach my $sentence ( split( /\.\s+/, $paragraph ) ) {
      chomp $sentence;
      my $tokenSet = $tkset_class->new();

      # TODO: account for abbreviations such as Mt., Mr., Mrs., etc.
      my @word = split( /\s+/, $sentence );
      my @tree;

      for ( my $i = 0; $i < scalar( @word ); $i++ ) {

        my $homograph =
          Syntactic::Practice::Lexicon::Homograph->new( word => $word[$i] );
        foreach my $lexeme ( @{ $homograph->lexemes } ) {

          my $lexTree = $tree_class->new(
                                          { daughters    => $lexeme,
                                            frompos      => $i,
                                            category     => $lexeme->category,
                                            label        => $lexeme->label,
                                            constituents => $tkset_class->new(),
                                          } );

          push( @tree, $lexTree );
          $tokenSet->append_new( $lexTree );
        }
      }
      my $sentence = $sentence_class->new( tokens => $tokenSet );
      foreach my $tree ( @tree ) {
        $tree->sentence( $sentence );
      }
      $self->log('Sentence first token: ' . $sentence->first);
      push( @sentence, $sentence );
    }
    push( @paragraph, \@sentence );
  }
  return @paragraph;
}

sub scan_with_analysis {
  my ( $self, $input ) = @_;

  chomp $input;

  my $tree_class = 'Syntactic::Practice::Tree::Abstract::Lexical';
  my $tkset_class = 'Syntactic::Practice::Grammar::TokenSet';

  my @paragraph;
  foreach my $paragraph ( split( /\n\n+/, $input ) ) {
    my @sentence;
    my $tokenSet = $tkset_class->new();
    foreach my $sentence ( split( /\.\s+/, $paragraph ) ) {
      chomp $sentence;

      # TODO: account for abbreviations such as Mt., Mr., Mrs., etc.
      my @word = split( /\s+/, $sentence );
      my @tree;

      for ( my $i = 0; $i < scalar( @word ); $i++ ) {

        my $homograph =
          Syntactic::Practice::Lexicon::Homograph->new( word => $word[$i] );
        foreach my $lexeme ( @{ $homograph->lexemes } ) {

          my $lexTree = $tree_class->new(
                                          { daughters    => $lexeme,
                                            frompos      => $i,
                                            category     => $lexeme->category,
                                            label        => $lexeme->label,
                                            sentence     => \@tree,
                                            constituents => $tkset_class->new(),
                                          } );

          push( @tree, $lexTree );
          $tokenSet->append_new( $lexTree );
        }

        #map { $_->sentence( $tokenSet->tokens ) } @tree;

        #map { $_->sentence( \@tree ) } @tree;
      }

      my @analysis;

      foreach my $lextree ( @tree ) {
        my @factors = @{ $lextree->category->factors };
        my $f_set   = {};
        my $t_set   = {};
        my $column  = $analysis[ $lextree->frompos ];
        if ( scalar @factors == 1 ) {

          my $tokenSet = $tkset_class->new();
          $tokenSet->append_new( $lextree );

     # If this terminal node can only be licensed by one factor, pre-populate it
          my $f = $factors[0];
          my $t = $f->term;
          my $abstree =
            Syntactic::Practice::Tree::Abstract::Phrasal->new(
                                                      category => $t->category,
                                                      sentence => \@tree,
                                                      constituents => $tokenSet,
                                                      daughters    => [$lextree],
            );
          $f_set->{ $f->id } = $lextree;
          $t_set->{ $t->id } = $lextree;

          $column->{1} = { factor          => { $t->id => $abstree },
                           term            => { $t->id => $abstree },
                           $lextree->label => [$abstree] };
        } else {

          # otherwise fill with zeroes
          $f_set->{0} = $lextree;
          $t_set->{0} = $lextree;
        }
        $column->{0} = { factor          => $f_set,
                         term            => $t_set,
                         $lextree->label => [$t_set], };
        push( @analysis, $column );
      }

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
