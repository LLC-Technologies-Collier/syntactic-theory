package Syntactic::Practice::Grammar::Factor;

=head1 NAME

Syntactic::Practice::Grammar::Factor - Factors on the right hand side of Terms

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use Moose;
use namespace::autoclean;

with 'Syntactic::Practice::Roles::Category';
with 'MooseX::Log::Log4perl';

my $rs_class = 'Factor';
has resultset => ( is      => 'ro',
                   isa     => "Syntactic::Practice::Schema::Result::$rs_class",
                   lazy    => 1,
                   builder => '_build_resultset' );

has term => ( is      => 'ro',
              isa     => 'Syntactic::Practice::Grammar::Term',
              lazy    => 1,
              builder => '_build_term' );

sub _build_resultset {
  my ( $self ) = @_;
  my $cond = {};
  die 'Term was not specified for factor [' . $self->label . ']'
    unless ( exists $self->{term} );
  Syntactic::Practice::Util->get_schema->resultset( $rs_class )->find(
                                      { 'term.id' => $self->term->resultset->id,
                                        'cat.label' => $self->label,
                                      },
                                      { prefetch => [ 'term', 'cat' ] } );
}

sub _build_term {
  my ( $self ) = @_;
  return
    Syntactic::Practice::Grammar::Term->new(resultset => $_[0]->resultset->term,
                                            label     => $self->label, );
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

package Syntactic::Practice::Grammar::Factor::NonTerminal;

use Moose;
use namespace::autoclean;

extends 'Syntactic::Practice::Grammar::Factor';
with 'Syntactic::Practice::Roles::Category::NonTerminal';

__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Grammar::Factor::Phrasal;

use Moose;
use namespace::autoclean;

extends 'Syntactic::Practice::Grammar::Factor::NonTerminal';
with 'Syntactic::Practice::Roles::Category::Phrasal';

__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Grammar::Factor::Terminal;

use Moose;
use namespace::autoclean;

extends 'Syntactic::Practice::Grammar::Factor';
with 'Syntactic::Practice::Roles::Category::Terminal';

__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Grammar::Factor::Lexical;

use Moose;
use namespace::autoclean;

extends 'Syntactic::Practice::Grammar::Factor::Terminal';
with 'Syntactic::Practice::Roles::Category::Lexical';

__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Grammar::Factor::Literal;

use Moose;
use namespace::autoclean;

extends 'Syntactic::Practice::Grammar::Factor::Terminal';

has '+label' => ( is       => 'ro',
                  isa      => 'Str',
                  required => 1 );

sub as_string {
  my ( $self ) = @_;

  my $str = $self->label;

  return qq{"$str"};
}

__PACKAGE__->meta->make_immutable();
