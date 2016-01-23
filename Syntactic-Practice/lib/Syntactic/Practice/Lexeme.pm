package Syntactic::Practice::Lexeme;

use Carp;
use Syntactic::Practice::Util;
use Syntactic::Practice::Constituent;
use Syntactic::Practice::Types;
use Moose;

extends 'Syntactic::Practice::Constituent';

has word => ( is       => 'ro',
              isa      => 'Word',
              required => 0 );

has '+decomposition' => ( is  => 'ro',
                          isa => 'ArrayRef[Word]',
                          );

has '+sentence' => ( is       => 'ro',
                     isa      => 'ArrayRef[Word]',
                     required => 1 );

my $schema = Syntactic::Practice::Util->new()->get_schema();

around 'new' => sub {
  my ( $orig, $self, @arg ) = @_;

  my $arg;
  if ( scalar @arg == 1 && ref $arg[0] eq 'HASH' ) {
    $arg = $arg[0];
  } else {
    $arg = {@arg};
  }

  $arg->{topos} = $arg->{frompos} + 1 unless exists $arg->{topos};

  print STDERR ("[$arg->{frompos}] .. [$arg->{topos}]\n");

  $arg->{decomposition} = [(@{$arg->{sentence}})[ $arg->{frompos} .. ($arg->{topos} - 1) ]]
    unless exists $arg->{decomposition};

  if( exists $arg->{word} ){
    confess "word should not be a reference" if ref $arg->{word};
  }else{
    my $num_decomp = scalar @{ $arg->{decomposition} };
    if( $num_decomp == 1 ){
      $arg->{word} = $arg->{decomposition}->[0];
    }elsif( $num_decomp > 1 ){
      warn ("More than one word in decomposition for lexeme: [@{$arg->{decomposition}}]]");
      $arg->{word} = $arg->{decomposition}->[0];
    }elsif( $num_decomp == 0 ){
      confess("No word specified and empty decomposition list!");
    }
  }

  my $cond = { 'LOWER(me.word)' => { 'LIKE' => lc( $arg->{word} ) } };
  $cond->{'cat.label'} = $arg->{label} if exists $arg->{label};

  my $rs =
    $schema->resultset( 'Lexeme' )->search( $cond, { prefetch => ['cat'] } );

  my @lexeme = $rs->all();

  my $count = scalar @lexeme;
  my $label = exists $arg->{label} ? $arg->{label} : 'unknown';
  if ( $count == 0 ) {
    return { error => "unknown word: [$arg->{word}] with label [$label]" };

    # TODO: prompt for definition
  } elsif ( $count > 1 ) {
    die "cannot currently handle homonyms - word: [$arg->{word}] with label [$label]";

    # TODO: account for homonyms
  }

  $arg->{label} = $lexeme[0]->cat->label unless exists $arg->{label};

  my $lexeme = $self->$orig( %$arg );

  $lexeme->{rs} = $rs;
  $lexeme->{lexeme} = \@lexeme;

  confess ref $lexeme if ref $lexeme ne 'Syntactic::Practice::Lexeme';

  return $lexeme;

};

no Moose;
__PACKAGE__->meta->make_immutable;
