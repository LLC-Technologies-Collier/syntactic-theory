package Syntactic::Practice::Grammar::Category::NonTerminal;

use Moose;

extends 'Syntactic::Practice::Grammar::Category';

has '+label' => ( is      => 'ro',
                  isa     => 'NonTerminalCategoryLabel',
                  lazy    => 1,
                  builder => '_build_label' );

has '+is_terminal' => ( is      => 'ro',
                        isa     => 'False',
                        lazy    => 1,
                        builder => '_build_is_terminal' );

sub _build_is_terminal { 0 }

no Moose;
__PACKAGE__->meta->make_immutable();
