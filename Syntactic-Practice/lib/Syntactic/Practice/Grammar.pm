package Syntactic::Practice::Grammar;

=head1 NAME

Syntactic::Practice::Grammar - A natural language grammar

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use MooseX::Singleton;
use namespace::autoclean;
use MooseX::Method::Signatures;

with 'MooseX::Log::Log4perl';

has 'locale' => ( is      => 'ro',
                  isa     => 'Str',
                  default => 'en_US.UTF-8' );

has _rule => ( is      => 'ro',
               isa     => 'HashRef',
               lazy    => 1,
               builder => '_build_rule' );

has _cat => ( is      => 'ro',
              isa     => 'HashRef',
              lazy    => 1,
              builder => '_build_cat' );

sub _build_rule {
  my ( $self ) = @_;
  my %rule;

  foreach my $rule_rs (
       Syntactic::Practice::Util->get_schema->resultset( 'Rule' )
       ->search( {},
         { prefetch => [ 'target', { 'terms' => { 'factors' => ['cat'] } } ] } )
       ->search()->all )
  {
    my $class = 'Syntactic::Practice::Grammar::Rule';
    my $label = $rule_rs->target->label;
    $rule{$label} =
      $class->new( resultset => $rule_rs,
                   label     => $label, );
  }
  return \%rule;
}

sub _build_cat {
  my ( $self ) = @_;
  my %category;
  foreach my $cat_rs (
         Syntactic::Practice::Util->get_schema->resultset( 'SyntacticCategory' )
         ->search()->all )
  {
    my $class = 'Syntactic::Practice::Grammar::Category';
    my $label = $cat_rs->label;
    if ( $label eq 'S' ) {
      $class = join( '::', $class, 'Start' );
    } elsif (    $cat_rs->ctype eq 'lexical'
              || $cat_rs->ctype eq 'phrasal' )
    {
      $class = join( '::', $class, ucfirst $cat_rs->ctype );
    } else {
      my $msg = "Unknown syntactic category for label [$label]";
      $self->log->error( $msg );
      die $msg;
    }
    $category{$label} =
      $class->new( resultset => $cat_rs,
                   label     => $label, );
  }
  return \%category;
}

method rule ( PhrasalCategoryLabel :$label ) {
  my $rule = $self->_rule;
  return $rule->{$label} if exists $rule->{$label};

  my $msg = "Unknown rule with label [$label]";
  $self->log->error( $msg );
  die $msg;

}

method category ( SyntacticCategoryLabel :$label ) {
  my $category = $self->_cat;
  return $category->{$label} if exists $category->{$label};

  my $msg = "Unknown syntactic category with label [$label]";
  $self->log->error( $msg );
  die $msg;
}

__PACKAGE__->meta->make_immutable;
