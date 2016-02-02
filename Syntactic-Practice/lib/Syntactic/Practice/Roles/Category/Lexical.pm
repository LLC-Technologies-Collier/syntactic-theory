package Syntactic::Practice::Roles::Category::Lexical;

use Moose::Role;
use namespace::autoclean;

with 'Syntactic::Practice::Roles::Category::Terminal';

has 'label' => ( is      => 'ro',
                 isa     => 'LexicalCategoryLabel',
                 lazy    => 1,
                 builder => '_build_label' );

sub _get_category_class { 'Category::Lexical' }

no Moose::Role;
1;
