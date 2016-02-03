package Syntactic::Practice::Parser;

=head1 NAME

Syntactic::Practice::Parser - A natural language parser

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use Moose;
use MooseX::Method::Signatures;

with 'MooseX::Log::Log4perl';

has max_depth => ( is      => 'ro',
                   isa     => 'PositiveInt',
                   default => 5 );

has allow_partial => ( is      => 'ro',
                       isa     => 'Bool',
                       default => 0 );

has allow_duplicates => ( is      => 'ro',
                          isa     => 'Bool',
                          default => 0 );

has prune_nulls => ( is      => 'ro',
                     isa     => 'Bool',
                     default => 1 );

has sentence => (
                is  => 'ro',
                isa => 'ArrayRef[Syntactic::Practice::Tree::Abstract::Lexical]',
                required => 1, );

method ingest( PositiveInt : $frompos,
               Syntactic::Practice::Grammar::Category : $category ) {

  my $num_words = scalar( @{ $self->sentence } );
    if ( $frompos >= $num_words ) {
    $self->log->debug( "insufficient words to license phrase" );
    return ();
  }

  my %tree_params = ( frompos => $frompos,
                      depth   => $self->{current_depth}
  );

    my $msg_format =
    'Word [%s] depth [%d], position [%d] with label [%s] not licensed by [%s]';
    my ( $target );
    if ( $category->is_start ) {
    $target                = Syntactic::Practice::Tree::Abstract::Start->new();
    $tree_params{label}    = $target->label;
    $tree_params{depth}    = $target->depth;
    $tree_params{category} = $target->category;
    $category              = $target->category;
  } else {

    if ( $category->is_terminal ) {
      $target = $self->sentence->[$frompos];
      $target = $target->new( %$target, %tree_params, );
      return $target if ( $target->label eq $category->label );

      $self->log->debug(
                         sprintf( $msg_format,
                                  $target->daughters->word, $target->depth,
                                  $target->frompos,         $target->label,
                                  $category->label ) );
      return ();
    }
    $tree_params{category} = $category;

    $self->log->debug(   'Creating Abstract Phrasal tree with category ['
                       . $category->label
                       . ']' );

    $target = Syntactic::Practice::Tree::Abstract::Phrasal->new( %tree_params );
  }

  my $rule = Syntactic::Practice::Grammar::Rule->new( category => $category );

    unless ( $rule ) {
    $self->log->debug(
                    sprintf( 'bad rule identifier: [%s]!', $category->label ) );
    return ();
  }

  my @error          = ();
    my @return       = ();
    my $all_terminal = 1;
    my @factor_list;
    my $terms = $rule->terms;
    foreach my $term ( @$terms[0] ) {    # TODO: support multiple terms
    my ( $s ) = $term->factors;
    my @d_list = ( [] );
    my @factor = @$s;
    foreach my $factor ( @factor ) {
      my $factor_label = $factor->label;

      my $optional = $factor->optional;
      my $repeat   = $factor->repeat;

      my $optAtPos = {};

      for ( my $dlist_idx = 0; $dlist_idx < scalar @d_list; $dlist_idx++ ) {
        my $daughter = $d_list[$dlist_idx];

        my $curpos = ( scalar @$daughter ? $daughter->[-1]->topos : $frompos );

        next if $curpos == $num_words;

        if ( $optional && !exists $optAtPos->{$curpos} ) {
          my %mother = ( $factor->is_start ? () : ( mother => $target ) );
          my $class = 'Syntactic::Practice::Tree::Abstract::Null';
          my $tree = $class->new( depth   => $self->{current_depth} + 1,
                                  frompos => $curpos,
                                  %mother,
                                  label => $factor->label, );
          $optAtPos->{$curpos} = $tree;
          splice( @d_list, $dlist_idx, 0, ( [ @$daughter, $tree ] ) );
          next;
        }

        splice( @d_list, $dlist_idx, 1 );
        my @tree = $self->ingest( frompos  => $curpos,
                                  category => $factor->category );

        unless ( @tree ) {
          my $msg_format =
            'Failed to ingest sentence starting at position [%d] as [%s]';
          $self->log->debug( sprintf( $msg_format, $curpos, $factor->label ) );
          $dlist_idx--;
          next;
        }
        foreach my $tree ( @tree ) {
          $tree->mother( $target );

          my @new = ( [ @$daughter, $tree ] );
          push( @new, [ @$daughter, $tree ] ) if ( $repeat );
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
      next unless scalar @d;

      my $tree =
        $target->new( %tree_params,
                      topos     => $d[-1]->topos,
                      daughters => \@d );

      if ( grep { $tree->cmp( $_ ) == 0 } @return ) {
        next unless $self->allow_duplicates;
      }
      push( @return, $tree );
    }
  }

  return ( @return ) if scalar @return;
    $self->log->debug( @error );
    return ();
               }

  sub BUILD {
  my ( $self ) = @_;

  $self->{current_depth} = 0;
}

around 'ingest' => sub {
  my ( $orig, $self, @arg ) = @_;

  if ( $self->{current_depth}++ >= $self->max_depth ) {
    --$self->{current_depth};
    $self->log->debug(
                'exceeded maximum recursion depth [' . $self->max_depth . ']' );
    return ();
  }

  my @result = $self->$orig( @arg );

  if ( $self->{current_depth}-- == 0 ) {

    # only return the trees with all factors ingested
    my $num_factors = scalar @{ $self->sentence };
    my @num_ingested;
    my @complete;
    foreach my $tree ( @result ) {
      push( @num_ingested, ( $tree->daughters )[-1]->topos );
      push( @complete, $tree ) if ( $num_ingested[-1] == $num_factors );
    }

    unless ( $self->allow_partial ) {
      my $msg_fmt =
          'Incomplete parse;  '
        . '%d factors in input, only [ %d ] factors were ingested';
      unless ( scalar @complete ) {
        $self->log->debug(
                          sprintf( $msg_fmt, $num_factors, $num_ingested[0] ) );
        return ();
      }
    }

    return @complete;
  }
  return @result;
};

no Moose;
__PACKAGE__->meta->make_immutable;
