package Syntactic::Practice::Tree::Abstract::NonTerminal;

use Moose;

extends 'Syntactic::Practice::Tree::Abstract';
with 'Syntactic::Practice::Roles::Category::NonTerminal';

no Moose;
__PACKAGE__->meta->make_immutable;
