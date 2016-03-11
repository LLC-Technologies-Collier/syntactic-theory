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

has tokens => ( is      => 'rw',
                isa     => 'ArrayRef[Token|Tree]|TokenSet',
                lazy    => 1,
                builder => '_build_tokens', );

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

has frompos => ( is       => 'ro',
                 isa      => 'PositiveInt',
                 lazy     => 1,
                 builder  => '_build_frompos',
                 init_arg => undef );

has topos => ( is       => 'ro',
               isa      => 'PositiveInt',
               lazy     => 1,
               builder  => '_build_topos',
               init_arg => undef );

sub current {
  my ( $self, $position ) = @_;
  if ( defined $position ) {
    if ( $position < scalar @{ $self->tokens } ) {
      $self->{_current} = $self->tokens->[$position];
    } else {
      my $msg = 'Attempt to set index of token set to value outside of range';
      $self->log->error( $msg );
      confess( $msg );
    }
  } else {
    $self->{_current} //= $self->tokens->[0];
  }
}

sub next { $_[0]->{_current} = $_[0]->current->next }

sub prev { $_[0]->{_current} = $_[0]->current->prev }

sub all { @{ $_[0]->tokens } }

sub remainder {
  my ( $self ) = @_;
  my $i        = $self->current->position;
  my $n        = $#{ $self->tokens };
  @{ $self->tokens->[ $i .. $n ] };
}

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

sub _build_tokens  { $_[0]->{_token_array} }
sub _build_frompos { $_[0]->first->tree->frompos }
sub _build_topos   { $_[0]->first->tree->topos }

sub BUILD {
  my ( $self, $args ) = @_;
  my @array;
  my $aref = tie @array, "Syntactic::Practice::Grammar::TokenList", $self;
  my $tkarg = delete $self->{tokens};
  $self->{tokens} = $self->{_token_array} = \@array;

  return unless defined $tkarg;
  my $tr_class = 'Syntactic::Practice::Tree';
  if ( ref $tkarg eq 'ARRAY' ) {
    foreach my $tree ( map { $_->isa( $tr_class ) ? $_ : $_->tree } @$tkarg ) {
      $self->append_new( $tree );
    }
  } elsif ( $tkarg->isa( 'Syntactic::Practice::Grammar::TokenSet' ) ) {
    $#array = -1;
    push( @array,
          map { $_->copy( set => $self ) } @{ $tkarg->{_token_array} } );
  } else {
    my $msg = 'unknown token representation: ' . ref $tkarg;
    $self->log->error( $msg );
    die( $msg );
  }
  return $self;
}

sub copy {
  my ( $self, %attr ) = @_;
  %attr = ( %$self, %attr );

  my ( $prune_prev, $current, $tokens ) = ( delete( $attr{prune_prev} ),
                                            delete( $attr{_current}, ),
                                            delete( $attr{_token_array} ), );

  delete $attr{qw( tokens first last )};

  my $copy = $self->new( %attr );
  return $copy unless $self->count;

  my $push_token = 0;
  foreach my $token ( @$tokens ) {
    $copy->append_new( $token->tree );
    $copy->{_current} = $copy->tokens->[-1] if ( ( $token ~~ $current ) == 0 );
  }

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

method prepend_new ( Tree $tree ) {

  my $token =
    Syntactic::Practice::Grammar::Token->new( set  => $self,
                                              tree => $tree );

  unshift( @{ $self->tokens }, $token );

  return $self;
}

method count () { $self->tokens ? scalar @{ $self->tokens } : 0 }

__PACKAGE__->meta->make_immutable();
