package Syntactic::Practice::Grammar::Category::Phrasal;

use Syntactic::Practice::Util;
use Syntactic::Practice::Types;

use Moose;

extends 'Syntactic::Practice::Grammar::Category::NonTerminal';

has '+label' => ( is      => 'ro',
                  isa     => 'PhrasalCategoryLabel',
                  lazy    => 1,
                  builder => '_build_label' );

sub _build_is_terminal  { 1 }
sub _get_category_class { 'Category::Phrasal' }


no Moose;
__PACKAGE__->meta->make_immutable();
