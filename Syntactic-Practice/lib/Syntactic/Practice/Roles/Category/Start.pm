package Syntactic::Practice::Roles::Category::Start;

use Syntactic::Practice::Grammar::Category::Start;
use Syntactic::Practice::Util;
use Syntactic::Practice::Types;

use Moose::Role;
use namespace::autoclean;

with 'Syntactic::Practice::Roles::Category::NonTerminal';

has 'label' => ( is      => 'ro',
                 isa     => 'StartCategoryLabel',
                 lazy    => 1,
                 builder => '_build_label' );

has 'is_start' => ( is      => 'ro',
                    isa     => 'True',
                    lazy    => 1,
                    builder => '_build_is_start' );

has 'frompos' => ( is       => 'ro',
                   isa      => 'PositiveInt',
                   lazy     => 1,
                   builder  => '_build_frompos',
                   init_arg => undef );

sub _build_is_start    { 1 }
sub _build_is_terminal { 0 }
sub _build_label       { 'S' }
sub _build_frompos     { 0 }
sub _build_category {
  Syntactic::Practice::Grammar::Category::Start->new( label => $_[0]->label );
}

sub _get_category_class { 'Category::Start' }

no Moose::Role;
1;
