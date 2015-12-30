#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Syntactic::Practice' ) || print "Bail out!\n";
}

diag( "Testing Syntactic::Practice $Syntactic::Practice::VERSION, Perl $], $^X" );
