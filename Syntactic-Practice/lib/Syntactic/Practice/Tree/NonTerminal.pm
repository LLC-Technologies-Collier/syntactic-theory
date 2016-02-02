package Syntactic::Practice::Tree::NonTerminal;

use Moose;

extends 'Syntactic::Practice::Tree';
with 'Syntactic::Practice::Roles::Category::NonTerminal';

no Moose;
__PACKAGE__->meta->make_immutable;
