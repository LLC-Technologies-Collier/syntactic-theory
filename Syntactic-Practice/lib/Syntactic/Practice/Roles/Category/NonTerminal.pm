package Syntactic::Practice::Roles::Category::NonTerminal;

use Syntactic::Practice::Util;
use Syntactic::Practice::Types;

use Moose::Role;
use namespace::autoclean;

extends 'Syntactic::Practice::Roles::Category';

has '+label' => ( is      => 'ro',
                  isa     => 'NonTerminalCategoryLabel',
                  lazy    => 1,
                  builder => '_build_label' );

has 'category' => ( is      => 'ro',
                    isa     => 'Syntactic::Practice::Grammar::Category::NonTerminal',
                    lazy    => 1,
                    builder => '_build_category' );

sub _build_is_terminal { 0 }

no Moose::Role;
1;
