package Syntactic::Practice::Tree::Abstract;

use Syntactic::Practice::Types;
use Moose;

extends 'Syntactic::Practice::Tree';

has '+daughters' => ( is       => 'rw',
                      isa      => 'ArrayRef[Syntactic::Practice::Tree]',
                      required => 0, );

has '+mother' => (
                is  => 'rw',
                isa => (
                      'Syntactic::Practice::Tree | '
                    . 'Syntactic::Practice::Grammar::Symbol::Start | ' . 'Undef'
                ),
                required => 0 );

has '+sisters' => ( is       => 'rw',
                    isa      => ( 'ArrayRef[Syntactic::Practice::Tree]' ),
                    required => 0 );

has '+symbol' => ( is       => 'rw',
                   isa      => 'Syntactic::Practice::Grammar::Symbol',
                   required => 0 );

has '+prune_nulls' => ( is      => 'ro',
                        isa     => 'False',
                        default => 0 );

my %abstractTreeByName;
my %abstractTreeByLabel;

sub _treeExists {
  my ( $self, $arg ) = @_;

  return $abstractTreeByName{ $arg->{name} }
    if ( exists $abstractTreeByName{ $arg->{name} } );
  return 0;
}

sub _registerTree {
  my ( $self ) = @_;

  warn ref $self unless $self->label;
  $abstractTreeByLabel{ $self->label } = []
    unless exists $abstractTreeByLabel{ $self->label };
  push( @{ $abstractTreeByLabel{ $self->label } },
        $abstractTreeByName{ $self->name } = $self );
}

sub _numTrees {
  my ( $self, $arg ) = @_;
  $abstractTreeByLabel{ $arg->{label} } = []
    unless exists $abstractTreeByLabel{ $arg->{label} };
  return scalar @{ $abstractTreeByLabel{ $arg->{label} } };
}

sub to_concrete {
  my ( $self, $arg ) = @_;
  $arg = {} unless $arg;
  my $abstract_class = ref $self;
  ( my $class = $abstract_class ) =~ s/Abstract:://;
  return $class->new( %$self, %$arg );
}

no Moose;
__PACKAGE__->meta->make_immutable( inline_constructor => 0 );
