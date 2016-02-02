package Syntactic::Practice::Grammar::Category::Start;

use Moose;

extends 'Syntactic::Practice::Grammar::Category::NonTerminal';

has '+label' => ( is      => 'ro',
                  isa     => 'StartCategoryLabel',
                  lazy    => 1,
                  builder => '_build_label', );

has '+is_start' => ( is      => 'ro',
                     isa     => 'True',
                     lazy    => 1,
                     builder => '_build_is_start' );

sub _build_is_start { 1 }
sub _build_label    { 'S' }

sub _build_category {
  Syntactic::Practice::Grammar::Start->new( label => $_[0]->label );
}

no Moose;
__PACKAGE__->meta->make_immutable();
