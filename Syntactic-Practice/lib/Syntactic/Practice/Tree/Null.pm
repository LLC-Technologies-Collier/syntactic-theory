package Syntactic::Practice::Tree::Null;

use Syntactic::Practice::Tree::Terminal;
use Syntactic::Practice::Types;
use Moose;

extends 'Syntactic::Practice::Tree::Terminal';

has '+daughters' => ( is      => 'ro',
                      isa     => 'Undefined',
                      default => undef, );

has '+symbol' => ( is       => 'ro',
                   isa      => 'Syntactic::Practice::Grammar::Symbol',
                   required => 0, );

has '+frompos' => ( is       => 'ro',
                    isa      => 'PositiveInt',
                    required => 1, );

sub _build_topos {
  return $_[0]->frompos;
}

around 'new' => sub {
  my ( $orig, $self, @arg ) = @_;

  my $arg;
  if ( scalar @arg == 1 && ref $arg[0] eq 'HASH' ) {
    $arg = $arg[0];
  } else {
    $arg = {@arg};
  }
  $arg->{topos}     = $arg->{frompos};
  $arg->{name}      = $arg->{label} . "0";
  $arg->{daughters} = undef;
  $self->$orig( %$arg );
};

no Moose;

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

