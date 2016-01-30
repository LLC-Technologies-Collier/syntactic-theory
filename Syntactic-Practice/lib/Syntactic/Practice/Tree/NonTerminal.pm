package Syntactic::Practice::Tree::NonTerminal;

use Syntactic::Practice::Types;
use Moose;

extends 'Syntactic::Practice::Tree';

has '+label' => ( is       => 'ro',
                  isa      => 'NonTerminalCategoryLabel',
                  required => 1, );

has '+symbol' => ( is  => 'rw',
                   isa => 'Syntactic::Practice::Grammar::Symbol::NonTerminal',
                   required => 0
                 );

no Moose;
__PACKAGE__->meta->make_immutable( inline_constructor => 0 );
