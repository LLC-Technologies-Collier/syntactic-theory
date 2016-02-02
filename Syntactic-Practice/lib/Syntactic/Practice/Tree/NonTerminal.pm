package Syntactic::Practice::Tree::NonTerminal;

use Syntactic::Practice::Types;
use Moose;

extends 'Syntactic::Practice::Tree';
with 'Syntactic::Practice::Roles::Category::NonTerminal';

no Moose;
__PACKAGE__->meta->make_immutable( inline_constructor => 0 );
