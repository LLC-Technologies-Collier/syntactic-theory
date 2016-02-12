package Syntactic::Practice::Grammar::Token;

=head1 NAME

Syntactic::Practice::Grammar::Token - An atomic unit of grammar

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use Syntactic::Practice::Types -declare => [qw(Token TokenSet Tree)];

use Moose;
use namespace::autoclean;
use MooseX::Method::Signatures;
use MooseX::Params::Validate;

has set => ( is       => 'ro',
             isa      => 'TokenSet',
             required => 1, );

has tree => ( is       => 'ro',
              isa      => 'Tree',
              required => 1 );

has next => ( is      => 'rw',
              isa     => 'Maybe[Tree]',
              lazy    => 1,
              builder => '_build_next',
              trigger => \&_set_next, );

has prev => ( is      => 'rw',
              isa     => 'Maybe[Tree]',
              lazy    => 1,
              builder => '_build_prev',
              trigger => \&_set_prev, );

sub copy {
  my ( $self, %attr ) = @_;
  $attr{set} //= Syntactic::Practice::Grammar::TokenSet->new();
  %attr = ( %$self, %attr );
  my $copy = $self->new( %attr );
}

#method position () {
sub position {
  my ( $self ) = @_;
  my $token_set = $self->set;
  my $tokens = $token_set->tokens;
  my $count = $token_set->count;

  for ( my $i = 0; $i < $count; $i++ ) {
    return $i if $tokens->[$i]->cmp( $self ) == 0;
  }
  my $msg = 'Did not find self in TokenSet';
  $self->log->error( $msg );
  die $msg;
}

#method cmp ( Token $other! ){
sub cmp {
  my ( $self, $other ) = @_;
  return undef unless $self->set eq $other->set;
  my $result = $self->tree->name() cmp $other->tree->name();
  return $result unless $result == 0;
  if( !defined $self->prev() ){
    return 0 if !defined $other->prev()
  }else{
    return 1 if !defined $other->prev();
    $result = $self->prev() eq $other->prev();
    return 0 if $result == 0;
  }
  if( !defined $self->next() ){
    return 0 if !defined $other->next()
  }else{
    return 1 if !defined $other->next();
    $result = $self->next() eq $other->next();
    return 0 if $result == 0;
  }
  return $result;
}

#method _build_next () {
sub _build_next {
  my ( $self ) = @_;
  my ( $position_n, $set ) = ( $self->position + 1, $self->set );
  return undef if $position_n == $set->count;
  return $set->tokens->[$position_n];
}

#method _set_next ( Token $next!, Token $old_next! ) {
sub _set_next {
  my ( $self, $next, $old_next ) = @_;
  return unless defined $next;
  my ( $position_n, $set ) = ( $self->position + 1, $self->set );
  if ( $position_n < $set->count ) {
    splice( @${ $self->set->tokens }, $position_n, 0, $next );
    $next->next( $old_next );
  } else {
    push( @${ $self->set->tokens }, $next );
  }
  $next->prev( $self );
  return $next;
}

#method _build_prev () {
sub _build_prev {
  my ( $self ) = @_;
  my $tokens = $self->set->tokens;
  $tokens->[0]->prev(undef);
  for( my $cursor = $tokens->[0]; defined $cursor->next; $cursor = $cursor->next ){
    return $cursor if $cursor->next eq $self;
    $cursor = $cursor->next;
  }
  die 'could not find self in list of tokens!';
}

#method _set_prev ( Token $prev!, Token $old_prev! ) {
sub _set_prev {
  my ( $self, $prev, $old_prev ) = @_;
  return unless defined $prev;
  my ( $position_p, $set ) = ( $self->position - 1, $self->set );
  if ( $position_p > 0 ) {
    splice( @${ $self->set->tokens }, $position_p, 0, $prev );
    $old_prev->next( $prev );
  } else {
    unshift( @{ $self->set->tokens }, $prev );
  }
  $prev->next( $self );
  return $prev;
}

sub BUILD {
my($self) = @_;
#method BUILD () {
# $self->set->append( $self )
};

__PACKAGE__->meta->make_immutable();

