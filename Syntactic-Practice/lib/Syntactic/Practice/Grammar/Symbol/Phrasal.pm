package Syntactic::Practice::Grammar::Symbol::Phrasal;

use Moose;

extends 'Syntactic::Practice::Grammar::Symbol::NonTerminal';
with 'Syntactic::Practice::Roles::Category::Phrasal';

no Moose;
__PACKAGE__->meta->make_immutable;
