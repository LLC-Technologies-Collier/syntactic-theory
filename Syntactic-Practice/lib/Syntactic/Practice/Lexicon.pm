package Syntactic::Practice::Lexicon;

use Syntactic::Practice::Lexicon::Lexeme;
use MooseX::Params::Validate;

use Moose;
use namespace::autoclean;

has 'locale' => ( is      => 'ro',
                  isa     => 'Str',
                  default => 'en_US.UTF-8' );

my $rs_namespace = Syntactic::Practice::Util->get_rs_namespace;
my $rs_class     = 'Lexeme';

my %lexeme;

sub lexeme {
  my ( $self, %opt ) =
    validated_hash( \@_, word => { isa => 'Word', optional => 0 }, );

  return $lexeme{ $opt{word} } if exists $lexeme{ $opt{word} };

  return $lexeme{ $opt{word} } =
    Syntactic::Practice::Lexicon::Lexeme->new( word => $opt{word} );
}

has 'resultset' => ( is        => 'ro',
                     isa       => $rs_namespace . '::' . $rs_class,
                     lazy      => 1,
                     init_arg  => undef,
                     builder   => '_build_resultset',
                     predicate => 'has_resultset', );

sub _build_resultset {
  my ( $self ) = @_;

  Syntactic::Practice::Util->get_schema->resultset( $rs_class )->search( {} );
}

__PACKAGE__->meta->make_immutable;
