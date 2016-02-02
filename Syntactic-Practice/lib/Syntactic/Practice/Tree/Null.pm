package Syntactic::Practice::Tree::Null;

use Syntactic::Practice::Tree::Terminal;
use Syntactic::Practice::Types;
use Moose;

extends 'Syntactic::Practice::Tree::Terminal';
with 'Syntactic::Practice::Roles::Category::Terminal';

has '+daughters' => ( is      => 'ro',
                      isa     => 'Undefined',
                      lazy    => 1,
                      builder => '_build_daughters', );

sub _build_daughters { undef }
sub _build_topos     { $_[0]->frompos }
sub _build_name      { $_[0]->label . '0' }

no Moose;

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

