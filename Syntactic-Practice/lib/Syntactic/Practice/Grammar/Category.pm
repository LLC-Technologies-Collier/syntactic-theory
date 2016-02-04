package Syntactic::Practice::Grammar::Factor;
1;

package Syntactic::Practice::Grammar::Category;

=head1 NAME

Syntactic::Practice::Grammar::Category - Syntactic Category Representation

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use Moose::Util::TypeConstraints;

use Moose;

with 'MooseX::Log::Log4perl';

subtype SyntacticCategory => as 'Syntactic::Practice::Grammar::Category';

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
          Syntactic::Practice::Factor->new( resultset => $resultset ) );
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

no Moose;
__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Grammar::Category::Terminal;

use Moose::Util::TypeConstraints;

use Moose;

subtype TerminalCategory => as
  'Syntactic::Practice::Grammar::Category::Terminal';

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

no Moose;
__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Grammar::Category::Lexical;

use Moose::Util::TypeConstraints;

use Moose;

subtype LexicalCategory => as 'Syntactic::Practice::Grammar::Category::Lexical';

extends 'Syntactic::Practice::Grammar::Category::Terminal';

has '+label' => ( is      => 'ro',
                  isa     => 'LexicalCategoryLabel',
                  lazy    => 1,
                  builder => '_build_label' );

no Moose;
__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Grammar::Category::NonTerminal;

use Moose::Util::TypeConstraints;

use Moose;

subtype NonTerminalCategory => as
  'Syntactic::Practice::Grammar::Category::NonTerminal';

extends 'Syntactic::Practice::Grammar::Category';

has '+label' => ( is      => 'ro',
                  isa     => 'NonTerminalCategoryLabel',
                  lazy    => 1,
                  builder => '_build_label' );

has '+is_terminal' => ( is      => 'ro',
                        isa     => 'False',
                        lazy    => 1,
                        builder => '_build_is_terminal' );

sub _build_is_terminal { 0 }

no Moose;
__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Grammar::Category::Phrasal;

use Moose::Util::TypeConstraints;

use Moose;

subtype PhrasalCategory => as 'Syntactic::Practice::Grammar::Category::Phrasal';

extends 'Syntactic::Practice::Grammar::Category::NonTerminal';

has '+label' => ( is      => 'ro',
                  isa     => 'PhrasalCategoryLabel',
                  lazy    => 1,
                  builder => '_build_label' );

sub _get_category_class { 'Category::Phrasal' }

no Moose;
__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Grammar::Category::Start;

use Moose::Util::TypeConstraints;

use Moose;

subtype StartCategory => as 'Syntactic::Practice::Grammar::Category::Start';

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

sub _build_category {
  Syntactic::Practice::Grammar::Start->new( label => $_[0]->label );
}

no Moose;
__PACKAGE__->meta->make_immutable;
