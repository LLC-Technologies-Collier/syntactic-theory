package Syntactic::Practice::Lexicon::Lexeme;

use Moose;

use Syntactic::Practice::Util;

my $rs_namespace = Syntactic::Practice::Util->get_rs_namespace();

my $rs_class = 'Lexeme';

has 'word' => ( is      => 'ro',
                isa     => 'Word',
                lazy    => 1,
                builder => '_build_word', );

has 'resultset' => ( is      => 'ro',
                     isa     => $rs_namespace . '::' . $rs_class,
                     lazy    => 1,
                     builder => '_build_resultset' );

sub _build_word {
  my ( $self ) = @_;
  die 'Neither word nor resultset were specified for lexeme'
    unless ( exists $self->{resultset} );

  return $self->resultset->word;

}

sub _build_resultset {
  my ( $self ) = @_;
  die 'Neither resultset nor word were specified for lexeme'
    unless ( exists $self->{word} );

  return Syntactic::Practice::Util->get_schema->resultset( $rs_class )
    ->search( { word => $self->word } );
}

no Moose;
__PACKAGE__->meta->make_immutable( inline_constructor => 0 );
