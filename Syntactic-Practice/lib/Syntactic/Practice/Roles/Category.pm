package Syntactic::Practice::Roles::Category;

use Syntactic::Practice::Util;
use Syntactic::Practice::Types;

use Moose::Role;
use namespace::autoclean;

has 'label' => ( is      => 'ro',
                 isa     => 'SyntacticCategoryLabel',
                 lazy    => 1,
                 builder => '_build_label' );

sub _build_label {
  my ( $self ) = @_;
  if ( exists $self->{category} ) {
    return $self->category->label;
  } else {
    die 'Neither label nor category specified';
  }
}

has 'category' => ( is      => 'ro',
                    isa     => 'Syntactic::Practice::Grammar::Category',
                    lazy    => 1,
                    builder => '_build_category' );

sub _build_category {
  my ( $self ) = @_;
  if ( exists $self->{label} ) {
    return Syntactic::Practice::Grammar::Category->new( label => $_->label );
  } else {
    die 'Neither label nor category specified';
  }
}

has 'is_terminal' => ( is      => 'ro',
                       isa     => 'Bool',
                       lazy    => 1,
                       builder => '_build_is_terminal' );

sub _build_is_terminal {
  my ( $self ) = @_;

  # TODO: change this when there are more terminal and non-terminal categories
  my $ctype = $self->resultset->cat->ctype;
  return 0 if ( $ctype eq 'phrasal' );
  return 1 if ( $ctype eq 'lexical' );
}

has 'is_start' => ( is      => 'ro',
                    isa     => 'Bool',
                    lazy    => 1,
                    builder => '_build_is_start' );

sub _build_is_start {
  my $label = $_[0]->label;

  # TODO: change this when there are more start and non-start
  return 0 if ( $label ne 'S' );
  return 1 if ( $label eq 'S' );
}

no Moose::Role;
1;
