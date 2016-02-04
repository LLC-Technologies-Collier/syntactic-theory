package Syntactic::Practice::Grammar;

=head1 NAME

Syntactic::Practice::Grammar - A natural language grammar

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use Moose;
use namespace::autoclean;
use MooseX::Params::Validate;

with 'MooseX::Log::Log4perl';

has 'locale' => ( is      => 'ro',
                  isa     => 'Str',
                  default => 'en_US.UTF-8' );

my %rule;

sub rule {
  my ( $self, @args ) = @_;

  my ( %opt ) =
    validated_hash(
         \@args,
         label => { isa => 'NonTerminalCategoryLabel', optional => 0 },
         rule => { isa => 'Syntactic::Practice::Grammar::Rule', optional => 1 },
    );
  my ( $label, $rule ) = @opt{qw(label rule)};

  return $rule{$label} = $rule if $rule;

  return $rule{$label} if exists $rule{$label};

  $rule{$label} = Syntactic::Practice::Grammar::Rule->new( label => $label );
}

__PACKAGE__->meta->make_immutable;
