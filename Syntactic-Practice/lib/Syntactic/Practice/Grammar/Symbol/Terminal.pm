package Syntactic::Practice::Grammar::Symbol::Terminal;

use Syntactic::Practice::Grammar::Symbol;
use Syntactic::Practice::Util;
use Syntactic::Practice::Types;

use Moose;

extends 'Syntactic::Practice::Grammar::Symbol';

no Moose;
__PACKAGE__->meta->make_immutable( inline_constructor => 0 );
