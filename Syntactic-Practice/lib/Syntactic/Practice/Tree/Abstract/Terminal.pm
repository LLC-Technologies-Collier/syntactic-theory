package Syntactic::Practice::Tree::Abstract::Terminal;

use Moose;

extends 'Syntactic::Practice::Tree::Abstract';
with 'Syntactic::Practice::Roles::Category::Terminal';

no Moose;
__PACKAGE__->meta->make_immutable;
