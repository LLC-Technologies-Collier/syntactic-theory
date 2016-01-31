package Syntactic::Practice::Roles::Category::Phrasal;

use Syntactic::Practice::Util;
use Syntactic::Practice::Types;

use Moose::Role;
use namespace::autoclean;

extends 'Syntactic::Practice::Roles::Category::NonTerminal';

has '+label' => ( is      => 'ro',
                  isa     => 'PhrasalCategoryLabel',
                  lazy    => 1,
                  builder => '_build_label' );

has 'category' => ( is   => 'ro',
                    isa  => 'Syntactic::Practice::Grammar::Category::Phrasal',
                    lazy => 1,
                    builder => '_build_category' );

no Moose::Role;
1;
