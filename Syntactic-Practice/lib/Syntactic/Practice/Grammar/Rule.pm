package Syntactic::Practice::Grammar::Rule;

=head1 NAME

Syntactic::Practice::Rule - Grammar rule

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use Moose;

with 'Syntactic::Practice::Roles::Category';

has 'symbols' => ( is      => 'ro',
                   isa     => 'SymbolList',
                   lazy    => 1,
                   builder => '_build_symbols' );

sub _build_symbols {
  my ( $self ) = @_;
  my @return;
  my $symbols = $self->resultset->symbols;
  while ( my $sym = $symbols->next ) {
    my $class = 'Syntactic::Practice::Grammar::Symbol';
    my $label = $sym->cat->label;
    if ( $label eq 'S' ) {
      $class .= '::Start';
    } else {
      $class .= '::' . ucfirst $sym->cat->ctype;
    }
    $return[ $sym->position - 1 ] =
      $class->new( rule => $self, label => $label );
  }

  return \@return;
}

sub cmp {
  $_[0]->resultset->id <=> $_[1]->resultset->id
};

my $rs_class = 'PhraseStructureRule';
has 'resultset' => ( is   => 'ro',
                     isa  => "Syntactic::Practice::Schema::Result::$rs_class",
                     required => 1 );

sub as_string {
  my ( $self ) = @_;

  my $label = $self->label;
  my $str = "$label -> " . join( " ", map { $_->as_string } $self->symbols );

  return $str;

}

no Moose;
__PACKAGE__->meta->make_immutable();
