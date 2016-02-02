package Syntactic::Practice::Grammar::Symbol::Lexical;

use Moose;

extends 'Syntactic::Practice::Grammar::Symbol::Terminal';
with 'Syntactic::Practice::Roles::Category::Lexical';

no Moose;
__PACKAGE__->meta->make_immutable;
