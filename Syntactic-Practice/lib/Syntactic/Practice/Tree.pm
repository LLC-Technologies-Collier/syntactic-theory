package Syntactic::Practice::Tree;

use Carp;
use Syntactic::Practice::Types;
use Moose;

has name => ( is  => 'ro',
              isa => 'Str' );

has label => ( is       => 'ro',
               isa      => 'SyntacticCategoryLabel',
               required => 1, );

has frompos => ( is       => 'ro',
                 isa      => 'PositiveInt',
                 required => 1, );

has topos => ( is  => 'ro',
               isa => 'PositiveInt' );

has is_terminal => ( is      => 'ro',
                     isa     => 'Bool',
                     required => 1 );

has daughters => ( is => 'ro',
                   isa => 'ArrayRef[Syntactic::Practice::Tree]',
                 );

around 'daughters' => sub {
  my( $orig, $self ) = @_;

  if( ref $self->{daughters} eq 'ARRAY' ){
    return @{ $self->{daughters} };
  }else{
    return ( $self->{daughters} );
  }
};

my %treeByNameByLabel;

around 'new' => sub {
  my ( $orig, $self, @arg ) = @_;

  my $arg;
  if ( scalar @arg == 1 && ref $arg[0] eq 'HASH' ) {
    $arg = $arg[0];
  } else {
    $arg = {@arg};
  }

  $treeByNameByLabel{ $arg->{label} } = {}
    unless exists $treeByNameByLabel{ $arg->{label} };

  if ( exists $arg->{name} ) {
    if ( exists $treeByNameByLabel{ $arg->{label} }->{ $arg->{name} } ){
      die "Tree name $arg->{name} is already taken." unless $arg->{name} =~ /^\D+0$/;
    }
  } else {
    $arg->{name} =
      $arg->{label} . scalar keys %{ $treeByNameByLabel{ $arg->{label} } };
  }

  if ( exists $arg->{topos} ) {
    if ( $arg->{topos} < $arg->{frompos} ) {
      cluck( 'To and From positions are being reversed' );
      my $tmp = $arg->{topos};
      $arg->{topos}   = $arg->{frompos};
      $arg->{frompos} = $tmp;
    }
  } else {
    $arg->{topos} = $arg->{frompos} + 1;
  }

  $treeByNameByLabel{ $arg->{label} }->{ $arg->{name} } =
    $self->$orig( %$arg );
};

sub cmp {
  my ( $self, $other ) = @_;

  my $result;
  foreach my $attribute ( qw(label frompos topos ) ) {
    $result = $self->$attribute cmp $other->$attribute;
    return $result unless $result == 0;
  }

  my @self_daughter = $self->daughters;
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
  my ( $self, $depth ) = @_;
  return '' if $self->frompos == $self->topos;
  $depth = 0 unless $depth;
  my $indent = " " x ( $depth * 2 );

  my $output = "";
  my @daughter = $self->daughters;

  $output .= "${indent}[".$self->label."\n${indent}";
  if( $self->is_terminal ){
    $output .= "[@daughter] ";
  }else{
    $output .= join("", map { $_->as_forest( $depth + 1 ) } @daughter );
    $output .= "\n${indent}";
  }
  $output .= "]";
  return $output;
}

sub as_text {
  my ( $self, $depth ) = @_;
  my $output = '';

  $depth = 0 unless $depth;

  die "too deep!" if $depth > 5;

  my $indent = " " x ( $depth * 2 );
  $output .= $indent . $self->name . ": ";

  my @daughter = $self->daughters;
  return "${output}@daughter\n" if $self->is_terminal;

  $output .= join( ' ', map { $_->label } @daughter ) . "\n${indent}";
  $output .= join( '', map { $_->as_text( $depth + 1 ) } @daughter );;

  return $output;
}


no Moose;

__PACKAGE__->meta->make_immutable(inline_constructor => 0);
