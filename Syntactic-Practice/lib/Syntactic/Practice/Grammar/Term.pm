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
use MooseX::Method::Signatures;

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
    $return[ $factor->position - 1 ] =
      $class->new( term => $self, label => $label );
  }

  return \@return;
}

my %templates;

sub BUILD {
  my ( $self ) = @_;
  $templates{ $self->resultset->id } = { complete => 0,
                                         list     => [], };
}

method template () {
  my $templ = $templates{ $self->resultset->id };
  return $templ->{list} if $templ->{complete};

  my $template = $templ->{list};

  foreach my $factor ( @{ $self->factors } ) {
    if ( $factor->category->is_terminal ) {
      push( @$template, $factor );
    } elsif ( $factor->label eq $self->label ) {
      push( @$template, $template );
    } else {
      push( @$template, { label => $factor->label } );
    }
  }
  $templ->{complete} = 1;

  return $template;
}

sub cmp {
  $_[0]->resultset->id <=> $_[1]->resultset->id;
}

my $rs_namespace = Syntactic::Practice::Util->get_rs_namespace;
my $rs_class     = 'Term';
has 'resultset' => ( is       => 'ro',
                     isa      => "${rs_namespace}::$rs_class",
                     required => 1 );

sub as_string {
  my ( $self ) = @_;

  my $label = $self->label;
  my $str = "$label -> " . join( " ", map { $_->as_string } $self->factors );

  return $str;

}

__PACKAGE__->meta->make_immutable();
