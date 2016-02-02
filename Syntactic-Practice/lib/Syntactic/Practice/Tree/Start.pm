package Syntactic::Practice::Tree::Start;

use Moose;

extends 'Syntactic::Practice::Tree::NonTerminal';
with 'Syntactic::Practice::Roles::Category::Start';

has '+mother' => ( is      => 'ro',
                   isa     => 'Undefined',
                   lazy    => 1,
                   builder => '_build_mother' );

sub _build_mother   { undef }
sub _build_depth    { 0 }

no Moose;

__PACKAGE__->meta->make_immutable;
