package Syntactic::Practice::Tree::Abstract::NonTerminal;

use Moose::Util::TypeConstraints;

use Moose;

extends 'Syntactic::Practice::Tree::Abstract';
with 'Syntactic::Practice::Roles::Category::NonTerminal';

subtype 'NonTerminalAbstractTree', as 'NonTerminalTree | Syntactic::Practice::Tree::Abstract::NonTerminal';

no Moose;
__PACKAGE__->meta->make_immutable;
