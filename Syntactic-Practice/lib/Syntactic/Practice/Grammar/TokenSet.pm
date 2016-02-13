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

with 'MooseX::Log::Log4perl';

has tokens => ( is      => 'rw',
                isa     => 'ArrayRef[Token]',
                lazy    => 1,
                builder => '_build_tokens', );

has first => ( is        => 'rw',
               isa       => 'Maybe[Token]',
               lazy      => 1,
               builder   => '_build_first',
               trigger   => \&_set_first,
               clearer   => '_clear_first',
               predicate => '_has_first',
               init_arg  => undef, );

has last => ( is        => 'rw',
              isa       => 'Maybe[Token]',
              lazy      => 1,
              builder   => '_build_last',
              trigger   => \&_set_last,
              clearer   => '_clear_last',
              predicate => '_has_last',
              init_arg  => undef, );

has '_guid' => ( is       => 'ro',
                 isa      => 'Data::GUID',
                 lazy     => 1,
                 builder  => '_build_guid',
                 init_arg => undef, );

sub _build_guid { new Data::GUID }

sub cmp {
  my( $self, $other );
  return undef unless defined $other;
  return undef unless $other->can('_guid');
  $self->_guid cmp $other->_guid
}


method string () {
  join ' ', map { $_->string } @{ $self->tokens };
};

use overload
  q{""}    => sub { $_[0]->string },
  '<=>'    => sub { ( $_[2] ? -1 : 1 ) * $_[0]->cmp( $_[1] ) },
  fallback => 1;

sub _build_tokens { [] }

sub copy {
  my ( $self, %attr ) = @_;
  %attr = ( %$self, %attr );
  map { delete $attr{$_} } ( qw( tokens first last ) );

  my $copy = $self->new( %attr );
  return $copy unless $self->count;

  $copy->tokens( [ map { $_->copy( set => $copy ) } @{ $self->tokens } ] );
  return $copy;
}

method _build_last () { $self->tokens ? $self->tokens->[-1] : undef };

#method _set_last ( Token $last!, Maybe[Token] $old_last! ) {
sub _set_last {
  my ( $last, $old_last ) =
    pos_validated_list( \@_, { type => 'Token' }, { type => 'Maybe[Token]' } );
}

method _set_last ( Token $last!, Token $old_last? ) {
  my ( $tokens, $cursor, $i ) = ( $self->tokens, $last, $self->count + 1 );

  $last->next( undef );
  $tokens->[ $i-- ] = $last;
  $last->prev( $old_last );

  while ( ( $i > 0 ) && ( $tokens->[ $i-- ] = $cursor->prev() ) ) {
    $cursor = $cursor->prev();
  }
  $cursor->prev( undef );

  return $last;
};

#method append ( 'TokenSet|Token' $more!, 'Bool' $copy? ) {
sub append {
  my ( $self, $more, $do_copy ) = @_;

  $do_copy //= 1;

  #  my ( $self, @arg ) = @_;
  #  my ( $more, $do_copy ) =
  #    pos_validated_list( \@arg,
  #                        { type => 'Token|TokenSet' },
  #                        { type => 'Bool', default => 1 } );
  my ( $tokens, $old_last ) = ( $self->tokens, $self->last );
  my $num_tokens = scalar @$tokens;

  if ( $more->isa( 'Syntactic::Practice::Grammar::TokenSet' ) ) {
    my $copy = $do_copy ? $more->copy : $more;
    if ( $num_tokens == 0 ) {
      $self->tokens( $copy->tokens );
      $self->first( $copy->first );
      $self->last( $copy->last );
    } else {
      $self->last( $copy->last );
      $old_last->next( $copy->first ) if defined $old_last;
      $self->first( $copy->first ) unless $self->first;
      if ( $do_copy ) {
        delete $copy->{tokens};
        undef $copy;
      }
    }
  } elsif ( $more->isa( 'Syntactic::Practice::Grammar::Token' ) ) {
    my $copy = $do_copy ? $more->copy( set => $self ) : $more;
    if ( $num_tokens == 0 ) {
      $self->first( $copy );
      $copy->next( undef );
      $copy->prev( undef );
      $self->last( $copy );
      $self->tokens( [$copy] );
    } else {
      $self->first( $copy );
      $self->last( $copy );
      $self->tokens( [$copy] );
      undef $copy if $do_copy;
    }
  }

  my ( $cursor, $i ) = ( $self->first, 0 );

  $cursor->prev( undef ) if defined $cursor;

  $tokens->[$i] = $self->first;
  while ( $tokens->[ ++$i ] = $cursor->next ) {
    $tokens->[$i]->prev( $cursor );
    last unless $cursor;
    $cursor = $cursor->next;
  }
  pop @$tokens;
  $cursor->next( undef );

  return $self;
}

sub append_new {
  my ( $self, @arg ) = @_;

  my ( $tree ) = pos_validated_list( \@arg, { type => 'Tree' }, );

  my $tokens = $self->tokens;
  my $token =
    Syntactic::Practice::Grammar::Token->new( set  => $self,
                                              tree => $tree );

  if ( scalar @$tokens ) {
    push( @$tokens, $token );
    $self->last->next( $token );
  } else {
    $self->first( $token );
    $self->last( $token );
    $token->prev( undef );
  }
  $token->next( undef );

  return $self;
}

method _build_first () { $self->count > 0 ? $self->tokens->[0] : undef };

method _set_first ( Token $first!, Token $old_first? ) {

  #sub _set_first {
  #  my( $first, $old_first ) =
  #    pos_validated_list( \@_,
  #                        { type => 'Token' },
  #                        { type => 'Maybe[Token]' } );

  #  my $self = $first->set;

  my ( $tokens, $cursor, $i ) = ( $self->tokens, $first, 0 );

  $first->prev( undef );
  $first->next( $old_first );
  $tokens->[ $i++ ] = $first;
  while ( $tokens->[ $i++ ] = $cursor->next ) { $cursor = $cursor->next }
  pop @$tokens;

  return $first;
};

#method prepend ( 'TokenSet|Token' $more!, 'Bool' $do_copy = 1 ) {
sub prepend {
  my ( $self, @arg ) = @_;

  my ( $more, $do_copy ) =
    pos_validated_list( \@arg,
                        { type => 'Token|TokenSet' },
                        { type => 'Bool', default => 1 } );

  if ( $more->isa( 'Syntactic::Practice::Grammar::TokenSet' ) ) {
    my $copy = $do_copy ? $more->copy : $more;
    $self->first( $copy->first );
    if ( $do_copy ) {
      delete $copy->{tokens};
      undef $copy;
    }

  } elsif ( $more->isa( 'Syntactic::Practice::Grammar::Token' ) ) {
    my $copy = $do_copy ? $more->copy( set => $self ) : $more;
    $self->first( $copy );
    undef $copy if $do_copy;

  }
  return $self;
}

method count () { $self->tokens ? scalar @{ $self->tokens } : 0 };

__PACKAGE__->meta->make_immutable();
