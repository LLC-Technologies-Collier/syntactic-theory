package Syntactic::Practice::Tree::Abstract::Null;

use Syntactic::Practice::Tree::Abstract::Terminal;
use Syntactic::Practice::Types;
use Moose;

extends 'Syntactic::Practice::Tree::Abstract::Terminal';

has '+daughters' => ( is => 'ro',
                      isa => 'Undefined',
                      default => undef,
                    );

has '+symbol' => ( is       => 'ro',
                   isa      => 'Syntactic::Practice::Grammar::Symbol',
                   required => 0, );

sub _build_name {
  $_[0]->label . '0';
}

sub _build_topos {
  return $_[0]->frompos;
}

no Moose;

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

