package Syntactic::Practice::Tree::Phrasal;

use Moose::Util::TypeConstraints;

use Moose;

extends 'Syntactic::Practice::Tree::NonTerminal';
with 'Syntactic::Practice::Roles::Category::Terminal';

subtype 'PhrasalTree', as 'Syntactic::Practice::Tree::Phrasal';


no Moose;

__PACKAGE__->meta->make_immutable;

