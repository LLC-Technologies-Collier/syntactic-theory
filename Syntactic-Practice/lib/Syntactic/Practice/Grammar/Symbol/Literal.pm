package Syntactic::Practice::Grammar::Symbol::Literal;

use Syntactic::Practice::Types;

use Moose;

extends 'Syntactic::Practice::Grammar::Symbol::Terminal';

has '+label' => ( is       => 'ro',
                  isa      => 'Str',
                  required => 1 );

sub as_string {
  my ( $self ) = @_;

  my $str = $self->label;

  return qq{"$str"};
}

no Moose;
__PACKAGE__->meta->make_immutable();
