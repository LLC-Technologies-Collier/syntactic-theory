package Syntactic::Practice::Grammar::Category;

=head1 NAME

Syntactic::Practice::Grammar::Category - Syntactic Category Representation

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use Moose;

with 'MooseX::Log::Log4perl';

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
__PACKAGE__->meta->make_immutable();
