package Syntactic::Practice::Tree::Lexical;

use Moose::Util::TypeConstraints;

use Moose;

extends 'Syntactic::Practice::Tree::Terminal';
with 'Syntactic::Practice::Roles::Category::Terminal';

subtype 'LexicalTree', as 'Syntactic::Practice::Tree::Lexical';

has '+daughters' => ( is => 'ro',
                      isa => 'Syntactic::Practice::Lexicon::Lexeme',
                      required => 1
                    );

no Moose;
__PACKAGE__->meta->make_immutable;
