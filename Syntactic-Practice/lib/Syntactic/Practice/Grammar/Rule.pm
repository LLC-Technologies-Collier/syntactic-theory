package Syntactic::Practice::Grammar::Rule;

=head1 NAME

Syntactic::Practice::Rule - Grammar Rule

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use Moose::Util::TypeConstraints;

use Moose;
use namespace::autoclean;

subtype Rule => as 'Syntactic::Practice::Grammar::Rule';

with 'Syntactic::Practice::Roles::Category';

my $rs_namespace = Syntactic::Practice::Util->get_rs_namespace();
my $rs_class     = 'Rule';

has 'resultset' => ( is       => 'ro',
                     isa      => 'Syntactic::Practice::Schema::Result::Rule',
                     lazy     => 1,
                     init_arg => undef,
                     builder  => '_build_resultset' );

has 'terms' => ( is       => 'ro',
                 isa      => "ArrayRef[Syntactic::Practice::Grammar::Term]",
                 lazy     => 1,
                 init_arg => undef,
                 builder  => '_build_terms' );

sub _build_resultset {
  my $label = $_[0]->category->label;
  Syntactic::Practice::Util->get_schema->resultset( $rs_class )->find(
                         { 'target.label' => $label },
                         {
                           prefetch => [ 'target',
                                         { 'terms' => { 'factors' => ['cat'] } }
                           ]
                         }
  ) or confess "No rule for category [$label]";

}

my $term_class   = 'Syntactic::Practice::Grammar::Term';
sub _build_terms {
  my ( $self ) = @_;
  my $rs = $self->resultset->terms;
  my @return;
  while ( my $resultset = $rs->next ) {
    push( @return,
          $term_class->new( label     => $self->label,
                            category  => $self->category,
                            resultset => $resultset
          ) );
  }
  return \@return;
}

__PACKAGE__->meta->make_immutable();
