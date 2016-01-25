package Syntactic::Practice::Grammar::Symbol;

use Syntactic::Practice::Util;
use Syntactic::Practice::Types;

use Moose;

has 'label' => ( is       => 'ro',
                 isa      => 'SyntacticCategoryLabel',
                 required => 1 );

has 'name' => ( is => 'ro',
                isa => 'Str',
                required => 1 );

has 'optional' => ( is      => 'ro',
                    isa     => 'Bool',
                    default => '0' );

has 'repeat' => ( is      => 'ro',
                  isa     => 'Bool',
                  default => '0' );

has 'is_terminal' => ( is => 'ro',
                       isa => 'Bool',
                       required => 1
                     );

sub as_string {
  my ( $self ) = @_;

  my $str = $self->label;
  $str = ( $self->optional ? "[$str]" : "<$str>" );
  $str .= '+' if $self->repeat;

  return $str;
}

no Moose;
__PACKAGE__->meta->make_immutable();
