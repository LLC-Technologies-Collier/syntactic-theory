package Syntactic::Practice::Tree::Abstract::Phrasal;

use Moose;

extends 'Syntactic::Practice::Tree::Abstract::NonTerminal';
with 'Syntactic::Practice::Roles::Category::Phrasal';

no Moose;

__PACKAGE__->meta->make_immutable;
