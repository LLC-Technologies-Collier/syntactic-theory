package Syntactic::Practice::Tree::Lexical;

use Syntactic::Practice::Types;
use Moose;

extends 'Syntactic::Practice::Tree::Terminal';

has '+label' => ( is       => 'ro',
                  isa      => 'LexicalCategoryLabel',
                  required => 0, );

has '+daughters' => ( is => 'ro',
                      isa => 'Word',
                      required => 1
                    );

my $schema = Syntactic::Practice::Util->get_schema();

around 'new' => sub {
  my ( $orig, $self, @arg ) = @_;
  my $arg;

  if ( scalar @arg == 1 && ref $arg[0] eq 'HASH' ) {
    $arg = $arg[0];
  } else {
    $arg = {@arg};
  }

  my $cond = { 'LOWER(me.word)' => { 'LIKE' => lc( $arg->{daughters} ) } };
  $cond->{'cat.label'} = $arg->{label} if exists $arg->{label};

  my $rs =
    $schema->resultset( 'Lexeme' )->search( $cond, { prefetch => ['cat'] } );

  my @lexeme = $rs->all();
  my $count = scalar @lexeme;
  my $label = exists $arg->{label} ? $arg->{label} : 'unknown';
  if ( $count == 0 ) {
    return { error => "unknown word: [$arg->{daughters}] with label [$label]" };

    # TODO: prompt for definition
  } elsif ( $count > 1 ) {
    die
"cannot currently handle homonyms - word: [$arg->{daughters}] with label [$label]";

    # TODO: account for homonyms
  }

  $arg->{label} = $lexeme[0]->cat->label unless exists $arg->{label};

  my $lexTree = $self->$orig( %$arg );

  $lexTree->{rs}     = $rs;
  $lexTree->{lexeme} = \@lexeme;

  confess ref $lexTree if ref $lexTree ne 'Syntactic::Practice::Tree::Lexical';

  return $lexTree;
};

no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);
