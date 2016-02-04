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
use MooseX::Params::Validate;
use MooseX::Method::Signatures;


subtype Rule => as 'Syntactic::Practice::Grammar::Rule';

with 'Syntactic::Practice::Roles::Category';

my $rs_namespace = Syntactic::Practice::Util->get_rs_namespace();
my $rs_class     = 'Rule';

my $grammar;

has grammar => ( is       => 'ro',
                 isa      => 'Syntactic::Practice::Grammar',
                 lazy     => 1,
                 init_arg => undef,
                 builder  => '_build_grammar' );

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

my $term_class = 'Syntactic::Practice::Grammar::Term';

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


my %expansions;

sub BUILD {
  my ( $self ) = @_;
  $expansions{ $self->label } = { complete => 0,
                                  started  => 0,
                                  depends  => {},
                                  list     => [], };
}

method expansions ( PositiveInt :$depth ) {

  my $expansions = $expansions{ $self->label };

  return @{ $expansions->{list} } if $expansions->{complete};

  $expansions->{started} = 1;

  return [] unless ( $depth <= $self->max_depth );

  foreach my $term ( @{ $self->terms } ) {
    my $template = [];

    foreach my $factor ( @{ $term->factors } ) {
      if (    $factor->category->is_terminal
           || $factor->label eq $self->label )
      {
        push( @$template, $factor );
        next;
      } else {
        if ( $expansions{ $factor->label }->{complete}
             || !$expansions{ $factor->label }->{started} )
        {
          $expansions->{depends}->{ $factor->label }++;
          push( @$template,
                $grammar->rule( label => $factor->label )
                  ->expansions( depth => $depth + 1 ) );
        } else {
          $self->log->info(  'rule '
                           . $self->label
                           . ' blocked on completion of expansion list by rule '
                           . $factor->label );
        }
      }
    }

    my @interpolated;

    # TODO: interpolate template, store interpolated versions in @expansions

  }

  return @{ $expansions->{list} };
}

__PACKAGE__->meta->make_immutable();
