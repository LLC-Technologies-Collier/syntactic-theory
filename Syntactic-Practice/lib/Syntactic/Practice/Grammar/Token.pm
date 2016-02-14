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

with( 'MooseX::Log::Log4perl', 'Syntactic::Practice::Roles::Unique' );

has set => ( is       => 'ro',
             isa      => 'TokenSet',
             required => 1, );

has tree => ( is       => 'ro',
              isa      => 'Tree',
              required => 1 );

has next => ( is      => 'rw',
              isa     => 'Maybe[Token]',
              lazy    => 1,
              builder => '_build_next',
              trigger => \&_set_next, );

has prev => ( is      => 'rw',
              isa     => 'Maybe[Token]',
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
  my ( $self )  = @_;
  my $token_set = $self->set;
  my $tokens    = $token_set->tokens;
  my $count     = $token_set->count;

  for ( my $i = 0; $i < $count; $i++ ) {
    unless ( defined $tokens->[$i] ) {
      my $msg = "Position [$i] of token set is undefined!";
      $self->log->error( $msg );
      confess $msg;
    }
    return $i if ( ( $self <=> $tokens->[$i] ) == 0 );
  }
  my $msg = 'Did not find self in TokenSet';
  $self->log->error( $msg );
  confess $msg;
}

sub string { $_[0]->tree->string }

sub cmp { $_[0]->_guid cmp $_[1]->_guid }

sub _ovld_cmp {
  my ( $a, $b, $swap ) = @_;

  return undef unless defined $a       && defined $b;
  return undef unless ref $a eq ref $b;
  return undef unless $a->can( 'cmp' ) && $b->can( 'cmp' );

  if ( $swap ) { my $tmp = $b; $b = $a; $a = $tmp; }

  $a->cmp( $b );
}

use overload
  q{~~}    => \&_ovld_cmp,
  q{""}    => sub { $_[0]->string },
  '<=>'    => \&_ovld_cmp,
  fallback => 1;

#method _build_next () {
sub _build_next {
  my ( $self ) = @_;
  my ( $position_n, $set ) = ( $self->position + 1, $self->set );
  return undef if $position_n == $set->count;
  return $set->tokens->[$position_n];
}

method _set_next ( Maybe[Token] $next!, Maybe[Token] $old_next? ) {
#sub _set_next {
  #my ( $next, $old_next ) =
  #  pos_validated_list( \@_,
  #                      { type => 'Maybe[Token]' },
  #                      { type => 'Maybe[Token]' } );
  return unless defined $next;

  my $tset = $next->set;

  if ( $tset->count == 0 ) {
    my $msg = '$token->set was empty before calling $token->next($prev)';
    $tset->log->error( $msg );
    confess $msg;
  }

  my $self = defined $old_next ? $old_next->prev : $tset->last;

  $old_next->prev( $next ) if defined $old_next;
  $next->next( $old_next );
  $next->prev( $self );

  return $next;

}

#method _build_prev () {
sub _build_prev {
  my ( $self ) = @_;
  my $tokens = $self->set->tokens;
  $tokens->[0]->prev( undef );
  for ( my $cursor = $tokens->[0];
        defined $cursor->next;
        $cursor = $cursor->next )
  {
    return $cursor if $cursor->next eq $self;
    $cursor = $cursor->next;
  }
  confess 'could not find self in list of tokens!';
}

method _set_prev ( Maybe[Token] $prev!, Maybe[Token] $old_prev? ) {
#sub _set_prev {
#  my ( $prev, $old_prev ) =
#    pos_validated_list( \@_,
#                        { type => 'Maybe[Token]' },
#                        { type => 'Maybe[Token]' } );

  return unless defined $prev;

  my $tset = $prev->set;

  if ( $tset->count == 0 ) {
    my $msg = '$token->set was empty before calling $token->prev($prev)';
    $tset->log->error( $msg );
    confess $msg;
  }

  my $self = defined $old_prev ? $old_prev->next : $tset->first;

  $old_prev->next( $prev ) if defined $old_prev;
  $prev->prev( $old_prev );
  $prev->next( $self );

  return $prev;
}

sub BUILD {
  my ( $self ) = @_;

  my $tset   = $self->set;
  my $tokens = $tset->tokens;

  if ( $tset->count == 0 ) {
    push( @$tokens, $self );
    $tset->first( $self );
    $tset->last( $self );
  }

  $self->log->debug( 'tset GUID is [' . $self->set->_guid . ']' );

  #method BUILD () {
  #  $self->set->append( $self, 0 );

  return $self;
}

__PACKAGE__->meta->make_immutable();

