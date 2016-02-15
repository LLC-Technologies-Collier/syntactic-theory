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
use MooseX::Params::Validate;

use experimental qw(smartmatch);

with( 'MooseX::Log::Log4perl', 'Syntactic::Practice::Roles::Unique' );

has tokens => ( is       => 'rw',
                isa      => 'ArrayRef[Token]',
                lazy     => 1,
                init_arg => undef,
                builder  => '_build_tokens', );

has first => ( is        => 'rw',
               isa       => 'Maybe[Token]',
               lazy      => 1,
               builder   => '_build_first',
               clearer   => '_clear_first',
               predicate => '_has_first',
               init_arg  => undef, );

has last => ( is        => 'rw',
              isa       => 'Maybe[Token]',
              lazy      => 1,
              builder   => '_build_last',
              clearer   => '_clear_last',
              predicate => '_has_last',
              init_arg  => undef, );

sub cmp {
  my ( $self, $other ) = @_;
  return undef unless defined $other && $other->can( '_guid' );
  $self->_guid cmp $other->_guid;
}

method string () {
  join ' ', map { "$_" } @{ $self->tokens };
}

use overload
  q{.}  => sub { $_[0]->copy->append( $_[1]->copy ) },
  q{.=} => sub { $_[0]->append( $_[1] ) },
  q{""} => sub { $_[0]->string },
  '<=>' => sub {
  my $r = $_[0]->cmp( $_[1] );
  $r = 1 unless defined $r;
  ( $_[2] ? -1 : 1 ) * $r;
  },
  fallback => 1;

sub _build_tokens { $_[0]->{_token_array} }

sub BUILD {
  my ( $self ) = @_;
  my @array;
  my $aref = tie @array, "Syntactic::Practice::Grammar::TokenList", $self;
  $self->{_token_array} = \@array;
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

method _build_last () { $self->tokens    ? $self->tokens->[-1] : undef }
method _build_first () { $self->count > 0 ? $self->tokens->[0]  : undef }

method append ( TokenSet|Token $more!, Bool $do_copy=1 ) {
  my ( $tokens, $old_last ) = ( $self->tokens, $self->last );
  my $num_tokens = scalar @$tokens;

  my $copy;
  if ( $more->isa( 'Syntactic::Practice::Grammar::TokenSet' ) ) {
    $copy = $do_copy ? $more->copy : $more;
  } elsif ( $more->isa( 'Syntactic::Practice::Grammar::Token' ) ) {
    $copy = $do_copy ? $more->copy( set => $self ) : $more;
  }

  push( @{ $self->tokens }, $copy );

  return $self;
}

method append_new ( Tree $tree ) {

  my $token =
    Syntactic::Practice::Grammar::Token->new( set  => $self,
                                              tree => $tree );

  push( @{ $self->tokens }, $token );

  return $self;
}

method prepend ( TokenSet|Token $more!, Bool $do_copy = 1 ) {

  my $copy;
  if ( $more->isa( 'Syntactic::Practice::Grammar::TokenSet' ) ) {
    $copy = $do_copy ? $more->copy : $more;
  } elsif ( $more->isa( 'Syntactic::Practice::Grammar::Token' ) ) {
    $copy = $do_copy ? $more->copy( set => $self ) : $more;
  }
  unshift( @{ $self->tokens }, $copy );
  return $self;
}

method count () { $self->tokens ? scalar @{ $self->tokens } : 0 }

__PACKAGE__->meta->make_immutable();
