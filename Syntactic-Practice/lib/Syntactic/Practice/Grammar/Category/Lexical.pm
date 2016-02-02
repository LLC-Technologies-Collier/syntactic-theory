package Syntactic::Practice::Grammar::Category::Lexical;

use Syntactic::Practice::Util;
use Syntactic::Practice::Types;

use Moose;

extends 'Syntactic::Practice::Grammar::Category::Terminal';

has '+label' => ( is      => 'ro',
                  isa     => 'LexicalCategoryLabel',
                  lazy    => 1,
                  builder => '_build_label' );

has '+is_terminal' => ( is      => 'ro',
                        isa     => 'True',
                        lazy    => 1,
                        builder => '_build_is_terminal' );

sub _build_is_terminal { 1 }

no Moose;
__PACKAGE__->meta->make_immutable();
