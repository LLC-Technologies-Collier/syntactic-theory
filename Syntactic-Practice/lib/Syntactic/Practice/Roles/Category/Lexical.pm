package Syntactic::Practice::Roles::Category::Lexical;

use Syntactic::Practice::Util;
use Syntactic::Practice::Types;

use Moose::Role;
use namespace::autoclean;

extends 'Syntactic::Practice::Roles::Category::Terminal';

has '+label' => ( is      => 'ro',
                  isa     => 'LexicalCategoryLabel',
                  lazy    => 1,
                  builder => '_build_label' );

has 'category' => ( is   => 'ro',
                    isa  => 'Syntactic::Practice::Grammar::Category::Lexical',
                    lazy => 1,
                    builder => '_build_category' );

no Moose::Role;
1;
