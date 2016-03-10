package Syntactic::Practice::Lexicon::Lexeme;

use Moose;
use namespace::autoclean;

with( 'Syntactic::Practice::Roles::Category::Lexical',
      'MooseX::Log::Log4perl' );

my $rs_namespace = Syntactic::Practice::Util->get_rs_namespace();

my $rs_class = 'Lexeme';

my $grammar = Syntactic::Practice::Grammar->new();

has 'word' => ( is      => 'ro',
                isa     => 'Word',
                lazy    => 1,
                builder => '_build_word', );

has 'resultset' => ( is      => 'ro',
                     isa     => $rs_namespace . '::' . $rs_class,
                     lazy    => 1,
                     builder => '_build_resultset' );

use overload
  q{""}    => sub { $_[0]->word },
  fallback => 1;

sub _build_word {
  my ( $self ) = @_;
  die 'Neither word nor resultset were specified for lexeme'
    unless ( exists $self->{resultset} );

  return $self->resultset->word;
}

sub _build_label { $_[0]->category->label }

sub _build_category {
  my $c = $grammar->category( label => $_[0]->resultset->cat->label );

  unless ( $c->isa( 'Syntactic::Practice::Grammar::Category::Lexical' ) ) {
    my $msg = 'Category for lexeme is not Lexical!';
    $_[0]->log->error( $msg );
    die $msg;
  }

  return $c;
}

sub _build_resultset {
  my ( $self ) = @_;
  die 'Neither resultset nor word were specified for lexeme'
    unless ( exists $self->{word} );

  return Syntactic::Practice::Util->get_schema->resultset( $rs_class )
    ->search( { word => $self->word } );
}

__PACKAGE__->meta->make_immutable;
