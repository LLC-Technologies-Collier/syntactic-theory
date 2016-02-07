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

  return Syntactic::Practice::Grammar->new->category( label => $self->label );
}

sub _build_is_terminal {
  grep { $_ eq $_[0]->label } Syntactic::Practice::Util->get_terminal_labels;
}

sub _build_is_recursive {
  grep { $_ eq $_[0]->label } Syntactic::Practice::Util->get_recursive_labels;
}

sub _build_is_start {
  grep { $_ eq $_[0]->label } Syntactic::Practice::Util->get_start_labels;
}
sub _build_name         { $_[0]->category->resultset->longname }

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

1;

package Syntactic::Practice::Roles::Category::Recursive;

use Moose::Role;
use namespace::autoclean;

with( 'Syntactic::Practice::Roles::Category::Base',
      'Syntactic::Practice::Roles::Category::NonTerminal', );

has is_recursive => ( is      => 'ro',
                      isa     => 'True',
                      lazy    => 1,
                      builder => '_build_is_recursive' );

1;

package Syntactic::Practice::Roles::Category::NonRecursive;

use Moose::Role;
use namespace::autoclean;

with 'Syntactic::Practice::Roles::Category::Base';

has is_recursive => ( is      => 'ro',
                      isa     => 'False',
                      lazy    => 1,
                      builder => '_build_is_recursive' );

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

1;

package Syntactic::Practice::Roles::Category::Start;

use Moose::Role;
use namespace::autoclean;

with 'Syntactic::Practice::Roles::Category::Base' =>
  { -excludes => '_build_label' };

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

sub _build_label { 'S' }

1;
