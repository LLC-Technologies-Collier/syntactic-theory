package Syntactic::Practice::Grammar::Symbol;

=head1 NAME

Syntactic::Practice::Grammar::Symbol - Symbols on the right hand side of terms

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use Moose::Util::TypeConstraints;

use Moose;
use namespace::autoclean;

subtype Symbol => as 'Syntactic::Practice::Grammar::Symbol';

with 'Syntactic::Practice::Roles::Category';
with 'MooseX::Log::Log4perl';

my $rs_class = 'Symbol';
has 'resultset' => ( is       => 'ro',
                     isa      => "Syntactic::Practice::Schema::Result::$rs_class",
                     lazy     => 1,
                     init_arg => undef,
                     builder  => '_build_resultset' );

has 'term' => ( is      => 'ro',
                isa     => 'Syntactic::Practice::Grammar::Term',
                lazy    => 1,
                builder => '_build_term' );

sub _build_resultset {
  my ( $self ) = @_;
  my $cond = {};
  die 'Term was not specified for symbol [' . $self->label . ']'
    unless ( exists $self->{term} );
  Syntactic::Practice::Util->get_schema->resultset( $rs_class )->find(
                          { 'term.id'  => $self->term->resultset->id,
                            'cat.label' => $self->label,
                          },
                          { prefetch => [ 'term', 'cat' ] }
  );
}

sub _build_term {
  my( $self ) = @_;
  return $_[0]->resultset->term;
}

sub repeat {
  return $_[0]->resultset->rpt;
}

sub optional {
  return $_[0]->resultset->optional;
}

sub position {
  return $_[0]->resultset->position;
}

sub as_string {
  my ( $self ) = @_;

  my $str = $self->label;
  $str = ( $self->optional ? "[$str]" : "<$str>" );
  $str .= '+' if $self->repeat;

  return $str;
}

__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Grammar::Symbol::NonTerminal;

use Moose::Util::TypeConstraints;

use Moose;
use namespace::autoclean;

subtype NonTerminalSymbol => as 'Syntactic::Practice::Grammar::Symbol::NonTerminal';

extends 'Syntactic::Practice::Grammar::Symbol';
with 'Syntactic::Practice::Roles::Category::NonTerminal';

__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Grammar::Symbol::Phrasal;

use Moose::Util::TypeConstraints;

use Moose;
use namespace::autoclean;

subtype PhrasalSymbol => as 'Syntactic::Practice::Grammar::Symbol::Phrasal';

extends 'Syntactic::Practice::Grammar::Symbol::NonTerminal';
with 'Syntactic::Practice::Roles::Category::Phrasal';

__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Grammar::Symbol::Terminal;

use Moose::Util::TypeConstraints;

use Moose;
use namespace::autoclean;

subtype TerminalSymbol => as 'Syntactic::Practice::Grammar::Symbol::Terminal';

extends 'Syntactic::Practice::Grammar::Symbol';
with 'Syntactic::Practice::Roles::Category::Terminal';

__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Grammar::Symbol::Lexical;

use Moose::Util::TypeConstraints;

use Moose;
use namespace::autoclean;

subtype LexicalSymbol => as 'Syntactic::Practice::Grammar::Symbol::Lexical';

extends 'Syntactic::Practice::Grammar::Symbol::Terminal';
with 'Syntactic::Practice::Roles::Category::Lexical';

__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Grammar::Symbol::Literal;

use Moose::Util::TypeConstraints;

use Moose;
use namespace::autoclean;

subtype LiteralSymbol => as 'Syntactic::Practice::Grammar::Symbol::Literal';

extends 'Syntactic::Practice::Grammar::Symbol::Terminal';

has '+label' => ( is       => 'ro',
                  isa      => 'Str',
                  required => 1 );

sub as_string {
  my ( $self ) = @_;

  my $str = $self->label;

  return qq{"$str"};
}

__PACKAGE__->meta->make_immutable();
