package Syntactic::Practice::Phrase;

use Syntactic::Practice::Constituent;
use Moose;

extends 'Syntactic::Practice::Constituent';

has '+decomposition' => ( is  => 'ro',
                          isa => 'ArrayRef[Syntactic::Practice::Constituent]',
                          default => sub { [] }, );

has '+sentence' => ( is       => 'ro',
                     isa      => 'ArrayRef[Syntactic::Practice::Lexeme]',
                     required => 1 );

no Moose;
__PACKAGE__->meta->make_immutable;
