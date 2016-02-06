package Syntactic::Practice;

use 5.006;
use strict;
use warnings FATAL => 'all';


use Data::Printer;

BEGIN {
  use Log::Log4perl;

  Log::Log4perl->init( 'log4perl.conf' ) or die "couldn't init logger: $!";

  Log::Log4perl->get_logger()->info( "Syntactic::Practice startup..." );

  use Syntactic::Practice::Schema;
  use Syntactic::Practice::Util;

  my $ns = 'Syntactic::Practice';

  my $declared = [
    ( map { "${ns}::$_" }
        qw ( Grammar Grammar::Category Grammar::Rule Grammar::Term
        Grammar::Factor Roles::Category Tree Tree::Abstract Lexicon
        Lexicon::Homograph Lexicon::Lexeme Lexer::Token Lexer::Analysis
        Lexer Parser
        )
    ), (
      map {
        ( "${ns}::Tree::${_}", "${ns}::Tree::Abstract::${_}",
          "${ns}::Grammar::Category::${_}", )
      } Syntactic::Practice::Util->get_tree_types
       ) ];

  eval 'use Syntactic::Practice::Types -declare => $declared';
}

use Syntactic::Practice::Grammar::Category;
use Syntactic::Practice::Grammar;
use Syntactic::Practice::Grammar::Term;
use Syntactic::Practice::Grammar::Factor;
use Syntactic::Practice::Roles::Category;
use Syntactic::Practice::Grammar::Rule;
use Syntactic::Practice::Tree;
use Syntactic::Practice::Lexicon;
use Syntactic::Practice::Lexicon::Homograph;
use Syntactic::Practice::Lexicon::Lexeme;
use Syntactic::Practice::Lexer::Token;
use Syntactic::Practice::Lexer::Analysis;
use Syntactic::Practice::Lexer;
use Syntactic::Practice::Parser;

=head1 NAME

Syntactic::Practice - Natural Language Processing Engine

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Syntactic::Practice;

    my $foo = Syntactic::Practice->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 function1

=cut

sub function1 {
}

=head2 function2

=cut

sub function2 {
}

=head1 AUTHOR

C.J. Adams-Collier, C<< <cjac at colliertech.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-syntactic-practice at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Syntactic-Practice>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Syntactic::Practice


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Syntactic-Practice>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Syntactic-Practice>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Syntactic-Practice>

=item * Search CPAN

L<http://search.cpan.org/dist/Syntactic-Practice/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2015 C.J. Adams-Collier.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See L<http://dev.perl.org/licenses/> for more information.


=cut

1;    # End of Syntactic::Practice
