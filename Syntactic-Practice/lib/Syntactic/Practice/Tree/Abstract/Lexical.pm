package Syntactic::Practice::Tree::Abstract::Lexical;

use Moose;

extends 'Syntactic::Practice::Tree::Abstract::Terminal';
with 'Syntactic::Practice::Roles::Category::Lexical';

has '+daughters' => ( is => 'ro',
                      isa => 'Syntactic::Practice::Lexicon::Lexeme',
                      required => 1
                    );

no Moose;
__PACKAGE__->meta->make_immutable;
