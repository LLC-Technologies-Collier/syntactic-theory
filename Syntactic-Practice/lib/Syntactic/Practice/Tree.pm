package Syntactic::Practice::Tree;

=head1 NAME

Syntactic::Practice::Tree - Parse Tree Representation

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use Data::GUID;

use Moose;
use namespace::autoclean;
use MooseX::Method::Signatures;

with( 'Syntactic::Practice::Roles::Category',
      'Syntactic::Practice::Roles::Unique',
      'MooseX::Log::Log4perl' );

my $grammar = Syntactic::Practice::Grammar->new();

has topos => ( is       => 'ro',
               isa      => 'PositiveInt',
               lazy     => 1,
               builder  => '_build_topos',
               init_arg => undef );

has name => ( is       => 'ro',
              isa      => 'Str',
              lazy     => 1,
              builder  => '_build_name',
              init_arg => undef );

has string => ( is       => 'ro',
                isa      => 'Str',
                lazy     => 1,
                builder  => '_build_string',
                init_arg => undef );

has depth => ( is       => 'ro',
               isa      => 'PositiveInt',
               lazy     => 1,
               builder  => '_build_depth',
               init_arg => undef, );

has sentence => ( is       => 'ro',
                  isa      => 'ArrayRef[Tree]',
                  required => 1 );

sub copy {
  my ( $self, %attr ) = @_;
  my %arg = ( %$self );
  map { delete $arg{$_} } ( qw( mother daughters sisters guid string name ) );
  %attr = ( %arg, %attr );

  $attr{daughters} = [ map { ref $_ ? $_->copy : $_ } $self->daughters ]
    unless exists $attr{daughters};

  return $self->new( %attr );
}

use overload
  q{""} => sub { $_[0]->string },
  '<=>' => sub { ( $_[2] ? -1 : 1 ) * $_[0]->cmp( $_[1] ) },
  fallback => 1;

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

  return $self->mother->sentence
    if exists $self->{mother} && defined $self->{mother};
  foreach my $family ( qw( siblings daughters ) ) {
    $self->log->debug( "Checkin $family for tree..." );
    return $self->{$family}->[0]->sentence
      if exists $self->{$family} && scalar @{ $self->{$family} };
  }
  confess 'Cannot determine sentence';
}

sub _build_depth { $_[0]->mother->depth + 1 }

sub _build_sisters {
  my ( $self ) = @_;
  if ( $self->mother ) {
    return [ grep { $_[0]->cmp( $_ ) != 0 } $_[0]->mother->daughters ];
  }
  confess 'neither mother nor sisters were specified';
}

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

  $self->log->info( 'tree has been built.  Now registering' );
  $self->_registerTree();

  return $self;
}

sub cmp {
  my ( $self, $other ) = @_;

  return undef unless defined $other;

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

  return 0 unless $other->can( '_guid' );

  return $self->_guid cmp $other->_guid;
}

sub as_forest {
  my ( $self ) = @_;

  my $indent = ' ' x ( $self->depth * 2 );

  my $output   = '';
  my @daughter = $self->daughters;

  $output .= "${indent}[" . $self->label . "\n${indent}";
  if ( $self->category->is_terminal ) {
    $output .= '[' . $daughter[0]->word . '] ';
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

  my @daughter = map { $_ // '(null)' } ( $self->daughters );
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

  my $c_daughters;
  if ( $self->is_terminal ) {
    $c_daughters = $self->daughters;
  } else {
    $c_daughters = [ map { $_->to_concrete } $self->daughters ];
  }

  ( my $class = ref $self ) =~ ( s/Abstract::/Concrete::/ );

  return
    $class->new( category  => $self->category,
                 mother    => $self->mother,
                 sisters   => $self->sisters,
                 daughters => $c_daughters,
                 depth     => $self->depth,
                 frompos   => $self->frompos,
                 topos     => $self->topos,
                 label     => $self->label,
                 factor    => $self->factor,
                 sentence  => $self->sentence,
                 %$arg );
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

sub BUILD {
  my ( $self ) = @_;

  my $rule = $grammar->rule( label => $self->label );

  my @possible_factors;
  my @possible_term;
  my @daughter_labels = map { $_->label } $self->daughters;
  foreach my $term ( @{ $rule->terms } ) {
    $self->log->debug(
       qq{Now testing whether term [$term] licenses daughters[@daughter_labels]}
    );
    my $factors_match = 1;
    my $cursor        = $self->constituents->first;
    my @factor_list;
    foreach my $factor ( @{ $term->factors } ) {
      my $cursor_label = defined $cursor ? $cursor->label : '(undefined)';
      my $factor_label = $factor->label;
      if ( $factor->label ne $cursor_label ) {
        next if $factor->optional;
        $self->log->debug(
qq{Constituent [$cursor] has label [$cursor_label] which does not match [$factor_label]}
        );
        $factors_match = 0;
        last;
      }
      $self->log->debug(
qq{Constituent [$cursor] has label [$cursor_label], matching [$factor_label]} );
      push( @factor_list, $factor );
      $cursor = $cursor->next;
      next unless $factor->repeat;
      while ( defined $cursor
              && $cursor->label eq $factor->label )
      {
        push( @factor_list, $factor );
        $cursor = $cursor->next;
      }
    }
    unless ( $factors_match ) {
      $self->log->debug(
qq{Daughter(s) [@daughter_labels] could not have been licensed by term [$term]} );
      next;
    }
    $self->log->debug(
       qq{Daughter(s) [@daughter_labels] could have been licensed by term [$term]} );

    push( @possible_factors, \@factor_list );
    push( @possible_term,    $term );
  }

  die
    qq{Rule [$rule] cannot license daughter(s) with label(s) [@daughter_labels]}
    unless scalar @possible_term > 0;

  $self->log->info(
       qq{Daughter(s) [@daughter_labels] could have been licensed by rule [$rule]} );

  if ( @possible_term > 1 ) {
    $self->log->info(
                 'These daughters could have been licensed by multiple terms' );
  }

  my @factor_list = @{ shift( @possible_factors ) };
  foreach my $daughter ( $self->daughters ) {
    $daughter->mother( $self );
    my $factor = shift( @factor_list );
    $daughter->factor( $factor ) unless defined $daughter->factor;
  }
}

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

sub copy {
  my ( $self, %attr ) = @_;
  my %arg = ( %$self );
  map { delete $arg{$_} } ( qw( mother sisters guid string name ) );
  %attr = ( %arg, %attr );

  return $self->new( %attr );
}

__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Tree::Lexical;

use Moose;
use namespace::autoclean;

extends 'Syntactic::Practice::Tree::Terminal';
with 'Syntactic::Practice::Roles::Category::Terminal';

__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Tree::Null;

use Moose;
use namespace::autoclean;

extends 'Syntactic::Practice::Tree::Terminal';
with 'Syntactic::Practice::Roles::Category::Terminal';

sub _build_string    { '' }
sub _build_daughters { undef }
sub _build_topos     { $_[0]->frompos }
sub _build_name      { $_[0]->label . '0' }

__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Tree::Abstract;

use Moose;
use namespace::autoclean;

with( 'Syntactic::Practice::Roles::Category', 'MooseX::Log::Log4perl' );

extends 'Syntactic::Practice::Tree';

has frompos => ( is      => 'rw',
                 isa     => 'PositiveInt',
                 lazy    => 1,
                 builder => '_build_frompos', );

has sentence => ( is       => 'rw',
                  isa      => 'ArrayRef[Tree]',
                  required => 1 );

has sisters => ( is      => 'rw',
                 isa     => 'ArrayRef[Tree]',
                 lazy    => 1,
                 builder => '_build_sisters', );

has constituents => ( is      => 'ro',
                      isa     => 'TokenSet',
                      lazy    => 1,
                      builder => '_build_constituents', );

has daughters => ( is      => 'rw',
                   isa     => 'ArrayRef[Tree]',
                   lazy    => 1,
                   builder => '_build_daughters', );

has mother => ( is  => 'rw',
                isa => 'Maybe[Tree]' );

has prune_nulls => ( is      => 'ro',
                     isa     => 'False',
                     default => 0 );

has factor => ( is  => 'rw',
                isa => 'Maybe[Factor]' );

sub _build_frompos { 0 }

around daughters => sub {
  my ( $orig, $self ) = @_;

  return $self->{daughters} if $self->is_terminal;

  return @{ $self->{daughters} };
};

#method _build_depth { exists $self->{mother} ? $self->{mother}->depth + 1 : 0 };
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
extends( 'Syntactic::Practice::Tree::Abstract',
         'Syntactic::Practice::Tree::NonTerminal' );

__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Tree::Abstract::Phrasal;

use Moose;
use namespace::autoclean;

extends( 'Syntactic::Practice::Tree::Abstract::NonTerminal',
         'Syntactic::Practice::Tree::Phrasal' );
with 'Syntactic::Practice::Roles::Category::Phrasal';

__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Tree::Abstract::Start;

use Moose;
use namespace::autoclean;

extends( 'Syntactic::Practice::Tree::Abstract::NonTerminal',
         'Syntactic::Practice::Tree::Start' );
with 'Syntactic::Practice::Roles::Category::Start';

has mother => ( is      => 'ro',
                isa     => 'Undefined',
                lazy    => 1,
                builder => '_build_undef' );
has sisters => ( is      => 'ro',
                 isa     => 'Undefined',
                 lazy    => 1,
                 builder => '_build_undef' );

sub _build_undef { undef }
sub _build_depth { 0 }

__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Tree::Abstract::Terminal;

use Moose;
use namespace::autoclean;

extends( 'Syntactic::Practice::Tree::Terminal',
         'Syntactic::Practice::Tree::Abstract' );
with 'Syntactic::Practice::Roles::Category::Terminal';

has '+daughters' => ( is       => 'rw',
                      isa      => 'Syntactic::Practice::Lexicon::Lexeme',
                      required => 1 );

__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Tree::Abstract::Null;

use Moose;
use namespace::autoclean;

extends( 'Syntactic::Practice::Tree::Abstract::Terminal',
         'Syntactic::Practice::Tree::Null' );
with 'Syntactic::Practice::Roles::Category::Terminal';

has '+label'     => ( isa => 'SyntacticCategoryLabel' );
has '+category'  => ( isa => 'Syntactic::Practice::Grammar::Category' );
has '+daughters' => ( isa => 'Undefined' );

sub _build_daughters { undef }
sub _build_topos     { $_[0]->frompos }
sub _build_name      { $_[0]->label . '0' }
sub _build_string    { '(undef)' }

__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Tree::Abstract::Lexical;

use Moose;
use namespace::autoclean;
extends( 'Syntactic::Practice::Tree::Abstract::Terminal',
         'Syntactic::Practice::Tree::Lexical' );
with 'Syntactic::Practice::Roles::Category::Lexical';

has '+daughters' => ( is       => 'ro',
                      isa      => 'Syntactic::Practice::Lexicon::Lexeme',
                      required => 1 );

sub _build_daughters { $_[0]->sentence->[ $_[0]->frompos ]->daughters }
sub _build_string    { $_[0]->daughters->word }

__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Tree::Concrete;

use Moose;
use namespace::autoclean;

extends 'Syntactic::Practice::Tree';

with( 'Syntactic::Practice::Roles::Category', 'MooseX::Log::Log4perl' );

has daughters => ( is       => 'ro',
                   isa      => 'ArrayRef[ConcreteTree]',
                   required => 1, );

has mother => ( is       => 'ro',
                isa      => 'Tree',
                required => 1 );

has sentence => ( is       => 'ro',
                  isa      => 'ArrayRef[Tree]',
                  required => 1, );

has constituents => ( is      => 'ro',
                      isa     => 'TokenSet',
                      lazy    => 1,
                      builder => '_build_constituents', );

has sisters => ( is       => 'ro',
                 isa      => ( 'Maybe[ArrayRef[Tree]]' ),
                 required => 1 );

has frompos => ( is       => 'ro',
                 isa      => ( 'PositiveInt' ),
                 required => 1 );

has factor => ( is       => 'ro',
                isa      => 'Factor',
                required => 1, );

has prune_nulls => ( is      => 'ro',
                     isa     => 'Bool',
                     default => 1 );

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

#method _build_depth { exists $self->{mother} ? $self->{mother}->depth + 1 : 0 };

my %concreteTreeByName;
my %concreteTreeByLabel;

sub _treeExists {
  my ( $self, $arg ) = @_;

  #method _treeExists ( HashRef $arg ) {
  return $concreteTreeByName{ $arg->{name} }
    if ( exists $concreteTreeByName{ $arg->{name} } );
  return 0;
}

sub _registerTree {
  my ( $self ) = @_;

  warn ref $self unless $self->label;
  $concreteTreeByLabel{ $self->label } = []
    unless exists $concreteTreeByLabel{ $self->label };
  push( @{ $concreteTreeByLabel{ $self->label } },
        $concreteTreeByName{ $self->name } = $self );
}

sub _numTrees {
  my ( $self, $arg ) = @_;
  $concreteTreeByLabel{ $arg->{label} } = []
    unless exists $concreteTreeByLabel{ $arg->{label} };
  return scalar @{ $concreteTreeByLabel{ $arg->{label} } };
}

__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Tree::Concrete::NonTerminal;

use Moose;
use namespace::autoclean;

extends( 'Syntactic::Practice::Tree::Concrete',
         'Syntactic::Practice::Tree::NonTerminal' );
with 'Syntactic::Practice::Roles::Category::NonTerminal';

__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Tree::Concrete::Phrasal;

use Moose;
use namespace::autoclean;

extends( 'Syntactic::Practice::Tree::Concrete::NonTerminal',
         'Syntactic::Practice::Tree::Phrasal' );
with 'Syntactic::Practice::Roles::Category::Phrasal';

__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Tree::Concrete::Start;

use Moose;
use namespace::autoclean;

extends( 'Syntactic::Practice::Tree::Concrete::NonTerminal',
         'Syntactic::Practice::Tree::Start' );
with 'Syntactic::Practice::Roles::Category::Start';

has mother => ( is      => 'ro',
                isa     => 'Undefined',
                lazy    => 1,
                builder => '_build_undef' );

has factor => ( is      => 'ro',
                isa     => 'Undefined',
                lazy    => 1,
                builder => '_build_undef' );

has sisters => ( is      => 'ro',
                 isa     => 'Undefined',
                 lazy    => 1,
                 builder => '_build_undef' );

sub _build_undef { undef }
sub _build_depth { 0 }

__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Tree::Concrete::Terminal;

use Moose;
use namespace::autoclean;

extends( 'Syntactic::Practice::Tree::Terminal',
         'Syntactic::Practice::Tree::Concrete' );
with 'Syntactic::Practice::Roles::Category::Terminal';

has '+daughters' => ( is       => 'ro',
                      isa      => 'Syntactic::Practice::Lexicon::Lexeme',
                      required => 1 );

__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Tree::Concrete::Null;

use Moose;
use namespace::autoclean;

extends( 'Syntactic::Practice::Tree::Concrete::Terminal',
         'Syntactic::Practice::Tree::Null' );
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

package Syntactic::Practice::Tree::Concrete::Lexical;

use Moose;
use namespace::autoclean;
extends( 'Syntactic::Practice::Tree::Concrete::Terminal',
         'Syntactic::Practice::Tree::Lexical' );
with 'Syntactic::Practice::Roles::Category::Lexical';

has '+daughters' => ( is       => 'ro',
                      isa      => 'Syntactic::Practice::Lexicon::Lexeme',
                      required => 1 );

sub _build_string { $_[0]->daughters->word }

sub BUILD {
  my ( $self ) = @_;

  foreach my $daughter ( $self->daughters ) {
    $self->log->debug( "daughter value is [$daughter]" );
  }
}

__PACKAGE__->meta->make_immutable;
