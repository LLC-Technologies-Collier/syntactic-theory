package Syntactic::Practice::Grammar::Symbol;

=head1 NAME

Syntactic::Practice::Grammar::Symbol - Symbols on the right hand side of rules

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use Syntactic::Practice::Util;
use Moose;

with 'Syntactic::Practice::Roles::Category';
with 'MooseX::Log::Log4perl';

my $rs_class = 'Symbol';
has 'resultset' => ( is       => 'ro',
                     isa      => "Syntactic::Practice::Schema::Result::$rs_class",
                     lazy     => 1,
                     init_arg => undef,
                     builder  => '_build_resultset' );

has 'rule' => ( is      => 'ro',
                isa     => 'Syntactic::Practice::Grammar::Rule',
                lazy    => 1,
                builder => '_build_rule' );

sub _build_resultset {
  my ( $self ) = @_;
  my $cond = {};
  die 'Rule was not specified for symbol [' . $self->label . ']'
    unless ( exists $self->{rule} );
  Syntactic::Practice::Util->get_schema->resultset( $rs_class )->search(
                          { rule  => $self->rule->resultset,
                            label => $self->label,
                          },
                          { prefetch => [ 'target', { 'symbols' => ['cat'] } ] }
  );
}

sub _build_rule {
  my( $self ) = @_;
  return $_[0]->resultset->rule;
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

has logger => ( is       => 'ro',
                isa      => 'Log::Log4perl::Logger',
                lazy     => 1,
                builder  => '_build_logger',
                init_arg => undef );

sub _build_logger {
  return Log::Log4perl->get_logger( 'grammar.symbol' );
}

no Moose;
__PACKAGE__->meta->make_immutable( inline_constructor => 0 );
