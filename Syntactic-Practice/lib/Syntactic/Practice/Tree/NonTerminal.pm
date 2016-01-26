package Syntactic::Practice::Tree::NonTerminal;

use Syntactic::Practice::Types;
use Moose;

extends 'Syntactic::Practice::Tree';

has '+label' => ( is       => 'ro',
                  isa      => 'NonTerminalCategoryLabel',
                  required => 1, );

has '+is_terminal' => ( is      => 'ro',
                        isa     => 'Bool',
                        default => 0 );
around 'new' => sub {
  my ( $orig, $self, @arg ) = @_;
  my $arg;
  if ( scalar @arg == 1 && ref $arg[0] eq 'HASH' ) {
    $arg = $arg[0];
  } else {
    $arg = {@arg};
  }

  die "Cannot mark a non-terminal symbol as terminal"
    if exists $arg->{is_terminal} && !$arg->{is_terminal};

  my $tree = $self->$orig( $arg );
};

no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);
