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

with( 'MooseX::Log::Log4perl', 'Syntactic::Practice::Roles::Unique' );

has tokens => ( is      => 'rw',
                isa     => 'ArrayRef[Token]',
                lazy    => 1,
                builder => '_build_tokens', );

has first => ( is        => 'rw',
               isa       => 'Maybe[Token]',
               lazy      => 1,
               builder   => '_build_first',
               trigger   => \&_set_extrema,
               clearer   => '_clear_first',
               predicate => '_has_first',
               init_arg  => undef, );

has last => ( is        => 'rw',
              isa       => 'Maybe[Token]',
              lazy      => 1,
              builder   => '_build_last',
              trigger   => \&_set_extrema,
              clearer   => '_clear_last',
              predicate => '_has_last',
              init_arg  => undef, );

sub cmp {
  my ( $self, $other ) = @_;
  return undef unless defined $other && $other->can( '_guid' );
  $self->_guid cmp $other->_guid;
}

method string () {
  join ' ', map { $_->string } @{ $self->tokens };
}

use overload
  q{""} => sub { $_[0]->string },
  '<=>' => sub {
  my $r = $_[0]->cmp( $_[1] );
  $r = 1 unless defined $r;
  ( $_[2] ? -1 : 1 ) * $r;
  },
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

method _build_last () { $self->tokens ? $self->tokens->[-1] : undef }

method _set_extrema ( Token $new!, Maybe[Token] $old? ) {

  my ( $extrema ) = ( ( caller( 1 ) )[3] =~ /TokenSet::(\S+)/ );
  my ( $tbool, $count ) = ( $extrema eq 'first', $self->count );
  my ( $forward, $back ) = ( $tbool ? qw(next prev) : qw(prev next) );

  if ( 0 ~~ ( $new ~~ $old ) ) {
    $self->log->error( qq{Token specified as $extrema is already $extrema} );
  } else {
    $new->set( $self );
    $new->$forward( $old );
    $count++;
  }

  my ( $end, $start ) = $tbool ? ( $count, 0 ) : ( 0, $count );

  $self->log->error( "Token specified as old $extrema is not $extrema token" )
    unless ( 0 ~~ ( $old ~~ $self->tokens->[$start] ) );

  my ( $tokens, $cursor, $i, $prior ) = ( $self->tokens, $new, $start, undef );

  my ( $breach, $iterate ) =
    $tbool
    ? ( sub { $i > $end }, sub { $i++ } )
    : ( sub { $i < $end }, sub { $i-- } );

  while ( defined $cursor ) {
    if ( $breach->() ) {
      my $msg = "cursor has iterated more than [$count] times";
      $self->log->error( $msg );
      confess $msg;
    }
    $cursor->$back( $prior );
    $tokens->[$iterate->()] = $prior = $cursor;
    $cursor = $cursor->$forward;
    if ( 0 ~~ ( $cursor ~~ $new ) ) {
      my $msg = qq{Token sepcified as $extrema is in token set at index [$i]};
      $self->log->error( $msg );
      confess $msg;
    }
  }

  $self->$extrema( $prior ) unless 0 ~~ ( $self->$extrema ~~ $prior );

  return $new;
}

sub _assert_set_consistency {
  my ( $self ) = @_;

  $self->log->debug( "Performing token set consistency check." );
  my $tokens        = $self->tokenset;
  my $initial_count = $self->count;
  $self->log->debug( "Initial token count: [$initial_count]" );

  my @expected =
    ( undef, ( map { $tokens->[$_] } ( 0 .. $#{$tokens} ) ), undef );
  my ( @valid, @invalid, @correct );

  my ( $cursor, $i ) = ( $self->first, 0 );
  my $prev = undef;
  while ( defined $cursor or $i < $initial_count ) {
    my ( $prev_expected, $cur_expected, $next_expected ) =
      @expected[ $i, $i + 1, $i + 2 ];

    my ( $prev_token, $cur_token, $next_token ) =
      ( $cursor->prev, $cursor, $cursor->next );

    if ( $cur_token ~~ $cur_expected ) {
      push( @valid, $cur_token );
    } else {
      $self->log->debug( "Incorrect token at index [$i]" );
      push( @invalid,
            { position => $i,
              token    => $prev_token,
              expected => $prev_expected
            } );
    }

    if ( $prev_token ~~ $prev_expected ) {
      push( @valid, $prev_token );
    } else {
      $self->log->debug( "Incorrect previous token at index [$i]" );
      push( @invalid,
            { position => $i - 1,
              token    => $prev_token,
              expected => $prev_expected
            } );
    }

    if ( $next_token ~~ $next_expected ) {
      push( @valid, $next_token );
    } else {
      $self->log->debug( "Incorrect previous token at index [$i]" );
      push( @invalid,
            { position => $i + 1,
              token    => $next_token,
              expected => $next_expected
            } );
    }

    push( @correct, $cursor );
    $prev   = $cursor;
    $cursor = $cursor->next;
    $i++;
  }
  my ( $num_valid, $num_invalid, $num_tokens ) =
    ( scalar @valid, scalar @invalid, scalar @correct );

  $self->log->debug(
                 "Number of valid positions:   [$num_valid] of [$num_tokens]" );
  $self->log->debug(
               "Number of invalid positions: [$num_invalid] of [$num_tokens]" );

  $#{ $self->tokens } = -1;
  push( @{ $self->tokens }, @correct );
}

method append ( TokenSet|Token $more!, Bool $do_copy=1 ) {
#sub append {
#  my ( $self, $more, $do_copy ) = @_;

#  $do_copy //= 1;

  #  my ( $self, @arg ) = @_;
  #  my ( $more, $do_copy ) =
  #    pos_validated_list( \@arg,
  #                        { type => 'Token|TokenSet' },
  #                        { type => 'Bool', default => 1 } );
  my ( $tokens, $old_last ) = ( $self->tokens, $self->last );
  my $num_tokens = scalar @$tokens;

  if ( $more->isa( 'Syntactic::Practice::Grammar::TokenSet' ) ) {
    my $copy = $do_copy ? $more->copy : $more;
    foreach my $new_token ( @{ $copy->tokens } ){
      $self->last( $new_token );
    }
    if ( $do_copy ) {
      delete $copy->{tokens};
      undef $copy;
    }
  } elsif ( $more->isa( 'Syntactic::Practice::Grammar::Token' ) ) {
    my $copy = $do_copy ? $more->copy( set => $self ) : $more;
    $self->last( $copy );
  }

  return $self;
}

sub append_new {
  my ( $self, @arg ) = @_;

  my ( $tree ) = pos_validated_list( \@arg, { type => 'Tree' }, );

  my $tokens = $self->tokens;
  my $token =
    Syntactic::Practice::Grammar::Token->new( set  => $self,
                                              tree => $tree );

  if ( scalar @$tokens > 1 ) {
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

method _build_first () { $self->count > 0 ? $self->tokens->[0] : undef }

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

method count () { $self->tokens ? scalar @{ $self->tokens } : 0 }

__PACKAGE__->meta->make_immutable();
