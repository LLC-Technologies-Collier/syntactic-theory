package Syntactic::Practice::Roles::Category;

use Moose::Role;
use namespace::autoclean;

my $rs_namespace = Syntactic::Practice::Util->get_rs_namespace();

my $rs_class       = 'Category';
my $category_class = 'Syntactic::Practice::Grammar::Category';

has 'label' => ( is      => 'ro',
                 isa     => 'SyntacticCategoryLabel',
                 lazy    => 1,
                 builder => '_build_label' );

has 'category' => ( is      => 'ro',
                    isa     => 'SyntacticCategory',
                    lazy    => 1,
                    builder => '_build_category' );

has 'name' => ( is      => 'ro',
                isa     => 'Str',
                lazy    => 1,
                builder => '_build_name' );

has 'is_start' => ( is      => 'ro',
                    isa     => 'Bool',
                    lazy    => 1,
                    builder => '_build_is_start' );

has 'is_terminal' => ( is      => 'ro',
                       isa     => 'Bool',
                       lazy    => 1,
                       builder => '_build_is_terminal' );

sub _build_label {
  my ( $self ) = @_;
  confess 'Neither label nor category specified'
    unless exists $self->{category};
  return $self->category->label;
}

sub _build_category {
  my ( $self ) = @_;
  die 'Neither label nor category specified' unless exists $self->{label};
  my $class = 'Syntactic::Practice::Grammar::' . $self->_get_category_class;
  return $class->new( label => $self->{label} );
}

sub _build_name         { $_[0]->category->resultset->longname }
sub _build_is_terminal  { $_[0]->category->is_terminal }
sub _build_is_start     { $_[0]->category->is_start }
sub _get_category_class { 'Category' }

1;

package Syntactic::Practice::Roles::Category::Abstract;

use Moose::Role;
use namespace::autoclean;

with 'Syntactic::Practice::Roles::Category';

my $rs_namespace = Syntactic::Practice::Util->get_rs_namespace();

my $rs_class  = 'SyntacticCategory';
my $cat_class = 'Syntactic::Practice::Grammar::Category';

has 'label' => ( is      => 'rw',
                 isa     => 'SyntacticCategoryLabel',
                 lazy    => 1,
                 builder => '_build_label' );

has 'category' => ( is   => 'ro',
                    isa  => 'AbstractCategory',
                    lazy => 1,
                    builder => '_build_category' );

has 'is_start' => ( is      => 'rw',
                    isa     => 'Bool',
                    lazy    => 1,
                    builder => '_build_is_start' );

has 'is_terminal' => ( is      => 'rw',
                       isa     => 'Bool',
                       lazy    => 1,
                       builder => '_build_is_terminal' );


1;

package Syntactic::Practice::Roles::Category::Terminal;

use Moose::Role;
use namespace::autoclean;

with 'Syntactic::Practice::Roles::Category';

has 'label' => ( is      => 'ro',
                 isa     => 'TerminalCategoryLabel',
                 lazy    => 1,
                 builder => '_build_label' );

has 'category' => ( is   => 'ro',
                    isa  => 'TerminalCategory',
                    lazy => 1,
                    builder => '_build_category' );

sub _build_is_terminal  { 1 }
sub _build_is_start     { 0 }
sub _get_category_class { 'Category::Terminal' }

1;

package Syntactic::Practice::Roles::Category::Lexical;

use Moose::Role;
use namespace::autoclean;

with 'Syntactic::Practice::Roles::Category::Terminal';

has 'label' => ( is      => 'ro',
                 isa     => 'LexicalCategoryLabel',
                 lazy    => 1,
                 builder => '_build_label' );

has 'category' => (is  => 'ro',
                   isa => 'LexicalCategory',
                   lazy    => 1,
                   builder => '_build_category' );


sub _get_category_class { 'Category::Lexical' }

1;

package Syntactic::Practice::Roles::Category::NonTerminal;

use Moose::Role;
use namespace::autoclean;

with 'Syntactic::Practice::Roles::Category';

has 'label' => ( is      => 'ro',
                 isa     => 'NonTerminalCategoryLabel',
                 lazy    => 1,
                 builder => '_build_label' );

has 'category' => (is  => 'ro',
                   isa => 'NonTerminalCategory',
                   lazy    => 1,
                   builder => '_build_category' );

sub _build_is_start     { 0 }
sub _build_is_terminal  { 0 }
sub _get_category_class { 'Category::Terminal' }

1;

package Syntactic::Practice::Roles::Category::Phrasal;

use Moose::Role;
use namespace::autoclean;

with 'Syntactic::Practice::Roles::Category::NonTerminal';

has 'label' => ( is      => 'ro',
                 isa     => 'PhrasalCategoryLabel',
                 lazy    => 1,
                 builder => '_build_label' );

has 'category' => ( is   => 'ro',
                    isa  => 'PhrasalCategory',
                    lazy => 1,
                    builder => '_build_category' );

sub _get_category_class { 'Category::Phrasal' }

1;

package Syntactic::Practice::Roles::Category::Start;

use Moose::Role;
use namespace::autoclean;

with 'Syntactic::Practice::Roles::Category::NonTerminal';

has 'label' => ( is      => 'ro',
                 isa     => 'StartCategoryLabel',
                 lazy    => 1,
                 builder => '_build_label' );

has 'category' => ( is   => 'ro',
                    isa  => 'NonTerminalCategory',
                    lazy => 1,
                    builder => '_build_category' );

has 'is_start' => ( is      => 'ro',
                    isa     => 'True',
                    lazy    => 1,
                    builder => '_build_is_start' );

has 'frompos' => ( is       => 'ro',
                   isa      => 'PositiveInt',
                   lazy     => 1,
                   builder  => '_build_frompos',
                   init_arg => undef );

sub _build_is_start    { 1 }
sub _build_is_terminal { 0 }
sub _build_label       { 'S' }
sub _build_frompos     { 0 }
sub _build_category {
  Syntactic::Practice::Grammar::Category::Start->new( label => $_[0]->label );
}

sub _get_category_class { 'Category::Start' }

1;
