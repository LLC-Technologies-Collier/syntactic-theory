package Syntactic::Practice::Grammar::Symbol::Lexical;

use Syntactic::Practice::Types;

use Moose;

extends 'Syntactic::Practice::Grammar::Symbol::Terminal';

no Moose;
__PACKAGE__->meta->make_immutable( inline_constructor => 0 );
