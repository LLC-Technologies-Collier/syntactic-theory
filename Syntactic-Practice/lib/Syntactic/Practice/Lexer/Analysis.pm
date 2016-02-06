package Syntactic::Practice::Lexer::Analysis;

use strict;

=head1 NAME

Syntactic::Practice::Lexer::Analysis - Resuls of a lexical analysis

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use Moose;
use namespace::autoclean;

has tokens => ( is => 'ro',
                isa => 'ArrayRef[Token]' );

__PACKAGE__->meta->make_immutable;

