package Syntactic::Practice::Tree::Abstract::Start;

use Moose::Util::TypeConstraints;

use Moose;

extends 'Syntactic::Practice::Tree::Abstract::NonTerminal';
with 'Syntactic::Practice::Roles::Category::Start';

subtype 'StartAbstractTree', as 'StartTree | Syntactic::Practice::Tree::Abstract::Start';

has mother => ( is      => 'ro',
                isa     => 'Undefined',
                lazy    => 1,
                builder => '_build_mother' );

sub _build_mother { undef }
sub _build_depth  { 0 }

no Moose;

__PACKAGE__->meta->make_immutable
