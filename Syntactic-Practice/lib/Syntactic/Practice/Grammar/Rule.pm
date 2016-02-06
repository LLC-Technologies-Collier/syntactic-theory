package Syntactic::Practice::Grammar::Rule;

=head1 NAME

Syntactic::Practice::Rule - Grammar Rule

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use Moose;
use namespace::autoclean;
use MooseX::Method::Signatures;

with 'MooseX::Log::Log4perl';
with 'Syntactic::Practice::Roles::Category::NonTerminal';

my $rs_namespace = Syntactic::Practice::Util->get_rs_namespace();
my $rs_class     = 'Rule';

my $grammar;

has grammar => ( is       => 'ro',
                 isa      => 'Syntactic::Practice::Grammar',
                 lazy     => 1,
                 init_arg => undef,
                 builder  => '_build_grammar' );

has max_depth => ( is      => 'ro',
                   isa     => 'PositiveInt',
                   default => 5 );

has resultset => ( is       => 'ro',
                   isa      => 'Syntactic::Practice::Schema::Result::Rule',
                   lazy     => 1,
                   init_arg => undef,
                   builder  => '_build_resultset' );

has terms => ( is       => 'ro',
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

sub _build_grammar {
  return $grammar if $grammar;
  $grammar = Syntactic::Practice::Grammar->new( locale => 'en_US.UTF-8' );
}

sub _build_label {
  $_[0]->resultset->target->label;
}
sub _build_category {
  Syntactic::Practice::Grammar->new->category( label => $_[0]->label );
}

my $term_class = 'Syntactic::Practice::Grammar::Term';

sub _build_terms {
  my ( $self ) = @_;
  my $rs = $self->resultset->terms;
  my @return;
  while ( my $resultset = $rs->next ) {
    push( @return, $term_class->new( resultset => $resultset ) );
  }
  return \@return;
}

my %expansions;

sub BUILD {
  my ( $self ) = @_;
  $expansions{ $self->label } = { complete  => 0,
                                  started   => 0,
                                  compiled  => 0,
                                  depends   => {},
                                  list      => [],
                                  templates => undef, };

  return $self;
}

method templates () {
  my $ex = $expansions{ $self->label };
  return $ex->{templates} if defined $ex->{templates};

  my $interp = sub {
    my ( $template, $depth ) = @_;
    my @interp = ();
    return @interp unless $depth <= $self->max_depth;
    foreach my $element ( @{$template} ) {
      if ( blessed $element && $element->isa( 'Factor' ) ) {
        if ( $element->is_terminal ) {
          push( @interp, $element->label );
        }
        push( @interp, { label => $self->label } );
      } else {

  #        my $subtemplates = $self->grammar->rule( label => $element->{label} )
  #          ->templates();
  # TODO: do something with these.  Yow.
      }
    }
    return @interp;
  };

  my $templates = $ex->{templates} = [];
  foreach my $term ( @{ $self->terms } ) {
    push( @$templates, $interp->( $term->template, 0 ) );
  }
}

method expansions () {

  my $expansions = $expansions{ $self->label };

  return @{ $expansions->{list} } if $expansions->{complete};

  $expansions->{started} = 1;

  my @template;

  foreach my $templ ( $self->templates ) {

  }

  my @interpolated;

  # TODO: interpolate template, store interpolated versions in @expansions

  return @{ $expansions->{list} };
}

__PACKAGE__->meta->make_immutable();
