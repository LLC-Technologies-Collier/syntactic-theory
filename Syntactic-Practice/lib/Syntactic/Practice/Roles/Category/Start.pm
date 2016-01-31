package Syntactic::Practice::Roles::Category::Start;

use Syntactic::Practice::Util;
use Syntactic::Practice::Types;

use Moose;

extends 'Syntactic::Practice::Roles::Category::NonTerminal';

has '+label' => ( is      => 'ro',
                  isa     => 'StartCategoryLabel',
                  lazy    => 1,
                  builder => '_build_label' );

has '+is_start' => ( is      => 'ro',
                     isa     => 'True',
                     lazy    => 1,
                     builder => '_build_is_start' );

sub _build_is_start { 1 }

no Moose;
__PACKAGE__->meta->make_immutable();
