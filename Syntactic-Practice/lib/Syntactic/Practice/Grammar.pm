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

my %rule;
my %category;

sub _init {
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
      Log::Log4perl->get_logger()->info( "Class for category with label [$label] is [$class]" );
    } else {
      my $msg = "Unknown syntactic category for label [$label]";
      Log::Log4perl->get_logger()->error( $msg );
      die $msg;
    }
    $category{$label} =
      $class->new( resultset => $cat_rs,
                   label     => $label, );
  }
}

method rule ( PhrasalCategoryLabel :$label ) {
  _init unless %rule;

  Log::Log4perl->get_logger()->info( "Request received for rule [$label]" );

  return $rule{$label} if exists $rule{$label};

  my $msg = "Unknown rule with label [$label]";
  Log::Log4perl->get_logger()->error( $msg );
  die $msg;

}

method category ( SyntacticCategoryLabel :$label ) {
  _init unless %category;

  Log::Log4perl->get_logger()->info( "Request received for category [$label]" );

  return $category{$label} if exists $category{$label};

  my $msg = "Unknown syntactic category with label [$label]";
  Log::Log4perl->get_logger()->error( $msg );
  die $msg;
}

__PACKAGE__->meta->make_immutable;
