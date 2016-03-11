package Syntactic::Practice::Grammar::Sentence;

=head1 NAME

Syntactic::Practice::Grammar::Sentence - A set of Tokens

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use Syntactic::Practice::Types -declare => [qw(Token TokenSet Tree)];

use Moose;
use namespace::autoclean;

use experimental qw(smartmatch);

extends( 'Syntactic::Practice::Grammar::TokenSet' );

with( 'MooseX::Log::Log4perl', 'Syntactic::Practice::Roles::Unique' );

has '+tokens' => ( is       => 'ro',
                   isa      => 'ArrayRef[Token|Tree]|TokenSet',
                   required => 1 );

has '+first' => ( is       => 'ro',
                  isa      => 'Token',
                  lazy     => 1,
                  builder  => '_build_first',
                  init_arg => undef, );

has '+last' => ( is       => 'ro',
                 isa      => 'Token',
                 lazy     => 1,
                 builder  => '_build_last',
                 init_arg => undef, );

sub _log_immutable {
  my $msg = 'sentence object is immutable';
  $_[0]->log->warn( $msg );
  Carp::cluck $msg;
}

no strict 'refs';
foreach my $method ( qw( append append_new prepend prepend_new ) ){
  *{"$method"} = *{"_log_immutable"};
}
use strict 'refs';

sub copy {
  my ( $self, %attr ) = @_;
  my $tkset_class = 'Syntactic::Practice::Grammar::TokenSet';
  my $tkset = bless( {%$self}, $tkset_class );
  my $copy = $tkset->copy( %attr );
  bless $copy, __PACKAGE__;
}

1;
