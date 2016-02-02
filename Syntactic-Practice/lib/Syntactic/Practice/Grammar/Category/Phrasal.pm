package Syntactic::Practice::Grammar::Category::Phrasal;

use Moose;

extends 'Syntactic::Practice::Grammar::Category::NonTerminal';

has '+label' => ( is      => 'ro',
                  isa     => 'PhrasalCategoryLabel',
                  lazy    => 1,
                  builder => '_build_label' );

sub _get_category_class { 'Category::Phrasal' }


no Moose;
__PACKAGE__->meta->make_immutable();
