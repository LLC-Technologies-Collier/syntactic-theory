package Syntactic::Practice::Parser;

=head1 NAME

Syntactic::Practice::Parser - A natural language parser

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use Moose;
use namespace::autoclean;
use MooseX::Params::Validate;
use MooseX::Method::Signatures;

with 'MooseX::Log::Log4perl';

has max_depth => ( is      => 'ro',
                   isa     => 'PositiveInt',
                   default => 10 );

has allow_partial => ( is      => 'ro',
                       isa     => 'Bool',
                       default => 0 );

has allow_duplicates => ( is      => 'ro',
                          isa     => 'Bool',
                          default => 0 );

has prune_nulls => ( is      => 'ro',
                     isa     => 'Bool',
                     default => 1 );

has sentence => ( is       => 'ro',
                  isa      => 'ArrayRef[TerminalAbstractTree]',
                  required => 1, );

method ingest ( PositiveInt :$frompos,
                SyntacticCategory :$category,
                MotherValue :$mother
              ) {

  my $num_words = scalar( @{ $self->sentence } );
  if ( $frompos >= $num_words ) {
    $self->log->error( "insufficient words to license phrase" );
    return ();
  }

  # avoid excessive recursion
  return () if ( $mother && $category && $mother->label eq $category->label );

  my %tree_params = ( frompos  => $frompos,
                      depth    => $self->{current_depth},
                      sentence => $self->sentence,
                      label    => $category->label, );

  my $msg = '%2d: %-2s %s [%s]';

  my $rule = Syntactic::Practice::Grammar::Rule->new( category => $category );

  unless ( $rule ) {
    $self->log->debug(
                    sprintf( 'bad rule identifier: [%s]!', $category->label ) );
    return ();
  }

  my @return = ();
  my $terms  = $rule->terms;
  foreach my $term ( @$terms ) {    # TODO: support multiple terms
    $tree_params{term} = $term;

    my ( $target );
    if ( $term->is_start ) {
      $target = Syntactic::Practice::Tree::Abstract::Start->new( %tree_params );
      $tree_params{label} = $target->label;
    } else {
      $target =
        Syntactic::Practice::Tree::Abstract::Phrasal->new( %tree_params );
    }

    my @d_list = ( [] );
    foreach my $factor ( @{ $term->factors } ) {
      $target->factor( $factor ) unless $target->is_start;
      my $factor_label = $factor->label;

      my $optional = $factor->optional;
      my $repeat   = $factor->repeat;

      my $optAtPos = {};

      for ( my $dlist_idx = 0; $dlist_idx < scalar @d_list; $dlist_idx++ ) {
        my @daughter = @{ $d_list[$dlist_idx] };

        my $curpos = ( scalar @daughter ? $daughter[-1]->topos : $frompos );

        next if $curpos == $num_words;

        if ( $optional && !exists $optAtPos->{$curpos} ) {
          my %mother = ( $factor->is_start ? () : ( mother => $target ) );
          my $class = 'Syntactic::Practice::Tree::Abstract::Null';
          my $tree = $class->new( depth    => $self->{current_depth} + 1,
                                  term     => $term,
                                  category => $factor->category,
                                  factor   => $factor,
                                  frompos  => $curpos,
                                  sentence => $self->sentence,
                                  label    => $factor_label,
                                  %mother, );
          $optAtPos->{$curpos} = $tree;
          splice( @d_list, $dlist_idx, 0, ( [ @daughter, $tree ] ) );
          next;
        }

        splice( @d_list, $dlist_idx, 1 );
        my @tree = $self->ingest( frompos  => $curpos,
                                  category => $factor->category,
                                  mother   => $target, );

        unless ( @tree ) {
          my @s = @{ $self->sentence };
          unless ( $factor->is_terminal ) {
            my $string = join( ' ', map { $_->string } @s[ $curpos .. $#s ] );
            my @data = ( $curpos, $factor_label, '!->', $string );
            $self->log->info( sprintf( $msg, @data ) );
          }

          $dlist_idx--;
          next;
        }
        foreach my $tree ( @tree ) {
          $tree->mother( $target );

          my @new = ( [ @daughter, $tree ] );
          push( @new, [ @daughter, $tree ] ) if ( $repeat );
          splice( @d_list, $dlist_idx, 0, ( @new ) );
        }
      }
    }
    while ( my $d = shift( @d_list ) ) {
      my @d;
      if ( $self->prune_nulls ) {
        @d =
          grep { !$_->isa( 'Syntactic::Practice::Tree::Abstract::Null' ) } @$d;
      } else {
        @d = @$d;
      }
      my $num_daughters = scalar @d;
      next unless $num_daughters >= 1;

      if ( $num_daughters == 1 ) {

#        next if( ( $mother && $mother->label eq $target->label ) && $target->label eq $d[0]->label );
      }

      my $tree =
        $target->new( %$target,
                      %tree_params,
                      frompos   => $d[0]->frompos,
                      topos     => $d[-1]->topos,
                      daughters => \@d );

      foreach my $sib ( @d ) {
        next unless $sib->isa( 'Tree' );
        my @sibs = grep { $sib->cmp( $_ ) != 0 } @d;
        $sib->sisters( \@sibs );
        $sib->mother( $tree );
      }
      my @data = ( $d[0]->frompos, $tree->label, ' ->', $tree->string );
      $self->log->info( sprintf( $msg, @data ) );
      $self->log->info( $tree->factor->as_string )
        if !$tree->is_start && defined $tree->factor;

      if ( grep { $tree->cmp( $_ ) == 0 } @return ) {
        next unless $self->allow_duplicates;
      }
      push( @return, $tree );
    }
  }

  return ( @return ) if scalar @return;

  return ();
}

sub BUILD {
  my ( $self ) = @_;

  my @s = @{ $self->sentence };
  my $string;
  if ( scalar @s == 1 ) {
    $string = $s[0]->daughters;
  } else {
    $string = join( ' ', map { $_->string } @s );
  }

  $self->log->debug( "Parsing string [$string]" );

  $self->{current_depth} = 0;
  $self->{cached}        = {};

  foreach my $lexeme ( @s ) {
    my $label   = $lexeme->label;
    my $frompos = $lexeme->frompos;
    $self->log->debug( "pre-caching: $frompos -> $label" );
    $self->{cached}->{$frompos} = { $label   => [$lexeme],
                                    terminal => $lexeme };
  }
}

around ingest => sub {
  my ( $orig, $self, @args ) = @_;

  my ( %params ) =
    validated_hash( \@args,
                    frompos  => { isa => 'PositiveInt',       optional => 0 },
                    category => { isa => 'SyntacticCategory', optional => 0 },
                    mother   => { isa => 'MotherValue',       optional => 0 },
    );

  my ( $frompos, $category, $mother ) =
    ( @params{qw(frompos category mother)} );
  my $label = $category->label;

  if ( $self->{current_depth}++ >= $self->max_depth ) {
    --$self->{current_depth};
    $self->log->debug(
                'exceeded maximum recursion depth [' . $self->max_depth . ']' );
    return ();
  }

  $self->{cached}->{$frompos} = {}
    unless exists $self->{cached}->{$frompos};

  my $cache = $self->{cached}->{$frompos};

  my @data = ( $frompos, $label );
  my $msg = '%2d: %-2s %s [%s]';

  my @result;

  if ( $category->is_terminal ) {
    my $tree = $cache->{terminal};
    my %tree_params = ( frompos  => $frompos,
                        mother   => $mother,
                        depth    => $self->{current_depth},
                        sentence => $self->sentence );

    push( @result, $tree->new( %$tree, %tree_params ) )
      if $label eq $tree->label;

  } else {

    if ( exists $cache->{$label} && $cache->{$label} ne 'incomplete' ) {

      push( @result, @{ $cache->{$label} } );

      my $num_parses = scalar @result;
      $self->log->info( "cache hit. [$frompos,$label] - $num_parses parse(s)" );
    } else {
      if ( exists $cache->{$label} && $cache->{$label} eq 'incomplete' ) {
        $self->log->info(
          "cache re-miss. [$frompos,$label] - depth [$self->{current_depth}]" );
      } else {
        $cache->{$label} = 'incomplete';
        $self->log->info(
             "cache miss. [$frompos,$label] - depth [$self->{current_depth}]" );
      }
      push( @result, $self->$orig( @args ) );
      $cache->{$label} = [@result];
      my $num_parses = scalar @result;
      $self->log->info(
"cache filled at [$frompos,$label] - $num_parses parse(s) ; depth [$self->{current_depth}]"
      );

    }

    my @filtered;
    while ( my $tree = shift( @result ) ) {
      next
        if ( !$self->allow_duplicates && grep { $tree->cmp( $_ ) == 0 }
             @result );

      push( @filtered, $tree );
    }
    @result = @filtered;
  }
  if ( $self->{current_depth}-- == 0 ) {

    # only execute this code after final ingestion

    if ( !$self->allow_partial ) {
      my $num_tokens = scalar @{ $self->sentence };
      my @complete = grep { $_->topos == $num_tokens } @result;
      if ( !scalar @complete ) {
        $self->log->debug(
               sprintf( 'Incomplete parse;  Fewer than %d tokens were ingested',
                        $num_tokens ) );
        return ();
      }
      @result = @complete;
    }

    @result = map { $_->to_concrete } @result;
  }

  if ( scalar @result ) {
    foreach my $tree ( @result ) {
      $self->log->info( sprintf( $msg, @data, ' ->', $tree->string ) );
    }
  } else {
    my @s = @{ $self->sentence };
    my $string = join( ' ', map { $_->string } @s[ $frompos .. $#s ] );
    $self->log->info( sprintf( $msg, @data, '!->', $string ) );
  }
  return @result;
};

__PACKAGE__->meta->make_immutable;
