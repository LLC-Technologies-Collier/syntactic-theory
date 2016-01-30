package Syntactic::Practice::Grammar::Symbol::Start;

use Syntactic::Practice::Grammar::Symbol::NonTerminal;

use Moose;

extends 'Syntactic::Practice::Grammar::Symbol::NonTerminal';

no Moose;
__PACKAGE__->meta->make_immutable( inline_constructor => 0 );
