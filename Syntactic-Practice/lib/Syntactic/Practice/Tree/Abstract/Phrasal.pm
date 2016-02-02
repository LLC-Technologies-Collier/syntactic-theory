package Syntactic::Practice::Tree::Abstract::Phrasal;

use Syntactic::Practice::Types;
use Moose;

extends 'Syntactic::Practice::Tree::Abstract::NonTerminal';
with 'Syntactic::Practice::Roles::Category::Phrasal';

no Moose;

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );
1;
