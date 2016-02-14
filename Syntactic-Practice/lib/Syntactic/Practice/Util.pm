package Syntactic::Practice::Util;

use Syntactic::Practice::Schema;
use Carp;
use MooseX::Singleton;

my $hostname = 'localhost';
my $port     = '3306';
my $database = 'grammar';
my $user     = 'grammaruser';
my $pass     = 'nunya';
my $dsn      = "DBI:mysql:database=$database;host=$hostname;port=$port";

my $schema_namespace = 'Syntactic::Practice::Schema';
my $rs_namespace     = "${schema_namespace}::Result";
my $schema           = $schema_namespace->connect( $dsn, $user, $pass );

sub get_rs_namespace {
  return $rs_namespace;
}

sub get_schema {
  return $schema;
}

my @lexical_labels =
  map { $_->label }
  $schema->resultset( 'LexicalCategory' )->search( {}, { distinct => 1 } )
  ->all();

sub get_lexical_labels {
  @lexical_labels;
}

my @phrasal_labels =
  map { $_->label }
  $schema->resultset( 'PhrasalCategory' )->search( {}, { distinct => 1 } )
  ->all();

Log::Log4perl->get_logger()->debug( "Phrasal labels: @phrasal_labels" );

sub get_phrasal_labels {
  @phrasal_labels;
}

my @syntactic_labels =
  map { $_->label }
  $schema->resultset( 'SyntacticCategory' )->search( {}, { distinct => 1 } )
  ->all();

sub get_syntactic_labels   { @syntactic_labels }
sub get_recursive_labels   { qw( NOM PP ) }
sub get_nonterminal_labels { get_phrasal_labels }
sub get_terminal_labels    { get_lexical_labels }
sub get_start_labels       { qw( S ) }
sub get_null_labels        { }

my %label_cat;

sub get_terminal_types {
  qw( Null Lexical Literal );
}

sub get_nonterminal_types {
  qw( Start Phrasal );
}

sub get_syntactic_types {
  get_nonterminal_types, get_terminal_types, qw( Terminal NonTerminal );
}

sub get_cat_for_label {
  my ( $self, $label )  = @_;

  $label //= $self;

  Log::Log4perl->get_logger()->debug( "Finding category for label [$label]" );

  return $label_cat{$label} if exists $label_cat{$label};

  foreach my $stype ( get_syntactic_types ){
    my $method = 'get_'.lc($stype).'_labels';
    unless( $self->can($method) ){
      Log::Log4perl->get_logger->debug( "Unrecognized stype [$stype]" );
      confess($stype);
    }
    return $stype if grep { $_ eq $label } $self->$method;
  }

  return 'Syntactic';
}

no Moose;
__PACKAGE__->meta->make_immutable;
