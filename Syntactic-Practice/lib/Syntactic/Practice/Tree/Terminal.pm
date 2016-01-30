package Syntactic::Practice::Tree::Terminal;

use Syntactic::Practice::Tree;
use Syntactic::Practice::Types;
use Moose;

extends 'Syntactic::Practice::Tree';

has '+label' => ( is       => 'ro',
                  isa      => 'TerminalCategoryLabel',
                  required => 1, );

has '+symbol' => ( is  => 'ro',
                   isa => 'Syntactic::Practice::Grammar::Symbol::Terminal',
                   required => 1
                 );

sub _build_topos {
  return $_[0]->frompos + 1;
}

no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);
