package Syntactic::Practice::Tree::Phrasal;

use Moose;

extends 'Syntactic::Practice::Tree::NonTerminal';
with 'Syntactic::Practice::Roles::Category::Terminal';

no Moose;

__PACKAGE__->meta->make_immutable;

