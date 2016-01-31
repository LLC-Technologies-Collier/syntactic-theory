package Syntactic::Practice::Tree::Abstract::Start;

use Syntactic::Practice::Types;
use Moose;

extends 'Syntactic::Practice::Tree::Abstract::NonTerminal';

has '+label' => ( is      => 'ro',
                  isa     => 'StartCategoryLabel',
                  default => 'S', );

has '+mother' => ( is  => 'ro',
                   isa => 'Undefined' );

has '+frompos' => ( is      => 'ro',
                    isa     => 'PositiveInt',
                    default => 1 );

my $symClass = 'Syntactic::Practice::Grammar::Symbol::Start';
has '+symbol' => ( is      => 'ro',
                   isa     => $symClass,
                   default => sub { $symClass->new() }, );

no Moose;

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );
1;