package Syntactic::Practice::Parser;

=head1 NAME

Syntactic::Practice::Parser - A natural language parser

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use MooseX::Params::Validate;
use Syntactic::Practice::Util;
use Syntactic::Practice::Types;

use Syntactic::Practice::Tree::Start;
use Syntactic::Practice::Tree::Abstract::Null;
use Syntactic::Practice::Tree::Abstract::Lexical;
use Syntactic::Practice::Tree::Abstract::Phrasal;
use Syntactic::Practice::Tree::Abstract::Start;
use Syntactic::Practice::Tree::Null;
use Syntactic::Practice::Tree::Lexical;
use Syntactic::Practice::Tree::Phrasal;
use Syntactic::Practice::Grammar;
use Syntactic::Practice::Grammar::RuleSet;

use Moose;

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
           category =>
             { isa => 'Syntactic::Practice::Grammar::Category', optional => 0 },
    );

  my ( $from, $category ) = @opt{qw( frompos category )};

  my $num_words = scalar( @{ $self->sentence } );
  if ( $from >= $num_words ) {
    $self->log->debug( "insufficient words to license phrase" );
    return ();
  }

  my %tree_params = ( frompos => $from,
                      depth   => $self->{current_depth} );

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
      $target = $self->sentence->[$from];
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

    $target = Syntactic::Practice::Tree::Abstract->new( %tree_params );
  }

  my $ruleSet =
    Syntactic::Practice::Grammar::RuleSet->new( category => $category );

  unless ( $ruleSet ) {
    $self->log->debug(
                    sprintf( 'bad rule identifier: [%s]!', $category->label ) );
    return ();
  }

  my @error        = ();
  my @return       = ();
  my $all_terminal = 1;
  my @symbol_list;
  my $rules = $ruleSet->rules;
  foreach my $rule ( @$rules[0] ) {    # TODO: support multiple rules

    if ( $rule->label eq 'X' ) {
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
        push( @symbol_list, $rule->symbols );
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
      push( @symbol_list, $rule->symbols );
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

        splice( @d_list, $dlist_idx, 1 );
        my @tree = $self->ingest( frompos  => $curpos,
                                  category => $symbol->category );

        unless ( @tree ) {
          my $msg_format =
            'Failed to ingest sentence starting at position [%d] as [%s]';
          $self->log->debug( sprintf( $msg_format, $curpos, $symbol->label ) );
          $dlist_idx--;
          next;
        }
        foreach my $tree ( @tree ) {
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
        Syntactic::Practice::Tree::Abstract->new(
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
  $self->log->debug( @error );
  return ();
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
           category =>
             { isa => 'Syntactic::Practice::Grammar::Category', optional => 1 },
    );

  my $msg =
    "calling ingest at depth $self->{current_depth}, position $opt{frompos}";

  if ( $self->{current_depth}++ >= $self->max_depth ) {
    --$self->{current_depth};
    $self->log->debug(
                'exceeded maximum recursion depth [' . $self->max_depth . ']' );
    return ();
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
      unless ( scalar @complete ) {
        $self->log->debug(
                          sprintf( $msg_fmt, $num_symbols, $num_ingested[0] ) );
        return ();
      }
    }

    return @complete;
  }
  return @result;
};

no Moose;
__PACKAGE__->meta->make_immutable( inline_constructor => 0 );
