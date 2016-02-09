package Syntactic::Practice::Grammar::Term;

=head1 NAME

Syntactic::Practice::Term - Grammar Term

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use Moose;
use namespace::autoclean;
use MooseX::Method::Signatures;
use Moose::Util qw( apply_all_roles );

with 'Syntactic::Practice::Roles::Category';

my $grammar      = Syntactic::Practice::Grammar->new;
my $rs_namespace = Syntactic::Practice::Util->get_rs_namespace;
my $rs_class     = 'Term';

has 'factors' => ( is      => 'ro',
                   isa     => 'FactorList',
                   lazy    => 1,
                   builder => '_build_factors' );

has 'num_factors' => ( is      => 'ro',
                       isa     => 'PositiveInt',
                       lazy    => 1,
                       builder => '_build_num_factors' );

has resultset => ( is       => 'ro',
                   isa      => "${rs_namespace}::$rs_class",
                   required => 1 );

has id => ( is      => 'ro',
            isa     => 'PositiveInt',
            lazy    => 1,
            builder => '_build_id' );

has bnf => ( is       => 'ro',
             isa      => 'Str',
             lazy     => 1,
             init_arg => undef,
             builder  => '_build_bnf' );

has identifier => ( is       => 'ro',
                    isa      => 'Str',
                    lazy     => 1,
                    init_arg => undef,
                    builder  => '_build_identifier' );

has expression => ( is       => 'ro',
                    isa      => 'Str',
                    lazy     => 1,
                    init_arg => undef,
                    builder  => '_build_expression' );

sub _build_identifier { '<' . $_[0]->label . '>' }

sub _build_expression {
  my @factor;
  foreach my $factor ( @{ $_[0]->factors } ) {
    my $f = $factor->identifier;
    if ( $factor->repeat ) {
      $f = "{ $f }";
    } elsif ( $factor->optional ) {
      $f = "[ $f ]";
    }
    push( @factor, $f );
  }
  join( ' ', @factor );
}

sub _build_bnf {
  join( ' ::= ', $_[0]->identifier, $_[0]->expression );
}

sub _build_id {
  my ( $self ) = @_;
  $_[0]->resultset->id;
}

sub _build_label {
  $_[0]->resultset->rule->target->label;
}

sub _build_category {
  $grammar->category( label => $_[0]->label );
}

sub _build_num_factors { $_[0]->resultset->fact_count }

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

  if ( grep { $self->label eq $_ }
       Syntactic::Practice::Util->get_recursive_labels )
  {
    apply_all_roles( $self, 'Syntactic::Practice::Roles::Category::Recursive' );
  } else {
    apply_all_roles( $self,
                     'Syntactic::Practice::Roles::Category::NonRecursive' );
  }
  return $self;
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

sub as_string {
  my ( $self ) = @_;

  my $label = $self->label;
  my $str = "$label -> " . join( " ", map { $_->as_string } $self->factors );

  return $str;

}

__PACKAGE__->meta->make_immutable();
