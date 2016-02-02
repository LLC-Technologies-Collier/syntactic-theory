package Syntactic::Practice::Tree::Lexical;

use Moose;

with 'Syntactic::Practice::Roles::Category::Terminal';
extends 'Syntactic::Practice::Tree::Terminal';

has '+daughters' => ( is => 'ro',
                      isa => 'Syntactic::Practice::Lexicon::Lexeme',
                      required => 1
                    );

no Moose;
__PACKAGE__->meta->make_immutable;
