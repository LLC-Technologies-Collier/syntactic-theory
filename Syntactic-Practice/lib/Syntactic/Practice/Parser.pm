package Syntactic::Practice::Parser;

use TryCatch;

use MooseX::Params::Validate;

use Syntactic::Practice::Tree::Start;
use Syntactic::Practice::Tree::Abstract::Null;
use Syntactic::Practice::Tree::Abstract::Lexical;
use Syntactic::Practice::Tree::Abstract::Phrasal;
use Syntactic::Practice::Tree::Abstract::Start;
use Syntactic::Practice::Tree::Null;
use Syntactic::Practice::Tree::Lexical;
use Syntactic::Practice::Tree::Phrasal;
use Syntactic::Practice::Tree::Start;
use Syntactic::Practice::Grammar;

use Moose;

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

has grammar => (
  is      => 'ro',
  isa     => 'Syntactic::Practice::Grammar',
  default => sub {
    Syntactic::Practice::Grammar->new( { locale => 'en_US.UTF-8' } );
  } );

sub ingest {
  my ( $self, %opt ) =
    validated_hash(
     \@_,
     frompos => { isa => 'PositiveInt', optional => 1, default => 0 },
     mother  => { isa => 'MotherValue', optional => 1 },
     symbol => { isa => 'Syntactic::Practice::Grammar::Symbol', optional => 1 },
    );

  my ( $from, $mother, $target_symbol ) = @opt{qw( frompos mother symbol )};

  my $num_words = scalar( @{ $self->sentence } );
  die "insufficient words to license phrase"
    if ( $from >= $num_words );

  my %tree_params = ( frompos => $from );

  my $msg_format =
    'Word [%s] depth [%d], position [%d] with label [%s] not licensed by [%s]';
  my( $target );
  if ( $mother ) {
    die 'symbol not specified' unless $target_symbol;
    $target = $self->sentence->[$from];
    die sprintf( $msg_format,
                 $target->daughters->word, $target->depth,
                 $target->frompos,         $target->label,
                 $target_symbol->label )
      unless $target->label eq $target_symbol->label;

    $tree_params{daughters} = [ $target->daughters ];
    $tree_params{depth}     = $mother->depth + 1;
    $tree_params{mother}    = $mother;
    $tree_params{symbol}    = $target_symbol;
    $tree_params{label}     = $target->label;
    $target = $target->new( %tree_params );
    if ( $target_symbol->is_terminal ) {
      return $target;
    }
  } else {
    $target = Syntactic::Practice::Tree::Abstract::Start->new();
    $tree_params{label}  = $target->label;
    $tree_params{depth}  = $target->depth;
    $tree_params{symbol} = $target_symbol = $target->symbol;
  }

  my @rule = $self->grammar->rule( identifier => $target_symbol->label )
    or die( sprintf( 'bad rule identifier: [%s]!', $target_symbol->label ) );

  my @error        = ();
  my @return       = ();
  my $all_terminal = 1;
  my @symbol_list;
  foreach my $rule ( @rule[0] ) {    # TODO: support multiple rules

    if ( $rule->identifier eq 'X' ) {
      my @pre_conj;
      my $has_conj = 0;
      foreach my $tree ( ( $self->sentence )[ $from .. $#{ $self->sentence } ] )
      {
        if ( $tree->label eq 'CONJ' ) {
          $has_conj = 1;
          last;
        }
        push( @pre_conj, $tree );
      }
      unless ( $has_conj ) {
        push( @error, q{Rule 'X' requires CONJ, but none found} );
        next;
      }
      if ( scalar @pre_conj == 1 ) {
        push( @symbol_list, [ $rule->symbols ] );
      } elsif ( scalar @pre_conj > 1 ) {
        my @r = $self->grammar->rule( daughters => \@pre_conj );
        if ( scalar @r == 0 ) {
          push( @error,
qq{Symbols [@pre_conj] do not combine to make phrase of any known type} );
          next;
        }
        foreach my $r ( @r ) {
          push( @symbol_list, [ $r->label, 'CONJ', $r->label ] );
        }
      } else {
        push( @error,
              q{Rule 'X' requires symbols before CONJ, but none found} );
        next;
      }
    } else {
      push( @symbol_list, [ $rule->symbols ] );
    }
  }

  while ( my $s = shift( @symbol_list ) ) {
    my @d_list = ( [] );
    my @symbol = @$s;
    foreach my $symbol ( @symbol ) {
      my $symbol_label = $symbol->label;

      my $optional = $symbol->optional;
      my $repeat   = $symbol->repeat;

      my $optAtPos = {};

      for ( my $dlist_idx = 0; $dlist_idx < scalar @d_list; $dlist_idx++ ) {
        my $daughter = $d_list[$dlist_idx];

        my $curpos = ( scalar @$daughter ? $daughter->[-1]->topos : $from );

        next if $curpos == $num_words;

        if ( $optional && !exists $optAtPos->{$curpos} ) {
          my $class = 'Syntactic::Practice::Tree::Abstract::Null';
          my $tree = $class->new( %tree_params, frompos => $curpos );
          $optAtPos->{$curpos} = $tree;
          splice( @d_list, $dlist_idx, 0, ( [ @$daughter, $tree ] ) );
          next;
        }

        my @tree;
        try {
          @tree = $self->ingest( frompos => $curpos,
                                 mother  => $target,
                                 symbol  => $symbol );
        }
        catch {
          warn( "Failed call to ingest: $@" );
            push( @error, $@ );
            splice( @d_list, $dlist_idx, 1 );
            $dlist_idx--;
            next;
        };
        foreach my $tree ( @tree ) {
          my @new = ( [ @$daughter, $tree ] );
          push( @new, [ @$daughter, $tree ] ) if ( $repeat );
          splice( @d_list, $dlist_idx, 1, ( @new ) );
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
        Syntactic::Practice::Tree::Abstract::Phrasal->new(
                                                         %tree_params,
                                                         topos => $d[-1]->topos,
                                                         daughters => \@d );

      if ( grep { $tree->cmp( $_ ) == 0 } @return ) {
        next unless $self->allow_duplicates;
      }
      push( @return, $tree );
    }
  }

  return ( @return ) if scalar @return;
  die @error;
}

around 'new' => sub {
  my ( $orig, $self, @arg ) = @_;

  my $obj = $self->$orig( @arg );

  $obj->{current_depth} = 0;

  return $obj;
};

around 'ingest' => sub {
  my ( $orig, $self, @arg ) = @_;

  my ( $s, %opt ) =
    validated_hash(
     [ $self, @arg ],
     frompos => { isa => 'PositiveInt', optional => 1, default => 0 },
     mother  => { isa => 'MotherValue', optional => 1 },
     symbol => { isa => 'Syntactic::Practice::Grammar::Symbol', optional => 1 },
    );

  my $msg =
    "calling ingest at depth $self->{current_depth}, position $opt{frompos}";

  if ( $self->{current_depth}++ >= $self->max_depth ) {
    --$self->{current_depth};
    die 'exceeded maximum recursion depth [' . $self->max_depth . ']';
  }

  my @result = $self->$orig( @arg );

  if ( $self->{current_depth}-- == 0 ) {

    # only return the trees with all symbols ingested
    my $num_symbols = scalar @{ $self->sentence };
    my @num_ingested;
    my @complete;
    foreach my $tree ( @result ) {
      push( @num_ingested, ( $tree->daughters )[-1]->topos );
      push( @complete, $tree ) if ( $num_ingested[-1] == $num_symbols );
    }

    unless ( $self->allow_partial ) {
      my $msg_fmt =
          'Incomplete parse;  '
        . '%d symbols in input, only [ %d ] symbols were ingested';
      die sprintf( $msg_fmt, $num_symbols, $num_ingested[0] )
        unless scalar @complete;
    }

    return @complete;
  }
  return @result;
};

no Moose;
__PACKAGE__->meta->make_immutable( inline_constructor => 0 );
