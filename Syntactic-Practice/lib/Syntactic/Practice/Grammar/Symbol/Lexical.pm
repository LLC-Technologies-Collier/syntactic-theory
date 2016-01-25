package Syntactic::Practice::Grammar::Symbol::Lexical;

use Syntactic::Practice::Types;

use Moose;

extends 'Syntactic::Practice::Grammar::Symbol::Terminal';

has '+label' => ( is       => 'ro',
                  isa      => 'LexicalCategoryLabel',
                  required => 1 );

no Moose;
__PACKAGE__->meta->make_immutable();
