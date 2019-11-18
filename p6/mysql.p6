#!/usr/bin/env perl6

use v6;
use DBIish;

my $password="password";

my $dbh = DBIish.connect('mysql', :database<grammar>, :user<grammaradm>, :$password);

say "connect completed";

my $sth = $dbh.prepare(q:to/STATEMENT/);
  SELECT id, word, cat_id
  FROM lexeme
  ORDER by word
STATEMENT

say "prepare completed";

$sth.execute();

my @rows = $sth.allrows();

say "fetched all rows";

say "row count: " ~ @rows.elems;

$sth.finish;

$dbh.dispose;

