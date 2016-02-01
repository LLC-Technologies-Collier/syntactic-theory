package Syntactic::Practice::Tree;

use Carp;
use Data::Dumper;
use Moose;

use namespace::autoclean;

use Syntactic::Practice::Types;
use Moose::Util::TypeConstraints;
use Syntactic::Practice::Grammar::Symbol::Start;

with 'Syntactic::Practice::Roles::Category';

subtype 'MotherValue',
  as 'Syntactic::Practice::Tree | Syntactic::Practice::Grammar::Symbol::Start';

has name => ( is       => 'ro',
              isa      => 'Str',
              lazy     => 1,
              builder  => '_build_name',
              init_arg => undef );

has frompos => ( is       => 'ro',
                 isa      => 'PositiveInt',
                 required => 1 );

has topos => ( is       => 'ro',
               isa      => 'PositiveInt',
               lazy     => 1,
               builder  => '_build_topos',
               init_arg => undef );

has sisters => ( is       => 'ro',
                 isa      => 'ArrayRef[Syntactic::Practice::Tree]',
                 required => 1, );

has daughters => ( is       => 'ro',
                   isa      => 'ArrayRef[Syntactic::Practice::Tree]',
                   required => 1, );

has mother => ( is       => 'ro',
                isa      => 'MotherValue',
                required => 1 );

has depth => ( is       => 'rw',
               isa      => 'PositiveInt',
               lazy     => 1,
               builder  => '_build_depth',
               init_arg => undef, );

has prune_nulls => ( is      => 'ro',
                     isa     => 'Bool',
                     default => 1 );

sub _build_name {
  my ( $self ) = @_;
  $self->label . $self->_numTrees( { label => $self->label } );
}
sub _build_topos { $_[0]->{daughters}->[-1]->topos }
sub _build_depth { $_[0]->mother->depth + 1 }

around 'daughters' => sub {
  my ( $orig, $self ) = @_;

  return $self->{daughters} unless wantarray;
  return ( ref $self->{daughters} eq 'ARRAY'
           ? @{ $self->{daughters} }
           : ( $self->{daughters} ) );
};

my %treeByName;
my %treeByLabel;

sub _treeExists {
  my ( $self, $arg ) = @_;

  return $treeByName{ $arg->{name} } if ( exists $treeByName{ $arg->{name} } );
  return 0;
}

sub _registerTree {
  my ( $self ) = @_;

  $treeByLabel{ $self->label } = []
    unless exists $treeByLabel{ $self->label };

  push( @{ $treeByLabel{ $self->label } }, $treeByName{ $self->name } = $self );
}

sub _numTrees {
  my ( $self, $arg ) = @_;
  $treeByLabel{ $arg->{label} } = []
    unless exists $treeByLabel{ $arg->{label} };
  scalar @{ $treeByLabel{ $arg->{label} } };
}

around 'new' => sub {
  my ( $orig, $self, @arg ) = @_;

  my $class = ref $self ? ref $self : $self;

  my $arg;
  if ( scalar @arg == 1 && ref $arg[0] eq 'HASH' ) {
    $arg = $arg[0];
  } else {
    $arg = {@arg};
  }

  my $obj = $self->$orig( %$arg );

  $obj->_registerTree();

  return $obj;
};

sub cmp {
  my ( $self, $other ) = @_;

  my $result;
  foreach my $attribute ( qw(label frompos topos ) ) {
    $result = $self->$attribute cmp $other->$attribute;
    return $result unless $result == 0;
  }

  my @self_daughter  = $self->daughters;
  my @other_daughter = $other->daughters;

  $result = scalar @self_daughter <=> scalar @other_daughter;
  return $result unless $result == 0;

  for ( my $i = 0; $i < scalar @self_daughter; $i++ ) {
    $result = ( $self_daughter[$i] cmp $other_daughter[$i] );
    return $result unless $result == 0;
  }

  return 0;
}

sub as_forest {
  my ( $self ) = @_;

  my $indent = " " x ( $self->depth * 2 );

  my $output   = "";
  my @daughter = $self->daughters;

  $output .= "${indent}[" . $self->label . "\n${indent}";
  if ( $self->symbol->is_terminal ) {
    $output .= "[@daughter] ";
  } else {
    $output .= join( "", map { $_->as_forest() } @daughter );
    $output .= "\n${indent}";
  }
  $output .= "]";
  return $output;
}

sub as_text {
  my ( $self ) = @_;
  my $output = '';

  my $indent = " " x ( $self->depth * 2 );
  $output .= $indent . $self->name . ": ";

  my @daughter = map { $_ // '(null)' } $self->daughters;
  return "${output}@daughter\n" if $self->is_terminal;

  $output .= join( ' ', map { $_->label } @daughter ) . "\n${indent}";
  $output .= join( '',  map { $_->as_text() } @daughter );

  return $output;
}

sub to_concrete {
  my ( $self ) = @_;
  return $self;
}

no Moose;

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );
