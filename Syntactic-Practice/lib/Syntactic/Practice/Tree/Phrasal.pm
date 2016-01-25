package Syntactic::Practice::Tree::Phrasal;

use Syntactic::Practice::Types;
use Moose;

extends 'Syntactic::Practice::Tree::NonTerminal';

has '+label' => ( is       => 'ro',
                  isa      => 'PhrasalCategoryLabel',
                  required => 1, );

no Moose;

__PACKAGE__->meta->make_immutable;
1;
