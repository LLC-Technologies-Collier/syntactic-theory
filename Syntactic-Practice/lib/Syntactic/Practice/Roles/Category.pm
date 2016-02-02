package Syntactic::Practice::Roles::Category;

use Moose::Role;
use namespace::autoclean;

my $rs_namespace = Syntactic::Practice::Util->get_rs_namespace();

my $rs_class       = 'Category';
my $category_class = 'Syntactic::Practice::Grammar::Category';

has 'label' => ( is      => 'ro',
                 isa     => 'SyntacticCategoryLabel',
                 lazy    => 1,
                 builder => '_build_label' );

has 'name' => ( is      => 'ro',
                isa     => 'Str',
                lazy    => 1,
                builder => '_build_name' );

has 'category' => ( is      => 'ro',
                    isa     => $category_class,
                    lazy    => 1,
                    builder => '_build_category' );

has 'is_start' => ( is      => 'ro',
                    isa     => 'Bool',
                    lazy    => 1,
                    builder => '_build_is_start' );

has 'is_terminal' => ( is      => 'ro',
                       isa     => 'Bool',
                       lazy    => 1,
                       builder => '_build_is_terminal' );

sub _build_label {
  my ( $self ) = @_;
  confess 'Neither label nor category specified'
    unless exists $self->{category};
  return $self->category->label;
}

sub _build_category {
  my ( $self ) = @_;
  die 'Neither label nor category specified' unless exists $self->{label};
  my $class = 'Syntactic::Practice::Grammar::' . $self->_get_category_class;
  return $class->new( label => $self->{label} );
}

sub _build_name         { $_[0]->category->resultset->longname }
sub _build_is_terminal  { $_[0]->category->is_terminal }
sub _build_is_start     { $_[0]->category->is_start }
sub _get_category_class { 'Category' }

no Moose::Role;
1;
