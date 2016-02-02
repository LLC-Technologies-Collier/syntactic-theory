package Syntactic::Practice::Tree::Terminal;

use Moose;

with 'Syntactic::Practice::Roles::Category::Terminal';
extends 'Syntactic::Practice::Tree';

sub _build_topos { $_[0]->frompos + 1 }

no Moose;
__PACKAGE__->meta->make_immutable( inline_constructor => 0 );
