package Syntactic::Practice::Lexicon;

use Syntactic::Practice::Util;
use Syntactic::Practice::Types;
use Syntactic::Practice::Lexicon::Lexeme;
use MooseX::Params::Validate;

use Moose;

has 'locale' => ( is      => 'ro',
                  isa     => 'Str',
                  default => 'en_US.UTF-8' );

sub lexeme {
  my ( $self, %opt ) =
    validated_hash( \@_, word => { isa => 'Word', optional => 0 }, );

  return Syntactic::Practice::Lexicon::Lexeme->new( word => $opt{word} );
}

around 'new' => sub {
  my ( $orig, $self, @arg ) = @_;

  my $obj = $self->$orig( @arg );

  $obj->{schema} = Syntactic::Practice::Util->new()->get_schema();
  $obj->{rs}     = $obj->{schema}->resultset( 'Lexeme' )
    ->search( {}, { prefetch => ['cat'] } );

  return $obj;
};

no Moose;
__PACKAGE__->meta->make_immutable( inline_constructor => 0 );
