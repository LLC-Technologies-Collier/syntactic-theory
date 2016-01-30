package Syntactic::Practice::Tree::Abstract::Terminal;

use Syntactic::Practice::Types;
use Moose;

extends 'Syntactic::Practice::Tree::Abstract';

has '+label' => ( is       => 'ro',
                  isa      => 'TerminalCategoryLabel',
                  required => 1, );

has '+symbol' => ( is       => 'rw',
                   isa      => 'Syntactic::Practice::Grammar::Symbol::Terminal',
                   required => 0, );

sub _build_topos {
  return $_[0]->frompos + 1;
}

no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);
