package Syntactic::Practice::Tree::Abstract::Lexical;

use Syntactic::Practice::Types;
use Moose;

extends 'Syntactic::Practice::Tree::Abstract::Terminal';
with 'Syntactic::Practice::Roles::Category::Lexical';

has '+daughters' => ( is => 'ro',
                      isa => 'Syntactic::Practice::Lexicon::Lexeme',
                      required => 1
                    );

no Moose;
__PACKAGE__->meta->make_immutable( inline_constructor => 0 );
