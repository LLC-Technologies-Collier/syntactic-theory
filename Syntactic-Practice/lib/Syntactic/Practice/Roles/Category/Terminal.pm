package Syntactic::Practice::Roles::Category::Terminal;

use Syntactic::Practice::Util;
use Syntactic::Practice::Types;
use Syntactic::Practice::Grammar::Category::Terminal;

use Moose::Role;
use namespace::autoclean;

with 'Syntactic::Practice::Roles::Category';

has 'label' => ( is      => 'ro',
                 isa     => 'TerminalCategoryLabel',
                 lazy    => 1,
                 builder => '_build_label' );

has 'category' => ( is   => 'ro',
                    isa  => 'Syntactic::Practice::Grammar::Category::Terminal',
                    lazy => 1,
                    builder => '_build_category' );

sub _build_is_terminal  { 1 }
sub _build_is_start     { 0 }
sub _get_category_class { 'Category::Terminal' }

no Moose::Role;
1;
