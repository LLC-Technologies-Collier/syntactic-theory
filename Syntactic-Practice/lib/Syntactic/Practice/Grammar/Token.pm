package Syntactic::Practice::Grammar::Token;

=head1 NAME

Syntactic::Practice::Grammar::Token - An atomic unit of grammar

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use Moose;
use namespace::autoclean;
use MooseX::Method::Signatures;

has set => ( is       => 'ro',
             isa      => 'TokenSet',
             required => 1, );

has tree => ( is       => 'ro',
              isa      => 'Tree',
              required => 1 );

has next => ( is      => 'rw',
              isa     => 'Maybe[Tree]',
              lazy    => 1,
              build   => '_build_next',
              trigger => \&_set_next, );

has prev => ( is      => 'rw',
              isa     => 'Maybe[Tree]',
              lazy    => 1,
              build   => '_build_prev',
              trigger => \&_set_prev, );

sub copy {
  my ( $self, %attr ) = @_;
  $attr{set} //= Syntactic::Practice::Grammar::TokenSet->new();
  %attr = ( %$self, %attr );
  my $copy = $self->new( %attr );
}

method position () {
  for ( my $i = 0; $i < $self->set->count; $i++ ) {
    return $i if $self->set->tokens[$i]->cmp( $self ) == 0;
  }
  my $msg = 'Did not find self in TokenSet';
  $self->log->error( $msg );
  die $msg;
};

method cmp ( Token $other! ){
  return undef unless $self->set eq $other->set;
  return $self->position <=> $other->position;
};

method _build_next () {
  my( $position_n, $set ) = ( $self->position + 1, $self->set );
  return undef if $position_n == $set->count;
  return $set->tokens[$position_n];
};

method _set_next ( Token $next!, Token $old_next! ) {
  my ( $position_n, $set ) = ( $self->position + 1, $self->set );
  if( $position_n < $set->count ){
    splice( @${ $self->set->tokens }, $position_n, 0, $next );
    $next->next( $old_next );
  }else{
    push( @${ $self->set->tokens }, $next );
  }
  $next->prev($self);
  return $next;
};

method _build_prev () {
  my( $position_p, $set ) = ( $self->position - 1, $self->set );
  return undef if $position_p < 0;
  return $set->tokens[$position_p];
};

method _set_prev ( Token $prev!, Token $old_prev! ) {
  my ( $position_p, $set ) = ( $self->position - 1, $self->set );
  if( $position_p > 0 ){
    splice( @${ $self->set->tokens }, $position_p, 0, $prev );
    $old_prev->next($prev);
  }else{
    unshift( @${ $self->set->tokens }, $prev );
  }
  $prev->next($self);
  return $prev;
};

__PACKAGE__->meta->make_immutable();

