package Syntactic::Practice::Tree;

=head1 NAME

Syntactic::Practice::Tree - Parse Tree Representation

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use Moose::Util::TypeConstraints;

use Moose;
use namespace::autoclean;

with 'Syntactic::Practice::Roles::Category';

subtype Tree => as 'Syntactic::Practice::Tree';

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

has sisters => ( is       => 'ro',
                 isa      => 'ArrayRef[Tree]',
                 required => 1, );

has daughters => ( is       => 'ro',
                   isa      => 'ArrayRef[Tree]',
                   required => 1, );

has mother => ( is       => 'ro',
                isa      => 'Tree',
                required => 1 );

has depth => ( is       => 'rw',
               isa      => 'PositiveInt',
               lazy     => 1,
               builder  => '_build_depth',
               init_arg => undef, );

has prune_nulls => ( is      => 'ro',
                     isa     => 'Bool',
                     default => 1 );

sub _build_name {
  my ( $self ) = @_;
  $self->label . $self->_numTrees( { label => $self->label } );
}
sub _build_topos {
  my( $self) = @_;
  ref $self->{daughters} eq 'ARRAY' ? $self->daughters->[-1]->topos : $self->frompos + 1
}
sub _build_depth { $_[0]->mother->depth + 1 }

around 'daughters' => sub {
  my ( $orig, $self ) = @_;

  warn Data::Dumper::Dumper( { label => $self->label,
                               daughters => $self->{daughters} } );

  return ( ref $self->{daughters} eq 'ARRAY'
           ? @{ $self->{daughters} }
           : ( $self->{daughters} ) );
};

my %treeByName;
my %treeByLabel;

sub _treeExists {
  my ( $self, $arg ) = @_;

  return $treeByName{ $arg->{name} } if ( exists $treeByName{ $arg->{name} } );
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

  $self->_registerTree();
}

sub cmp {
  my($self,$other) = @_;
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
};

sub as_forest {
  my ( $self ) = @_;

  my $indent = ' ' x ( $self->depth * 2 );

  my $output   = '';
  my @daughter = $self->daughters;

  $output .= "${indent}[" . $self->label . "\n${indent}";
  if ( $self->factor->is_terminal ) {
    $output .= "[@daughter] ";
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

  my @daughter = map { $_ // '(null)' } $self->daughters;
  return "${output}@daughter\n" if $self->is_terminal;

  my $ref = ref $self;
  my $label = $self->label;
  warn "$ref - $label";

  $output .= join( ' ', map { ref $_ ? $_->label : $_ } @daughter ) . "\n${indent}";
  $output .= join( '',  map { ref $_ ? $_->as_text : $_ } @daughter );

  return $output;
}

__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Tree::NonTerminal;

use Moose::Util::TypeConstraints;

use Moose;
use namespace::autoclean;

extends 'Syntactic::Practice::Tree';
with 'Syntactic::Practice::Roles::Category::NonTerminal';

subtype NonTerminalTree => as 'Syntactic::Practice::Tree::NonTerminal';

__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Tree::Phrasal;

use Moose::Util::TypeConstraints;

use Moose;
use namespace::autoclean;

extends 'Syntactic::Practice::Tree::NonTerminal';
with 'Syntactic::Practice::Roles::Category::Terminal';

subtype PhrasalTree => as 'Syntactic::Practice::Tree::Phrasal';

__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Tree::Start;

use Moose::Util::TypeConstraints;

use Moose;
use namespace::autoclean;

extends 'Syntactic::Practice::Tree::NonTerminal';
with 'Syntactic::Practice::Roles::Category::Start';

subtype StartTree => as 'Syntactic::Practice::Tree::Start';

has mother => ( is      => 'ro',
                isa     => 'Undefined',
                lazy    => 1,
                builder => '_build_mother' );

sub _build_mother { undef }
sub _build_depth  { 0 }

__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Tree::Terminal;

use Moose::Util::TypeConstraints;

use Moose;
use namespace::autoclean;

extends 'Syntactic::Practice::Tree';
with 'Syntactic::Practice::Roles::Category::Terminal';

subtype TerminalTree => as 'Syntactic::Practice::Tree::Terminal';

sub _build_topos { $_[0]->frompos + 1 }

__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Tree::Lexical;

use Moose::Util::TypeConstraints;

use Moose;
use namespace::autoclean;

extends 'Syntactic::Practice::Tree::Terminal';
with 'Syntactic::Practice::Roles::Category::Terminal';

subtype LexicalTree => as 'Syntactic::Practice::Tree::Lexical';

has '+daughters' => ( is => 'ro',
                      isa => 'Syntactic::Practice::Lexicon::Lexeme',
                      required => 1
                    );

__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Tree::Null;

use Moose::Util::TypeConstraints;

use Moose;
use namespace::autoclean;

extends 'Syntactic::Practice::Tree::Terminal';
with 'Syntactic::Practice::Roles::Category::Terminal';

subtype NullTree => as 'Syntactic::Practice::Tree::Null';

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


package Syntactic::Practice::Tree::Abstract;

use Moose::Util::TypeConstraints;

use Moose;
use namespace::autoclean;

with 'Syntactic::Practice::Roles::Category';
extends 'Syntactic::Practice::Tree';

subtype AbstractTree => as 'Tree | Syntactic::Practice::Tree::Abstract';

has daughters => ( is       => 'rw',
                   isa      => 'ArrayRef[AbstractTree]',
                   required => 0, );

has mother => ( is       => 'rw',
                isa      => ( 'AbstractTree' ),
                required => 0 );

has sisters => ( is       => 'rw',
                 isa      => ( 'ArrayRef[AbstractTree]' ),
                 required => 0 );

has frompos => ( is       => 'rw',
                 isa      => ( 'PositiveInt' ),
                 required => 0 );

has '+prune_nulls' => ( is      => 'ro',
                        isa     => 'False',
                        default => 0 );

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

sub to_concrete {
  my ( $self, $arg ) = @_;

  my @concrete_daughters;
  unless ( $self->is_terminal ) {
    foreach my $daughter ( $self->daughters ) {
      push( @concrete_daughters, $daughter->to_concrete );
    }
  }

  $arg = {} unless $arg;
  my $abstract_class = ref $self;
  ( my $class = $abstract_class ) =~ s/Abstract:://;
  return $class->new( %$self, %$arg );
}

__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Tree::Abstract::NonTerminal;

use Moose::Util::TypeConstraints;

use Moose;

extends 'Syntactic::Practice::Tree::Abstract';
with 'Syntactic::Practice::Roles::Category::NonTerminal';

subtype 'NonTerminalAbstractTree', as 'NonTerminalTree | Syntactic::Practice::Tree::Abstract::NonTerminal';

no Moose;
__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Tree::Abstract::Phrasal;

use Moose::Util::TypeConstraints;

use Moose;

extends 'Syntactic::Practice::Tree::Abstract::NonTerminal';
with 'Syntactic::Practice::Roles::Category::Phrasal';

subtype 'PhrasalAbstractTree', as 'PhrasalTree | Syntactic::Practice::Tree::Abstract::Phrasal';

no Moose;

__PACKAGE__->meta->make_immutable;
package Syntactic::Practice::Tree::Abstract::Start;

use Moose::Util::TypeConstraints;

use Moose;

extends 'Syntactic::Practice::Tree::Abstract::NonTerminal';
with 'Syntactic::Practice::Roles::Category::Start';

subtype 'StartAbstractTree', as 'StartTree | Syntactic::Practice::Tree::Abstract::Start';

has mother => ( is      => 'ro',
                isa     => 'Undefined',
                lazy    => 1,
                builder => '_build_mother' );

sub _build_mother { undef }
sub _build_depth  { 0 }

no Moose;

__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Tree::Abstract::Terminal;

use Moose;

extends 'Syntactic::Practice::Tree::Abstract';
with 'Syntactic::Practice::Roles::Category::Terminal';

no Moose;
__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Tree::Abstract::Null;

use Moose::Util::TypeConstraints;

use Moose;

extends 'Syntactic::Practice::Tree::Abstract::Terminal';
with 'Syntactic::Practice::Roles::Category::Terminal';

subtype 'NullAbstractTree', as 'NullTree | Syntactic::Practice::Tree::Abstract::Null';

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

no Moose;

__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Tree::Abstract::Lexical;

use Moose::Util::TypeConstraints;

use Moose;

extends 'Syntactic::Practice::Tree::Abstract::Terminal';
with 'Syntactic::Practice::Roles::Category::Lexical';

subtype 'LexicalAbstractTree', as 'LexicalTree | Syntactic::Practice::Tree::Abstract::Lexical';

has '+daughters' => ( is => 'ro',
                      isa => 'Syntactic::Practice::Lexicon::Lexeme',
                      required => 1
                    );

no Moose;
__PACKAGE__->meta->make_immutable;
