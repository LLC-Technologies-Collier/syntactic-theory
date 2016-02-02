package Syntactic::Practice::Grammar::Category::Terminal;

use Syntactic::Practice::Util;
use Syntactic::Practice::Types;

use Moose;

extends 'Syntactic::Practice::Grammar::Category';

has '+label' => ( is      => 'ro',
                  isa     => 'TerminalCategoryLabel',
                  lazy    => 1,
                  builder => '_build_label' );

has '+is_terminal' => ( is      => 'ro',
                        isa     => 'True',
                        lazy    => 1,
                        builder => '_build_is_terminal' );

sub _build_is_terminal  { 1 }
sub _build_is_start     { 0 }
sub _get_category_class { 'Category::Terminal' }

no Moose;
__PACKAGE__->meta->make_immutable();
