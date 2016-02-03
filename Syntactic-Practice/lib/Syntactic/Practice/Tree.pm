package Syntactic::Practice::Tree;

=head1 NAME

Syntactic::Practice::Tree - Parse Tree Representation

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use Moose::Util::TypeConstraints;

use Moose;

use namespace::autoclean;

with 'Syntactic::Practice::Roles::Category';

subtype 'Tree', as 'Syntactic::Practice::Tree';

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
                 isa      => 'ArrayRef[Tree]',
                 required => 1, );

has daughters => ( is       => 'ro',
                   isa      => 'ArrayRef[Tree]',
                   required => 1, );

has mother => ( is       => 'ro',
                isa      => 'Tree',
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
sub _build_topos {
  my( $self) = @_;
  ref $self->{daughters} eq 'ARRAY' ? $self->daughters->[-1]->topos : $self->frompos + 1
}
sub _build_depth { $_[0]->mother->depth + 1 }

around 'daughters' => sub {
  my ( $orig, $self ) = @_;

  warn Data::Dumper::Dumper( { label => $self->label,
                               daughters => $self->{daughters} } );

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

sub BUILD {
  my ( $self ) = @_;

  $self->_registerTree();
}

sub cmp {
  my($self,$other) = @_;
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
};

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

  my $ref = ref $self;
  my $label = $self->label;
  warn "$ref - $label";

  $output .= join( ' ', map { ref $_ ? $_->label : $_ } @daughter ) . "\n${indent}";
  $output .= join( '',  map { ref $_ ? $_->as_text : $_ } @daughter );

  return $output;
}

no Moose;

__PACKAGE__->meta->make_immutable;
