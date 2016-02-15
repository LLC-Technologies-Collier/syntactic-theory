package Syntactic::Practice::Grammar::TokenList;

=head1 NAME

Syntactic::Practice::Grammar::TokenList - A tied list of Tokens

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use Carp;
use strict;
use Params::Validate;

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
    unless $self->{set} <=> $token->set;

  my $prev = $i == 0 ? undef : $self->{array}->[ $i - 1 ];
  my $next = $i == $#{ $self->{array} } ? undef : $self->{array}->[ $i + 1 ];

  my $old = $self->{array}->[$i];

  $self->{array}->[$i] = $token;
}
sub FETCHSIZE { scalar @{ $_[0]->{array} } }
sub STORESIZE { $#{ $_[0]->{array} } = $_[1] - 1 }
sub EXTEND    { $_[0]->STORESIZE( $_[1] ) }
sub CLEAR     { $_[0]->STORESIZE( 0 ) }
sub EXISTS    { exists $_[0]->{array}->[ $_[1] ] }
sub DELETE    { delete $_[0]->{array}->[ $_[1] ] }
sub POP       { pop @{ $_[0]->{array} } }
sub SHIFT     { shift @{ $_[0]->{array} } }
sub PUSH      { push @{ $_[0]->{array} }, $_[ 1 .. $#_ ] }
sub UNSHIFT   { unshift @{ $_[0]->{array} }, $_[ 1 .. $#_ ] }
sub SPLICE    { splice @{ $_[0]->{array} }, $_[ 1 .. $#_ ] }

sub UNTIE   { }
sub DESTROY { }

1;
