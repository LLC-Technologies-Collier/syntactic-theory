package Syntactic::Practice::Tree::Terminal;

use Moose::Util::TypeConstraints;

use Moose;

extends 'Syntactic::Practice::Tree';
with 'Syntactic::Practice::Roles::Category::Terminal';

subtype 'TerminalTree', as 'Syntactic::Practice::Tree::Terminal';

sub _build_topos { $_[0]->frompos + 1 }

no Moose;
__PACKAGE__->meta->make_immutable;
