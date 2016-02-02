package Syntactic::Practice::Grammar::Category::Lexical;

use Moose;

extends 'Syntactic::Practice::Grammar::Category::Terminal';

has '+label' => ( is      => 'ro',
                  isa     => 'LexicalCategoryLabel',
                  lazy    => 1,
                  builder => '_build_label' );

no Moose;
__PACKAGE__->meta->make_immutable();
