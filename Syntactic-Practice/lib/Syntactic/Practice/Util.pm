package Syntactic::Practice::Util;

use Syntactic::Practice::Schema;
use Moose;

my $hostname = 'localhost';
my $port     = '3306';
my $database = 'grammar';
my $user     = 'grammaruser';
my $pass     = 'nunya';
my $dsn      = "DBI:mysql:database=$database;host=$hostname;port=$port";

my $schema = Syntactic::Practice::Schema->connect( $dsn, $user, $pass );

sub get_schema {
  my( $self ) = @_;

  return $schema;
}

no Moose;
__PACKAGE__->meta->make_immutable;
