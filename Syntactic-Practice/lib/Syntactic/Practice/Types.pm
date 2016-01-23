package Syntactic::Practice::Types;

use Moose;
use Moose::Util::TypeConstraints;

subtype 'Word', as 'Str', where { $_ !~ /\s/ };

subtype 'PositiveInt', as 'Int',
  where { $_ >= 0 },
  message { "The number you provided, $_, was not a positive number" };

enum 'SynCatType', [qw(phrasal lexical)];

no Moose;
__PACKAGE__->meta->make_immutable;
