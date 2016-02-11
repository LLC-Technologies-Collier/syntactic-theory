package Syntactic::Practice::Grammar::TokenSet;

=head1 NAME

Syntactic::Practice::Grammar::TokenSet - A set of Tokens

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use Syntactic::Practice::Types -declare => [qw(Token TokenSet Tree)];

use Moose;
use namespace::autoclean;
use MooseX::Method::Signatures;

has tokens => ( is      => 'rw',
                isa     => 'ArrayRef[Token]',
                lazy    => 1,
                builder => '_build_tokens', );

has first => ( is      => 'rw',
               isa     => 'Maybe[Token]',
               lazy    => 1,
               builder => '_build_first',
               trigger => \&_set_first, );

has last => ( is      => 'rw',
              isa     => 'Maybe[Token]',
              lazy    => 1,
              builder => '_build_last',
              trigger => \&_set_last, );

sub _build_tokens {
  return [];
}

sub copy {
  my ( $self, %attr ) = @_;
  %attr = ( %$self, %attr );
  map { delete $attr{$_} } ( qw( tokens first last ) );

  my $copy = $self->new( %attr );
  return $copy unless $self->count;

  $copy->tokens( [ map { $_->copy( set => $copy ) } @{ $self->tokens } ] );
  return $copy;
}

method _build_last () { $self->tokens ? $self->tokens->[-1] : undef }

method _set_last ( Token $last!, Maybe[Token] $old_last! ) {
  return $last unless $old_last;
  my $cursor = $last;
  while ( $cursor->prev ) { $cursor = $cursor->prev }
  $old_last->next( $cursor );
  return $last;
}

#method append ( 'TokenSet|Token' $more! ) {
sub append {
my($self,$more) = @_;
  if ( $more->isa( 'Syntactic::Practice::Grammar::TokenSet' ) ) {
    $self->last( $more->copy->last );
  } elsif ( $more->isa( 'Syntactic::Practice::Grammar::Token' ) ) {
    $self->last( $more->copy( set => $self ) );
  }
  return $self;
}

method _build_first () { $self->tokens ? $self->tokens->[0] : undef }

method _set_first ( Token $first!, Maybe[Token] $old_first! ) {
  $self->first->next( $old_first );
  return $first unless $old_first;
  my $cursor = $first;
  while ( $cursor->next ) { $cursor = $cursor->next }
  $cursor->next( $old_first );
  return $first;
}

#method prepend ( 'TokenSet|Token' $more! ) {
sub prepend {
my($self,$more) = @_;
  if ( $more->isa( 'Syntactic::Practice::Grammar::TokenSet' ) ) {
    $self->first( $more->copy->first );
  } elsif ( $more->isa( 'Syntactic::Practice::Grammar::Token' ) ) {
    $self->first( $more->copy( set => $self ) );
  }
  return $self;
}

method count () { $self->tokens ? scalar @{ $self->tokens } : 0 }

__PACKAGE__->meta->make_immutable();
