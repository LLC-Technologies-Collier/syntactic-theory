package Syntactic::Practice::Lexicon::Homograph;

use Moose;

use Syntactic::Practice::Util;

my $rs_namespace = Syntactic::Practice::Util->get_rs_namespace();

my $rs_class     = 'Lexeme';
my $lexeme_class = 'Syntactic::Practice::Lexicon::Lexeme';

has 'word' => ( is       => 'ro',
                isa      => 'Word',
                required => 1, );

has 'lexemes' => ( is      => 'ro',
                   isa     => "ArrayRef[$lexeme_class]",
                   lazy    => 1,
                   builder => '_build_lexemes' );

has 'resultset' => ( is      => 'ro',
                     isa     => 'DBIx::Class::ResultSet',
                     lazy    => 1,
                     builder => '_build_resultset' );

sub _build_lexemes {
  return [ map { $lexeme_class->new( resultset => $_ ) }
           $_[0]->resultset->all() ];
}

sub _build_resultset {
  my ( $self ) = @_;
  die 'Word was not specified for lexeme'
    unless ( exists $self->{word} );

  Syntactic::Practice::Util->get_schema->resultset( $rs_class )
    ->search( { word => $self->word } );
}

no Moose;
__PACKAGE__->meta->make_immutable( inline_constructor => 0 );
