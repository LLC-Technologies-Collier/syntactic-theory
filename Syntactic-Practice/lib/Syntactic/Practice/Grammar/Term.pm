package Syntactic::Practice::Grammar::Term;

use Moose;

with 'Syntactic::Practice::Roles::Category';

has 'factors' => ( is      => 'ro',
                   isa     => 'FactorList',
                   lazy    => 1,
                   builder => '_build_factors' );

sub _build_factors {
  my ( $self ) = @_;
  my @return;
  my $factors = $self->resultset->factors;
  while ( my $sym = $factors->next ) {
    my $class = 'Syntactic::Practice::Grammar::Factor';
    my $label = $sym->cat->label;
    if ( $label eq 'S' ) {
      $class .= '::Start';
    } else {
      $class .= '::' . ucfirst $sym->cat->ctype;
    }
    $return[ $sym->position - 1 ] =
      $class->new( term => $self, label => $label );
  }

  return \@return;
}

sub cmp {
  $_[0]->resultset->id <=> $_[1]->resultset->id
};

my $rs_namespace = Syntactic::Practice::Util->get_rs_namespace;
my $rs_class = 'PhraseStructureRule';
has 'resultset' => ( is   => 'ro',
                     isa  => "${rs_namespace}::$rs_class",
                     required => 1 );

sub as_string {
  my ( $self ) = @_;

  my $label = $self->label;
  my $str = "$label -> " . join( " ", map { $_->as_string } $self->factors );

  return $str;

}

no Moose;
__PACKAGE__->meta->make_immutable();
