package Syntactic::Practice::Grammar::TokenList;

=head1 NAME

Syntactic::Practice::Grammar::TokenList - A tied list of Tokens

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use Carp;
use strict;
use Params::Validate qw( validate_pos validate_with );

#our $NEGATIVE_INDICES = 1;

sub TIEARRAY {
  my ( $class, $set ) =
    validate_pos( @_, 1, { isa => 'Syntactic::Practice::Grammar::TokenSet' } );
  bless { set => $set, array => [] }, $class;
}

sub FETCH { $_[0]->{array}->[ $_[1] ] }

my $number_rx = qr/^\d+$/;

sub STORE {
  my ( $self, $i, $token ) =
    validate_pos( @_, 1,
                  { regex => $number_rx },
                  { isa   => 'Syntactic::Practice::Grammar::Token' } );

  die 'This token does not belong to the correct set'
    unless ( ( $self->{set} <=> $token->set ) == 0 );
  my $dst = $self->{array};

  my ( $old, $prev, $next ) = $dst->[$i];
  if ( $i == 0 ) {
    $prev = undef;
  } else {
    $prev = $dst->[ $i - 1 ];
    $prev->next( $token ) if defined $prev;
  }
  if ( $i >= $#{$dst} ) {
    $next = undef;
  } else {
    $next = $dst->[ $i + 1 ];
    $next->prev( $token ) if defined $next;
  }

  # TODO: clean up $old

  $token->next( $next );
  $token->prev( $prev );

  $dst->[$i] = $token;
}

sub _permit_elements {
  my ( $self, @input ) = @_;

  my ( $prev, @tokens ) = ( undef );

  foreach my $element ( @input ) {
    if ( $element->isa( 'Syntactic::Practice::Grammar::TokenSet' ) ) {
      my @permitted =
        $self->_permit_elements( map { $_->copy( set => $self->{set} ) }
                                 @{ $element->tokens } );
      $permitted[0]->prev( $prev );
      $prev->next( $permitted[0] ) if defined $prev;
      push( @tokens, @permitted );
      $prev = $tokens[-1];
      next;
    }

    die 'attempted to append a non-token element'
      unless $element->isa( 'Syntactic::Practice::Grammar::Token' );

    die( 'attempted to append a token element with incorrect set' )
      unless ( ( $element->set <=> $self->{set} ) == 0 );

    $element->prev( $prev );
    $prev->next( $element ) if defined $prev;
    push( @tokens, $element );
    $prev = $element;
  }

  $tokens[0]->prev( undef );
  $tokens[-1]->next( undef );

  return @tokens;
}

sub PUSH {
  my ( $self, @input ) = @_;

  my @tokens = $self->_permit_elements( @input );

  return unless @tokens;

  my $dst = $self->{array};

  if ( scalar @$dst ) {
    $dst->[-1]->next( $tokens[0] );
    $tokens[0]->prev( $dst->[-1] );
  } else {
    $self->{set}->first( $tokens[0] );
  }

  push( @$dst, @tokens );

  $self->{set}->last( $tokens[-1] );
}

sub UNSHIFT {
  my ( $self, @input ) = @_;

  my @tokens = $self->_permit_elements( @input );

  return unless @tokens;

  my $dst = $self->{array};

  if ( scalar( @$dst ) ) {
    $dst->[0]->prev( $tokens[-1] );
    $tokens[-1]->next( $dst->[0] );
  } else {
    $self->{set}->last( $tokens[-1] );
  }

  unshift( @$dst, @tokens );
  $self->first( $tokens[0] );
}

sub SPLICE {
  my ( $self, $from, $length, @input ) = @_;

  my $dst = $self->{array};
  my $to  = $from + $length;

  my $prev = $from == 0      ? undef : $dst->[ $from - 1 ];
  my $next = $to >= $#{$dst} ? undef : $dst->[ $to + 1 ];

  my @deleted = $dst->[ $from .. $to ];

  if ( @input ) {
    my @tokens = $self->_permit_elements( @input );

    $prev->next( $tokens[0] )  if defined $prev;
    $next->prev( $tokens[-1] ) if defined $next;
    $tokens[0]->prev( $prev );
    $tokens[-1]->next( $next );
    splice @$dst, $from, $length, @tokens;
  } else {
    $next->prev( $prev ) if defined $next;
    $prev->next( $next ) if defined $prev;
    splice @$dst, $from, $length;
  }

  $self->{set}->first( $dst->[0] );
  $self->{set}->last( $dst->[-1] );
}

sub FETCHSIZE { scalar @{ $_[0]->{array} } }
sub STORESIZE { $#{ $_[0]->{array} } = $_[1] - 1 }
sub EXTEND    { $_[0]->STORESIZE( $_[1] ) }
sub CLEAR     { $_[0]->STORESIZE( 0 ) }
sub EXISTS    { exists $_[0]->{array}->[ $_[1] ] }
sub DELETE    { delete $_[0]->{array}->[ $_[1] ] }
sub POP       { pop @{ $_[0]->{array} } }
sub SHIFT     { shift @{ $_[0]->{array} } }

sub UNTIE   { }
sub DESTROY { }

1;
