package Syntactic::Practice::Util;

use Moose;

my $hostname = 'localhost';
my $port     = '3306';
my $database = 'grammar';
my $user     = 'grammaruser';
my $pass     = 'nunya';
my $dsn      = "DBI:mysql:database=$database;host=$hostname;port=$port";

my $schema_namespace = 'Syntactic::Practice::Schema';
my $rs_namespace = "${schema_namespace}::Result";
my $schema = $schema_namespace->connect( $dsn, $user, $pass );

sub get_rs_namespace {
  return $rs_namespace;
}

sub get_schema {
  return $schema;
}

sub get_start_category_labels {
  qw( S );
}

sub get_syntactic_category_types {
  qw(Phrasal Lexical);
}

sub get_terminal_types {
  qw( Null Lexical Literal );
}

sub get_nonterminal_types {
  qw( Phrasal Start );
}

sub get_tree_types {
  qw( Terminal NonTerminal ), get_terminal_types, get_nonterminal_types
}

no Moose;
__PACKAGE__->meta->make_immutable;
