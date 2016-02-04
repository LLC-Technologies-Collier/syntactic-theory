package Syntactic::Practice::Grammar::Term;

=head1 NAME

Syntactic::Practice::Term - Grammar Term

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use Moose::Util::TypeConstraints;

use Moose;
use namespace::autoclean;

subtype Term => as 'Syntactic::Practice::Grammar::Term';

with 'Syntactic::Practice::Roles::Category';

has 'factors' => ( is      => 'ro',
                   isa     => 'FactorList',
                   lazy    => 1,
                   builder => '_build_factors' );

sub _build_factors {
  my ( $self ) = @_;
  my @return;
  my $rs = $self->resultset->factors;
  while ( my $factor = $rs->next ) {
    my $class = 'Syntactic::Practice::Grammar::Factor';
    my $label = $factor->cat->label;
    if ( $label eq 'S' ) {
      $class .= '::Start';
    } else {
      $class .= '::' . ucfirst $factor->cat->ctype;
    }
    $return[ $factor->position - 1 ] =
      $class->new( term => $self, label => $label );
  }

  return \@return;
}

sub cmp {
  $_[0]->resultset->id <=> $_[1]->resultset->id
};

my $rs_namespace = Syntactic::Practice::Util->get_rs_namespace;
my $rs_class = 'Term';
has 'resultset' => ( is   => 'ro',
                     isa  => "${rs_namespace}::$rs_class",
                     required => 1 );

sub as_string {
  my ( $self ) = @_;

  my $label = $self->label;
  my $str = "$label -> " . join( " ", map { $_->as_string } $self->factors );

  return $str;

}

__PACKAGE__->meta->make_immutable();
