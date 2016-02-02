package Syntactic::Practice;

use 5.006;
use strict;
use warnings FATAL => 'all';

use Log::Log4perl;
BEGIN {
  Log::Log4perl->init('log4perl.conf') or die "couldn't init logger: $!";

  my $log = Log::Log4perl->get_logger('syntactic-practice');
  $log->info("Syntactic::Practice startup...");
};

use MooseX::Params::Validate;
use Moose::Util::TypeConstraints;
use Carp;
use Data::Dumper;

use Syntactic::Practice::Util;
use Syntactic::Practice::Types;
use Syntactic::Practice::Grammar::Category;
use Syntactic::Practice::Grammar::Category::Lexical;
use Syntactic::Practice::Grammar::Category::NonTerminal;
use Syntactic::Practice::Grammar::Category::Phrasal;
use Syntactic::Practice::Grammar::Category::Start;
use Syntactic::Practice::Grammar::Category::Terminal;
use Syntactic::Practice::Grammar::Rule;
use Syntactic::Practice::Grammar::RuleSet;
use Syntactic::Practice::Grammar::Symbol;
use Syntactic::Practice::Grammar::Symbol::Lexical;
use Syntactic::Practice::Grammar::Symbol::Phrasal;
use Syntactic::Practice::Grammar::Symbol::Start;
use Syntactic::Practice::Lexicon;
use Syntactic::Practice::Lexicon::Homograph;
use Syntactic::Practice::Lexicon::Lexeme;
use Syntactic::Practice::Schema;
use Syntactic::Practice::Tree;
use Syntactic::Practice::Tree::Abstract::Lexical;
use Syntactic::Practice::Tree::Abstract::Null;
use Syntactic::Practice::Tree::Abstract::Phrasal;
use Syntactic::Practice::Tree::Abstract::Start;
use Syntactic::Practice::Tree::Abstract::Terminal;
use Syntactic::Practice::Tree::Lexical;
use Syntactic::Practice::Tree::Null;
use Syntactic::Practice::Tree::Phrasal;
use Syntactic::Practice::Tree::Start;
use Syntactic::Practice::Tree::Terminal;


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

1; # End of Syntactic::Practice
