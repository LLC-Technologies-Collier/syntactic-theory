package Syntactic::Practice::Grammar::Symbol::NonTerminal;

use Moose;

extends 'Syntactic::Practice::Grammar::Symbol';
with 'Syntactic::Practice::Roles::Category::NonTerminal';

no Moose;
__PACKAGE__->meta->make_immutable;
