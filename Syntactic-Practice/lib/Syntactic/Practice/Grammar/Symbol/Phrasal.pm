package Syntactic::Practice::Grammar::Symbol::Phrasal;

use Syntactic::Practice::Types;

use Moose;

extends 'Syntactic::Practice::Grammar::Symbol::NonTerminal';

no Moose;
__PACKAGE__->meta->make_immutable( inline_constructor => 0 );
