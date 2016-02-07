package Syntactic::Practice::Tree;

=head1 NAME

Syntactic::Practice::Tree - Parse Tree Representation

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use Moose;
use namespace::autoclean;

with 'Syntactic::Practice::Roles::Category';

has name => ( is       => 'ro',
              isa      => 'Str',
              lazy     => 1,
              builder  => '_build_name',
              init_arg => undef );

has frompos => ( is       => 'ro',
                 isa      => 'PositiveInt',
                 required => 1 );

has topos => ( is       => 'ro',
               isa      => 'PositiveInt',
               lazy     => 1,
               builder  => '_build_topos',
               init_arg => undef );

has string => ( is       => 'ro',
                isa      => 'Str',
                lazy     => 1,
                builder  => '_build_string',
                init_arg => undef );

has sentence => ( is      => 'ro',
                  isa     => 'ArrayRef[Tree]',
                  lazy    => 1,
                  builder => '_build_sentence', );

has sisters => ( is       => 'ro',
                 isa      => 'ArrayRef[Tree]',
                 required => 1, );

has daughters => ( is       => 'ro',
                   isa      => 'ArrayRef[Tree]',
                   required => 1, );

has mother => ( is       => 'ro',
                isa      => 'Tree',
                required => 1 );

has depth => ( is       => 'ro',
               isa      => 'PositiveInt',
               lazy     => 1,
               builder  => '_build_depth',
               init_arg => undef, );

has prune_nulls => ( is      => 'ro',
                     isa     => 'Bool',
                     default => 1 );

sub _build_label    { $_[0]->factor->label }
sub _build_category { $_[0]->factor->category }

sub _build_name {
  my ( $self ) = @_;
  $self->label . $self->_numTrees( { label => $self->label } );
}

sub _build_topos {
  my ( $self ) = @_;
  ref $self->{daughters} eq 'ARRAY'
    ? $self->{daughters}->[-1]->topos
    : $self->frompos + 1;
}

sub _build_string {
  my ( $self ) = @_;
  my @s = @{ $self->sentence };
  join( ' ', map { $_->string } @s[ $self->frompos .. ( $self->topos - 1 ) ] );
}

sub _build_sentence {
  my ( $self ) = @_;
  return $self->{mother}->sentence if exists $self->{mother};
  foreach my $family ( qw( siblings daughters ) ) {
    $self->log->debug("Checkin $family for tree...");
    return $self->{$family}->[0]->sentence if exists $self->{$family} && scalar @{ $self->{$family} };
  }
  confess 'Cannot determine sentence';
}

sub _build_depth { $_[0]->mother->depth + 1 }

around daughters => sub {
  my ( $orig, $self ) = @_;

  return ( ref $self->{daughters} eq 'ARRAY'
           ? @{ $self->{daughters} }
           : ( $self->{daughters} ) );
};

my %treeByName;
my %treeByLabel;

sub _treeExists {
  my ( $self, $arg ) = @_;

  return $treeByName{ $arg->{name} }
    if ( exists $treeByName{ $arg->{name} } );
  return 0;
}

sub _registerTree {
  my ( $self ) = @_;

  $treeByLabel{ $self->label } = []
    unless exists $treeByLabel{ $self->label };

  push( @{ $treeByLabel{ $self->label } }, $treeByName{ $self->name } = $self );
}

sub _numTrees {
  my ( $self, $arg ) = @_;
  $treeByLabel{ $arg->{label} } = []
    unless exists $treeByLabel{ $arg->{label} };
  scalar @{ $treeByLabel{ $arg->{label} } };
}

sub BUILD {
  my ( $self ) = @_;

  $self->log->info('tree has been built.  Now registering');
  $self->_registerTree();

  return $self;
}

sub cmp {
  my ( $self, $other ) = @_;
  my $result;
  foreach my $attribute ( qw(label frompos topos ) ) {
    $result = $self->$attribute cmp $other->$attribute;
    return $result unless $result == 0;
  }

  my @self_daughter  = $self->daughters;
  my @other_daughter = $other->daughters;

  $result = scalar @self_daughter <=> scalar @other_daughter;
  return $result unless $result == 0;

  for ( my $i = 0; $i < scalar @self_daughter; $i++ ) {
    $result = ( $self_daughter[$i] cmp $other_daughter[$i] );
    return $result unless $result == 0;
  }

  return 0;
}

sub as_forest {
  my ( $self ) = @_;

  my $indent = ' ' x ( $self->depth * 2 );

  my $output   = '';
  my @daughter = $self->daughters;

  $output .= "${indent}[" . $self->label . "\n${indent}";
  if ( $self->category->is_terminal ) {
    $output .= '['.$daughter[0]->word.'] ';
  } else {
    $output .= join( '', map { $_->as_forest() } @daughter );
    $output .= "\n${indent}";
  }
  $output .= ']';
  return $output;
}

sub as_text {
  my ( $self ) = @_;
  my $output = '';

  my $indent = ' ' x ( $self->depth * 2 );
  $output .= $indent . $self->name . ': ';

  my @daughter = map { $_ // '(null)' } ($self->daughters);
  $self->log->debug( Data::Printer::p @daughter );
  return "${output}@daughter\n" if $self->is_terminal;

  my $ref   = ref $self;
  my $label = $self->label;
  warn "$ref - $label";

  $output .=
    join( ' ', map { ref $_ ? $_->label : $_ } @daughter ) . "\n${indent}";
  $output .= join( '', map { ref $_ ? $_->as_text : $_ } @daughter );

  return $output;
}

sub to_concrete {
  my ( $self, $arg ) = @_;

  my @c_daughters;
  foreach my $daughter ( $self->daughters ) {
    if ( $daughter->isa( 'Str' ) ) {
      push( @c_daughters, $daughter );
    } elsif ( $daughter->isa( 'Tree' ) ) {
      push( @c_daughters, $daughter->to_concrete );
    } else {
      $self->log->warn( 'Daughter is of unknown type' );
      push( @c_daughters, undef );
    }
  }

  ( my $class = ref $self ) =~ ( s/Abstract::// );

  return $class->new( %$self, %$arg, daughters => \@c_daughters );
}

__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Tree::NonTerminal;

use Moose;
use namespace::autoclean;

extends 'Syntactic::Practice::Tree';
with 'Syntactic::Practice::Roles::Category::NonTerminal';

__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Tree::Phrasal;

use Moose;
use namespace::autoclean;

extends 'Syntactic::Practice::Tree::NonTerminal';
with 'Syntactic::Practice::Roles::Category::Terminal';

__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Tree::Start;

use Moose;
use namespace::autoclean;

extends 'Syntactic::Practice::Tree::NonTerminal';
with 'Syntactic::Practice::Roles::Category::Start';

has mother => ( is      => 'ro',
                isa     => 'Undefined',
                lazy    => 1,
                builder => '_build_mother' );

sub _build_mother { undef }
sub _build_depth  { 0 }

__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Tree::Terminal;

use Moose;
use namespace::autoclean;

extends 'Syntactic::Practice::Tree';
with 'Syntactic::Practice::Roles::Category::Terminal';

sub _build_topos { $_[0]->frompos + 1 }

__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Tree::Lexical;

use Moose;
use namespace::autoclean;

extends 'Syntactic::Practice::Tree::Terminal';
with 'Syntactic::Practice::Roles::Category::Terminal';

has '+daughters' => ( is       => 'ro',
                      isa      => 'Syntactic::Practice::Lexicon::Lexeme',
                      required => 1 );

__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Tree::Null;

use Moose;
use namespace::autoclean;

extends 'Syntactic::Practice::Tree::Terminal';
with 'Syntactic::Practice::Roles::Category::Terminal';

has '+label' => ( is      => 'ro',
                  isa     => 'SyntacticCategoryLabel',
                  lazy    => 1,
                  builder => '_build_label' );

has '+category' => ( is      => 'ro',
                     isa     => 'Syntactic::Practice::Grammar::Category',
                     lazy    => 1,
                     builder => '_build_category' );

has '+daughters' => ( is      => 'ro',
                      isa     => 'Undefined',
                      lazy    => 1,
                      builder => '_build_daughters', );

sub _build_string    { '' }
sub _build_daughters { undef }
sub _build_topos     { $_[0]->frompos }
sub _build_name      { $_[0]->label . '0' }

__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Tree::Abstract;

use Moose;
use namespace::autoclean;

with 'Syntactic::Practice::Roles::Category';
with 'MooseX::Log::Log4perl';

extends 'Syntactic::Practice::Tree';

has daughters => ( is       => 'rw',
                   isa      => 'ArrayRef[AbstractTree]',
                   required => 0, );

has mother => ( is       => 'rw',
                isa      => ( 'AbstractTree' ),
                required => 0 );

has sentence => ( is      => 'rw',
                  isa     => 'ArrayRef[Tree]',
                  lazy    => 1,
                  builder => '_build_sentence', );

has sisters => ( is       => 'rw',
                 isa      => ( 'ArrayRef[AbstractTree]' ),
                 required => 0 );

has frompos => ( is       => 'rw',
                 isa      => ( 'PositiveInt' ),
                 required => 0 );

has factor => ( is  => 'rw',
                isa => 'Factor' );

has '+prune_nulls' => ( is      => 'ro',
                        isa     => 'False',
                        default => 0 );

around daughters => sub {
  my ( $orig, $self ) = @_;

  return ( ref $self->{daughters} eq 'ARRAY'
           ? @{ $self->{daughters} }
           : ( $self->{daughters} ) );
};

sub _build_depth {
  my ( $self ) = @_;
  exists $self->{mother} ? $self->{mother}->depth + 1 : 0;
}

my %abstractTreeByName;
my %abstractTreeByLabel;

sub _treeExists {
  my ( $self, $arg ) = @_;

  return $abstractTreeByName{ $arg->{name} }
    if ( exists $abstractTreeByName{ $arg->{name} } );
  return 0;
}

sub _registerTree {
  my ( $self ) = @_;

  warn ref $self unless $self->label;
  $abstractTreeByLabel{ $self->label } = []
    unless exists $abstractTreeByLabel{ $self->label };
  push( @{ $abstractTreeByLabel{ $self->label } },
        $abstractTreeByName{ $self->name } = $self );
}

sub _numTrees {
  my ( $self, $arg ) = @_;
  $abstractTreeByLabel{ $arg->{label} } = []
    unless exists $abstractTreeByLabel{ $arg->{label} };
  return scalar @{ $abstractTreeByLabel{ $arg->{label} } };
}

__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Tree::Abstract::NonTerminal;

use Moose;
use namespace::autoclean;

with 'Syntactic::Practice::Roles::Category::NonTerminal';
extends 'Syntactic::Practice::Tree::Abstract';

__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Tree::Abstract::Phrasal;

use Moose;
use namespace::autoclean;

with 'Syntactic::Practice::Roles::Category::Phrasal';
extends 'Syntactic::Practice::Tree::Abstract::NonTerminal';

__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Tree::Abstract::Start;

use Moose;
use namespace::autoclean;

extends 'Syntactic::Practice::Tree::Abstract::NonTerminal';
with 'Syntactic::Practice::Roles::Category::Start';

has mother => ( is      => 'ro',
                isa     => 'Undefined',
                lazy    => 1,
                builder => '_build_mother' );

sub _build_mother { undef }
sub _build_depth  { 0 }

__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Tree::Abstract::Terminal;

use Moose;
use namespace::autoclean;

extends 'Syntactic::Practice::Tree::Abstract';
with 'Syntactic::Practice::Roles::Category::Terminal';

__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Tree::Abstract::Null;

use Moose;
use namespace::autoclean;

extends 'Syntactic::Practice::Tree::Abstract::Terminal';
with 'Syntactic::Practice::Roles::Category::Terminal';

has '+label' => ( is      => 'ro',
                  isa     => 'SyntacticCategoryLabel',
                  lazy    => 1,
                  builder => '_build_label' );

has '+category' => ( is      => 'ro',
                     isa     => 'Syntactic::Practice::Grammar::Category',
                     lazy    => 1,
                     builder => '_build_category' );

has '+daughters' => ( is      => 'ro',
                      isa     => 'Undefined',
                      lazy    => 1,
                      builder => '_build_daughters', );

sub _build_daughters { undef }
sub _build_topos     { $_[0]->frompos }
sub _build_name      { $_[0]->label . '0' }

__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Tree::Abstract::Lexical;

use Moose;
use namespace::autoclean;
extends 'Syntactic::Practice::Tree::Abstract::Terminal';
with 'Syntactic::Practice::Roles::Category::Lexical';

has '+daughters' => ( is       => 'ro',
                      isa      => 'Syntactic::Practice::Lexicon::Lexeme',
                      required => 1 );

sub _build_string { $_[0]->daughters->word }

__PACKAGE__->meta->make_immutable;
