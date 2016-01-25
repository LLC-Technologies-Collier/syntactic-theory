package Syntactic::Practice::Grammar::Symbol::Terminal;

use Syntactic::Practice::Util;
use Syntactic::Practice::Types;

use Moose;

extends Syntactic::Practice::Grammar::Symbol;

has 'label' => ( is       => 'ro',
                 isa      => 'TerminalCategoryLabel',
                 required => 1 );

has '+is_terminal' => ( is      => 'ro',
                        isa     => 'Bool',
                        default => 1 );
around 'new' => sub {
  my ( $self, @arg ) = @_;

  my $arg;
  if ( scalar @arg == 1 && ref $arg[0] eq 'HASH' ) {
    $arg = $arg[0];
  } else {
    $arg = {@arg};
  }

  die "Cannot mark a terminal symbol as non-terminal"
    unless $arg->{is_terminal};

};

no Moose;
__PACKAGE__->meta->make_immutable();
