package Syntactic::Practice::Tree::Abstract::Null;

use Moose::Util::TypeConstraints;

use Moose;

extends 'Syntactic::Practice::Tree::Abstract::Terminal';
with 'Syntactic::Practice::Roles::Category::Terminal';

subtype 'NullAbstractTree', as 'NullTree | Syntactic::Practice::Tree::Abstract::Null';

has '+label' => ( is      => 'ro',
                  isa     => 'SyntacticCategoryLabel',
                  lazy    => 1,
                  builder => '_build_label' );

has '+category' => ( is      => 'ro',
                     isa     => 'Syntactic::Practice::Grammar::Category',
                     lazy    => 1,
                     builder => '_build_category' );

has '+daughters' => ( is      => 'ro',
                      isa     => 'Undefined',
                      lazy    => 1,
                      builder => '_build_daughters', );

sub _build_daughters { undef }
sub _build_topos     { $_[0]->frompos }
sub _build_name      { $_[0]->label . '0' }

no Moose;

__PACKAGE__->meta->make_immutable;
