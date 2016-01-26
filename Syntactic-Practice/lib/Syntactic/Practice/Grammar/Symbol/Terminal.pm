package Syntactic::Practice::Grammar::Symbol::Terminal;

use Syntactic::Practice::Grammar::Symbol;
use Syntactic::Practice::Util;
use Syntactic::Practice::Types;

use Moose;

extends 'Syntactic::Practice::Grammar::Symbol';

has 'label' => ( is       => 'ro',
                 isa      => 'TerminalCategoryLabel',
                 required => 1 );

has '+is_terminal' => ( is      => 'ro',
                        isa     => 'Bool',
                        default => 1 );
around 'new' => sub {
  my ( $orig, $self, @arg ) = @_;

  my $arg;
  if ( scalar @arg == 1 && ref $arg[0] eq 'HASH' ) {
    $arg = $arg[0];
  } else {
    $arg = {@arg};
  }

  die "Cannot mark a terminal symbol as non-terminal"
    if exists $arg->{is_terminal} && !$arg->{is_terminal};


  my $obj = $self->$orig( @arg );
};

no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);
