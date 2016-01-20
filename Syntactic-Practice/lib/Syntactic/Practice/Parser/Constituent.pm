package Syntactic::Practice::Parser::Constituent;

use Moose;
use Moose::Util::TypeConstraints;

has name => ( is  => 'ro',
              isa => 'Str' );

has label => ( is  => 'ro',
               isa => 'Str' );

has decomposition => ( is  => 'ro',
                       isa => 'ArrayRef[Syntactic::Practice::Parser::Constituent]' );

subtype 'Word', as 'Str', where { $_ !~ /\s/ };

has sentence => ( is  => 'ro',
                  isa => 'ArrayRef[Word]', );

subtype 'PositiveInt', as 'Int',
  where { $_ >= 0 },
  message { "The number you provided, $_, was not a positive number" };

has frompos => ( is  => 'ro',
                 isa => 'PositiveInt' );

has topos => ( is  => 'ro',
               isa => 'PositiveInt' );

enum 'SynCatType', [qw(phrasal lexical)];
has cat_type => ( is => 'ro',
                  isa => 'SynCatType' );

no Moose;
__PACKAGE__->meta->make_immutable;
