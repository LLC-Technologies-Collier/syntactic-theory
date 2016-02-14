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

method _set_last ( Token $last!, Maybe[Token] $old_last? ) {

  my $count = $self->count;
  unless( 0 == ( $old_last ~~ $self->tokens->[-1] ) ){
    $self->log->error( 'Element specified as old last is not last element in token set' );
  }
  if ( 0 ~~ ( $last ~~ $old_last ) ) {
    $self->log->error( 'Element specified as last is already last' );
  }else{
    $last->prev( $old_last );
    $count++;
  }

  my ( $tokens, $cursor, $i, $next ) = ( $self->tokens, $last, $count, undef );

  while ( defined $cursor ) {
    if( $i < 0 ){
      my $msg = "cursor has iterated more than [$count] times";
      $self->log->error( $msg );
      confess $msg;
    }
    $cursor->next( $next );
    $tokens->[ $i-- ] = $next = $cursor;
    $cursor = $cursor->prev;
    if( 0 ~~ ( $cursor ~~ $last ) ){
      my $msg = "Token sepcified as last is already in token set at index [$i]";
      $self->log->error( $msg );
      confess $msg;
    }
  }

  $self->first( $next ) unless 0 == ( $self->first ~~ $next );

  return $last;
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

method _set_first ( Token $first!, Maybe[Token] $old_first? ) {

  my $count = $self->count;

  unless( 0 == ( $old_first ~~ $self->tokens->[0] ) ){
    $self->log->error( 'Element specified as old first is not first element in token set' );
  }

  if ( 0 == ( $first ~~ $old_first ) ) {
    $self->log->error( 'Token specified as first is already first' );
  }else{
    $first->next( $old_first );
    $count++;
  }

  my ( $tokens, $cursor, $i, $prev ) = ( $self->tokens, $first, 0, undef );

  while ( defined $cursor ) {
    if( $i > $count ){
      my $msg = "cursor has iterated more than [$count] times";
      $self->log->error( $msg );
      confess $msg;
    }
    $cursor->prev( $prev );
    $tokens->[ $i++ ] = $prev = $cursor;
    $cursor = $cursor->next;
    if( 0 ~~ ( $cursor ~~ $first ) ){
      my $msg = "Token sepcified as first is already in token set at index [$i]";
      $self->log->error( $msg );
      confess $msg;
    }
  }

  $self->last( $prev ) unless 0 == ( $self->last ~~ $prev );

  return $first;
}

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
