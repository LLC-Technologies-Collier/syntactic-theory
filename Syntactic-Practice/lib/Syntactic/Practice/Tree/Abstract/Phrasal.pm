package Syntactic::Practice::Tree::Abstract::Phrasal;

use Moose::Util::TypeConstraints;

use Moose;

extends 'Syntactic::Practice::Tree::Abstract::NonTerminal';
with 'Syntactic::Practice::Roles::Category::Phrasal';

subtype 'PhrasalAbstractTree', as 'PhrasalTree | Syntactic::Practice::Tree::Abstract::Phrasal';

no Moose;

__PACKAGE__->meta->make_immutable;
