package Syntactic::Practice::Roles::Category::Base;

use Moose::Role;
use namespace::autoclean;


has name => ( is      => 'ro',
              isa     => 'Str',
              lazy    => 1,
              builder => '_build_name' );

sub _build_label {
  my ( $self ) = @_;
  confess 'Neither label nor category specified'
    unless exists $self->{category};
  return $self->category->label;
}

sub _build_category {
  my ( $self ) = @_;
  unless ( exists $self->{label} ) {
    my $msg = 'Neither label nor category specified';
    $self->log->error( $msg );
    die $msg;
  }
  my $class = 'Syntactic::Practice::Grammar::' . $self->_cat_class;
  return $class->new( label => $self->{label} );
}

sub _build_name        { $_[0]->category->resultset->longname }
sub _build_is_terminal { $_[0]->category->is_terminal }
sub _build_is_start    { $_[0]->category->is_start }

requires '_cat_class';

1;

package Syntactic::Practice::Roles::Category;

use Moose::Role;
use namespace::autoclean;

with 'Syntactic::Practice::Roles::Category::Base';

has label => ( is      => 'ro',
               isa     => 'SyntacticCategoryLabel',
               lazy    => 1,
               builder => '_build_label' );

has category => ( is      => 'ro',
                  isa     => 'Category',
                  lazy    => 1,
                  builder => '_build_category' );

has is_start => ( is      => 'ro',
                  isa     => 'Bool',
                  lazy    => 1,
                  builder => '_build_is_start' );

has is_terminal => ( is      => 'ro',
                     isa     => 'Bool',
                     lazy    => 1,
                     builder => '_build_is_terminal' );

sub _cat_class { 'Category' }

1;

package Syntactic::Practice::Roles::Category::Abstract;

use Moose::Role;
use namespace::autoclean;

with 'Syntactic::Practice::Roles::Category::Base';

has label => ( is      => 'rw',
               isa     => 'SyntacticCategoryLabel',
               lazy    => 1,
               builder => '_build_label' );

has category => ( is      => 'ro',
                  isa     => 'AbstractCategory',
                  lazy    => 1,
                  builder => '_build_category' );

has is_start => ( is      => 'rw',
                  isa     => 'Bool',
                  lazy    => 1,
                  builder => '_build_is_start' );

has is_terminal => ( is      => 'rw',
                     isa     => 'Bool',
                     lazy    => 1,
                     builder => '_build_is_terminal' );

sub _cat_class { 'Category::Abstract' }

1;

package Syntactic::Practice::Roles::Category::Terminal;

use Moose::Role;
use namespace::autoclean;

with 'Syntactic::Practice::Roles::Category::Base';

has label => ( is      => 'ro',
               isa     => 'TerminalCategoryLabel',
               lazy    => 1,
               builder => '_build_label' );

has category => ( is      => 'ro',
                  isa     => 'TerminalCategory',
                  lazy    => 1,
                  builder => '_build_category' );

has is_start => ( is      => 'ro',
                  isa     => 'Bool',
                  lazy    => 1,
                  builder => '_build_is_start' );

has is_terminal => ( is      => 'ro',
                     isa     => 'True',
                     lazy    => 1,
                     builder => '_build_is_terminal' );

sub _cat_class { 'Category::Terminal' }

1;

package Syntactic::Practice::Roles::Category::Lexical;

use Moose::Role;
use namespace::autoclean;

with 'Syntactic::Practice::Roles::Category::Base';

has label => ( is      => 'ro',
               isa     => 'LexicalCategoryLabel',
               lazy    => 1,
               builder => '_build_label' );

has category => ( is      => 'ro',
                  isa     => 'LexicalCategory',
                  lazy    => 1,
                  builder => '_build_category' );

has is_start => ( is      => 'ro',
                  isa     => 'False',
                  lazy    => 1,
                  builder => '_build_is_start' );

has is_terminal => ( is      => 'ro',
                     isa     => 'True',
                     lazy    => 1,
                     builder => '_build_is_terminal' );

sub _cat_class { 'Category::Lexical' }

1;

package Syntactic::Practice::Roles::Category::NonTerminal;

use Moose::Role;
use namespace::autoclean;

with 'Syntactic::Practice::Roles::Category::Base';

has label => ( is      => 'ro',
               isa     => 'NonTerminalCategoryLabel',
               lazy    => 1,
               builder => '_build_label' );

has category => ( is      => 'ro',
                  isa     => 'NonTerminalCategory',
                  lazy    => 1,
                  builder => '_build_category' );

has is_start => ( is      => 'ro',
                  isa     => 'Bool',
                  lazy    => 1,
                  builder => '_build_is_start' );

has is_terminal => ( is      => 'ro',
                     isa     => 'False',
                     lazy    => 1,
                     builder => '_build_is_terminal' );

sub _cat_class { 'Category::NonTerminal' }

1;

package Syntactic::Practice::Roles::Category::Phrasal;

use Moose::Role;
use namespace::autoclean;

with 'Syntactic::Practice::Roles::Category::Base';

has label => ( is      => 'ro',
               isa     => 'PhrasalCategoryLabel',
               lazy    => 1,
               builder => '_build_label' );

has category => ( is      => 'ro',
                  isa     => 'PhrasalCategory',
                  lazy    => 1,
                  builder => '_build_category' );

has is_start => ( is      => 'ro',
                  isa     => 'False',
                  lazy    => 1,
                  builder => '_build_is_start' );

has is_terminal => ( is      => 'ro',
                     isa     => 'False',
                     lazy    => 1,
                     builder => '_build_is_terminal' );

sub _cat_class { 'Category::Phrasal' }

1;

package Syntactic::Practice::Roles::Category::Start;

use Moose::Role;
use namespace::autoclean;

with 'Syntactic::Practice::Roles::Category::Base';

has label => ( is      => 'ro',
               isa     => 'StartCategoryLabel',
               lazy    => 1,
               builder => '_build_label' );

has category => ( is      => 'ro',
                  isa     => 'StartCategory',
                  lazy    => 1,
                  builder => '_build_category' );

has is_start => ( is      => 'ro',
                  isa     => 'True',
                  lazy    => 1,
                  builder => '_build_is_start' );

has is_terminal => ( is      => 'ro',
                     isa     => 'False',
                     lazy    => 1,
                     builder => '_build_is_terminal' );

sub _cat_class { 'Category::Start' }

sub BUILD { $_[0]->{cat_class} = 'Category::Start' }

1;
