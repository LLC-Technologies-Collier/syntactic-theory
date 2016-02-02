package Syntactic::Practice::Grammar::Symbol::Terminal;

use Moose;

extends 'Syntactic::Practice::Grammar::Symbol';
with 'Syntactic::Practice::Roles::Category::Terminal';

no Moose;
__PACKAGE__->meta->make_immutable;
