package Syntactic::Practice::Grammar::Rule;

use Syntactic::Practice::Util;
use Syntactic::Practice::Types;

use Moose;

has 'identifier' => ( is       => 'ro',
                      isa      => 'SyntacticCategoryLabel',
                      required => 1 );

has 'symbols' => ( is       => 'ro',
                   isa      => 'SymbolList',
                   required => 1,
                 );

around 'symbols' => sub {
  my ( $orig, $self ) = @_;

  return
    ref $self->{symbols}
    ? @{ $self->{symbols} }
    : ( $self->{symbols} );

};

sub as_string {
  my ( $self ) = @_;

  my $identifier = $self->identifier;
  my $str =
    "$identifier -> " . join( " ", map { $_->as_string } $self->symbols );

  return $str;

}

no Moose;
__PACKAGE__->meta->make_immutable();
