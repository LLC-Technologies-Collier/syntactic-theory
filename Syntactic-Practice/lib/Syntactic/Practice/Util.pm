package Syntactic::Practice::Util;

use Moose;

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

sub get_phrasal_labels {
  @phrasal_labels;
}

my @syntactic_labels =
  map { $_->label }
  $schema->resultset( 'SyntacticCategory' )->search( {}, { distinct => 1 } )
  ->all();

sub get_syntactic_labels   { @syntactic_labels }
sub get_nonterminal_labels { get_phrasal_labels }
sub get_terminal_labels    { get_lexical_labels }
sub get_start_labels       { qw( S ) }
sub get_null_labels        { }

my %label_cat;

sub get_cat_for_label {
  my ( $label ) = @_;

  Log::Log4perl->get_logger()->debug( "Finding category for label [$label]" );

  return $label_cat{$label} if exists $label_cat{$label};

  Log::Log4perl->get_logger()->debug( 'lexical: ', Data::Printer::p get_lexical_labels );
  return $label_cat{$label} = 'Lexical'
    if grep { $_ eq $label } get_lexical_labels;
    Log::Log4perl->get_logger()->debug( 'start: ', Data::Printer::p get_start_labels );
  return $label_cat{$label} = 'Start' if grep { $_ eq $label } get_start_labels;
  Log::Log4perl->get_logger()->debug( 'phrasal: ', Data::Printer::p get_phrasal_labels );
  return $label_cat{$label} = 'Phrasal'
    if grep { $_ eq $label } get_phrasal_labels;
  Log::Log4perl->get_logger()->debug( 'nonterminal: ', Data::Printer::p get_nonterminal_labels );
  return $label_cat{$label} = 'NonTerminal'
    if grep { $_ eq $label } get_nonterminal_labels;
  Log::Log4perl->get_logger()->debug( 'terminal: ', Data::Printer::p get_terminal_labels );
  return $label_cat{$label} = 'Terminal'
    if grep { $_ eq $label } get_terminal_labels;

  return 'Syntactic';
}

sub get_terminal_types {
  qw( Null Lexical Literal );
}

sub get_nonterminal_types {
  qw( Start Phrasal );
}

sub get_syntactic_types {
  qw( Terminal NonTerminal ), get_terminal_types, get_nonterminal_types;
}

no Moose;
__PACKAGE__->meta->make_immutable;
