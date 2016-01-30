package Syntactic::Practice::Tree::Abstract::NonTerminal;

use Syntactic::Practice::Types;
use Moose;

extends 'Syntactic::Practice::Tree::Abstract';

has '+label' => ( is       => 'ro',
                  isa      => 'NonTerminalCategoryLabel',
                  required => 1, );

has '+symbol' => ( is       => 'ro',
                   isa      => 'Syntactic::Practice::Grammar::Symbol::NonTerminal',
                   required => 1, );

no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);
