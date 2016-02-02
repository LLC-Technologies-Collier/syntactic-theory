package Syntactic::Practice::Grammar::RuleSet;

use Syntactic::Practice::Util;
use Syntactic::Practice::Types;
use Syntactic::Practice::Grammar::Rule;

use Moose;

with 'Syntactic::Practice::Roles::Category';

my $rs_namespace = Syntactic::Practice::Util->get_rs_namespace();
my $rs_class     = 'PhraseStructureRule';
my $rule_class   = 'Syntactic::Practice::Grammar::Rule';

has 'resultset' => ( is       => 'ro',
                     isa      => 'DBIx::Class::ResultSet',
                     lazy     => 1,
                     init_arg => undef,
                     builder  => '_build_resultset' );

has 'rules' => ( is       => 'ro',
                 isa      => "ArrayRef[$rule_class]",
                 lazy     => 1,
                 init_arg => undef,
                 builder  => '_build_rules' );

sub _build_resultset {
  Syntactic::Practice::Util->get_schema->resultset( $rs_class )
    ->search( { 'target.label' => $_[0]->category->label },
              { prefetch => [ 'target', { 'symbols' => ['cat'] } ] } );
}

sub _build_rules {
  my ( $self ) = @_;
  my $rs = $self->resultset;
  my @return;
  while ( my $resultset = $rs->next ) {
    push( @return,
          $rule_class->new( label     => $self->label,
                            category  => $self->category,
                            resultset => $resultset
          ) );
  }
  return \@return;
}

no Moose;
__PACKAGE__->meta->make_immutable();
