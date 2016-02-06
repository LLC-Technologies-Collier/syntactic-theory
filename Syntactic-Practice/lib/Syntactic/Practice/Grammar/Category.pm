package Syntactic::Practice::Grammar::Factor;
1;

package Syntactic::Practice::Grammar::Category;

=head1 NAME

Syntactic::Practice::Grammar::Category - Syntactic Category Representation

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use Moose;
use namespace::autoclean;

with 'MooseX::Log::Log4perl';

my $rs_namespace = Syntactic::Practice::Util->get_rs_namespace();
my $rs_class     = 'SyntacticCategory';

has 'label' => ( is        => 'ro',
                 isa       => $rs_class . 'Label',
                 lazy      => 1,
                 builder   => '_build_label',
                 predicate => 'has_label', );

has 'name' => ( is       => 'ro',
                isa      => 'Str',
                lazy     => 1,
                init_arg => undef,
                builder  => '_build_name' );

has 'resultset' => ( is        => 'ro',
                     isa       => $rs_namespace . '::' . $rs_class,
                     lazy      => 1,
                     builder   => '_build_resultset',
                     predicate => 'has_resultset', );

has factors => ( is       => 'ro',
                 isa      => 'ArrayRef[Syntactic::Practice::Grammar::Factor]',
                 lazy     => 1,
                 builder  => '_build_factors',
                 init_arg => undef, );

has 'is_terminal' => ( is      => 'ro',
                       isa     => 'Bool',
                       lazy    => 1,
                       builder => '_build_is_terminal' );

has 'is_start' => ( is      => 'ro',
                    isa     => 'Bool',
                    lazy    => 1,
                    builder => '_build_is_start' );

sub _build_label {
  my ( $self ) = @_;
  confess 'Neither label nor resultset were specified'
    unless $self->has_resultset;

  $self->resultset->label;
}

sub _build_name {
  $_[0]->resultset->longname;
}

sub _build_resultset {
  my ( $self ) = @_;
  confess 'Neither label nor resultset were specified'
    unless $self->has_label;

  Syntactic::Practice::Util->get_schema->resultset( 'SyntacticCategory' )
    ->find( { label => $self->label } );
}

sub _build_factors {
  my ( $self ) = @_;
  my $rs = $self->resultset->factors;
  my @return;
  while ( my $resultset = $rs->next ) {
    push( @return,
          Syntactic::Practice::Grammar::Factor->new(
                                                 resultset => $resultset,
                                                 label => $resultset->cat->label
          ) );
  }
  return \@return;
}

sub _build_is_terminal {
  my $ctype = $_[0]->resultset->ctype;
  return 0 if ( $ctype eq 'phrasal' );
  return 1 if ( $ctype eq 'lexical' );
}

sub _build_is_start {
  my $label = $_[0]->label;
  return 0 if ( $label ne 'S' );
  return 1 if ( $label eq 'S' );
}

__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Grammar::Category::Terminal;

use Moose;
use namespace::autoclean;

extends 'Syntactic::Practice::Grammar::Category';

has '+label' => ( is      => 'ro',
                  isa     => 'TerminalCategoryLabel',
                  lazy    => 1,
                  builder => '_build_label' );

has '+is_terminal' => ( is      => 'ro',
                        isa     => 'True',
                        lazy    => 1,
                        builder => '_build_is_terminal' );

sub _build_is_terminal  { 1 }
sub _build_is_start     { 0 }
sub _get_category_class { 'Category::Terminal' }

__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Grammar::Category::Lexical;

use Moose;
use namespace::autoclean;

extends 'Syntactic::Practice::Grammar::Category::Terminal';

has '+label' => ( is      => 'ro',
                  isa     => 'LexicalCategoryLabel',
                  lazy    => 1,
                  builder => '_build_label' );

__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Grammar::Category::NonTerminal;

use Moose;
use namespace::autoclean;

extends 'Syntactic::Practice::Grammar::Category';

has '+label' => ( isa => 'NonTerminalCategoryLabel' );

has '+is_terminal' => ( isa => 'False' );

sub _build_is_terminal { 0 }

__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Grammar::Category::Phrasal;

use Moose;
use namespace::autoclean;

extends 'Syntactic::Practice::Grammar::Category::NonTerminal';

has '+label' => ( isa => 'PhrasalCategoryLabel' );

sub _get_category_class { 'Category::Phrasal' }

__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Grammar::Category::Start;

use Moose;
use namespace::autoclean;

extends 'Syntactic::Practice::Grammar::Category::NonTerminal';

has '+label' => ( is      => 'ro',
                  isa     => 'StartCategoryLabel',
                  lazy    => 1,
                  builder => '_build_label', );

has '+is_start' => ( is      => 'ro',
                     isa     => 'True',
                     lazy    => 1,
                     builder => '_build_is_start' );

sub _build_is_start { 1 }
sub _build_label    { 'S' }
sub _is_terminal    { 0 }

sub _build_category {
  Syntactic::Practice::Grammar::Category::Start->new( label => $_[0]->label );
}

__PACKAGE__->meta->make_immutable;
