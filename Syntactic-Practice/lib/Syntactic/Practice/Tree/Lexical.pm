package Syntactic::Practice::Tree::Lexical;

use Syntactic::Practice::Types;
use Moose;

extends 'Syntactic::Practice::Tree::Terminal';

has '+label' => ( is       => 'ro',
                  isa      => 'LexicalCategoryLabel',
                  required => 0, );

has '+daughters' => ( is => 'ro',
                      isa => 'Syntactic::Practice::Schema::Result::Lexeme',
                      required => 1
                    );

no Moose;
__PACKAGE__->meta->make_immutable( inline_constructor => 0 );
