package Syntactic::Practice::Tree::NonTerminal;

use Moose::Util::TypeConstraints;

use Moose;

extends 'Syntactic::Practice::Tree';
with 'Syntactic::Practice::Roles::Category::NonTerminal';

subtype 'NonTerminalTree', as 'Syntactic::Practice::Tree::NonTerminal';

no Moose;
__PACKAGE__->meta->make_immutable;
