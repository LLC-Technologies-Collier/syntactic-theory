package Syntactic::Practice::Grammar::Factor;

=head1 NAME

Syntactic::Practice::Grammar::Factor - Factors on the right hand side of Terms

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use Moose;
use namespace::autoclean;
use Moose::Util qw( apply_all_roles );

with 'Syntactic::Practice::Roles::Category';
with 'MooseX::Log::Log4perl';

my $rs_namespace = Syntactic::Practice::Util->get_rs_namespace;
my $rs_class     = 'Factor';
has resultset => ( is      => 'ro',
                   isa     => "${rs_namespace}::$rs_class",
                   lazy    => 1,
                   builder => '_build_resultset' );

has term => ( is      => 'ro',
              isa     => 'Term',
              lazy    => 1,
              builder => '_build_term' );

has id => ( is      => 'ro',
            isa     => 'PositiveInt',
            lazy    => 1,
            builder => '_build_id' );

has bnf => ( is       => 'ro',
             isa      => 'Str',
             lazy     => 1,
             init_arg => undef,
             builder  => '_build_bnf' );

has identifier => ( is       => 'ro',
                    isa      => 'Str',
                    lazy     => 1,
                    init_arg => undef,
                    builder  => '_build_identifier' );

has expression => ( is       => 'ro',
                    isa      => 'Str',
                    lazy     => 1,
                    init_arg => undef,
                    builder  => '_build_expression' );

use overload
  q{""}    => sub { $_[0]->as_string },
  fallback => 1;

# Test whether this factor licenses the token sets passed
sub evaluate {
  my ( $self,     %args )        = @_;
  my ( $tokenset, $do_optional ) = @args{qw( tokenset do_optional )};

  my $position = $self->position;

  $do_optional //= 1;

  my $current_token = $tokenset->current;

  return () unless defined $current_token;

  my $license_depth = $self->licenses( $current_token );

  if ( $self->optional && $do_optional ) {

    $self->log->debug( "Factor [$self], position [$position] is optional" );

    my ( @non_opt_tsets ) = (
                              $self->evaluate( tokenset    => $tokenset,
                                               do_optional => 0,
                              ) );

    my $num_results = scalar @non_opt_tsets;
    $self->log->debug(
      "number of results: [$num_results]; array ref values: [@non_opt_tsets]" );

    my $class = 'Syntactic::Practice::Tree::Abstract::Null';

    my $tset = Syntactic::Practice::Grammar::TokenSet->new();
    my $tree = $class->new(
                  sentence     => [],
                  term         => $self->term,
                  category     => $self->category,
                  constituents => Syntactic::Practice::Grammar::TokenSet->new(),
                  factor       => $self,
                  frompos      => $current_token->tree->frompos,
                  label        => $self->label );

    $tset->append_new( $tree );

    return ( $tset, @non_opt_tsets );
  }

  my $msg = '%2d: %-2s %s [%s]';
  unless ( defined $license_depth ) {
    $self->log->debug( "Factor [$self] does not license [$current_token]" );
    my $string = join( ' ', map { "$_" } $tokenset->remainder );
    my @data = ( $current_token->position, $self->label, ' ->', $string );
    $self->log->info( sprintf( $msg, @data ) );

    return ();
  }

  $self->log->debug(
             "Factor [$self], position [$position] licenses [$current_token]" );

  my @token = ();
  if ( $license_depth == 0 ) {
    push( @token, $current_token );
  } else {
    my $parser = Syntactic::Practice::Parser->new( tokenset => $tokenset );
    push( @token, $parser->ingestToken( $tokenset->current_token ) );
  }

  my @tokenset_list;
  foreach my $token ( @token ) {
    $self->log->debug( "Matched factor [$self]: $token" );

    my @data =
      ( $token->tree->frompos, $token->label, ' ->', $token->tree->string );
    $self->log->info( sprintf( $msg, @data ) );

    my $tset = Syntactic::Practice::Grammar::TokenSet->new();
    $tset->append_new( $token->tree );

    push( @tokenset_list, $tset );

    next unless $self->repeat;

    $self->log->debug( "Repeat factor [$self]" );

    my @tokensets;
    if ( $tokenset->current != $tokenset->last ) {
      my $tokenset_copy = $tokenset->copy();
      $tokenset_copy->next;

      push( @tokenset_list,
            map { $_->prepend_new( $token->tree ) }
              $self->evaluate( tokenset    => $tokenset_copy,
                               do_optional => 0
              ) );
    }
  }

  $self->log->debug( "Number of token sets: " . scalar @tokenset_list );

  return @tokenset_list;
}

sub _build_identifier {
  my ( $self ) = @_;
  my $identifier = $self->label;
  $identifier = "<$identifier>" unless $self->is_terminal;
  return $identifier;
}

sub _build_expression {
  my ( $self ) = @_;
  my $f = $self->identifier;
  if ( $self->repeat ) {
    $f = "{ $f }";
  } elsif ( $self->optional ) {
    $f = "[ $f ]";
  }
  return $f;
}

sub _build_bnf {
  join( ' ::= ', $_[0]->identifier, $_[0]->expression );
}

my $required_msg =
  'Neither Term + Label, resultset, nor ID were specified for factor';

sub _build_id { return $_[0]->resultset->id }

sub _build_resultset {
  my ( $self ) = @_;
  my $cond = {};
  if ( exists $self->{term} && exists $self->{label} ) {
    $cond = { 'cat.label' => $self->label,
              term        => $self->term->resultset };
  } elsif ( exists $self->{id} ) {
    $cond = { id => $self->id };
  } else {
    die $required_msg;
  }

  Syntactic::Practice::Util->get_schema->resultset( $rs_class )
    ->find( $cond, { prefetch => [ 'term', 'cat' ] } );
}

sub _build_label {
  $_[0]->resultset->cat->label;
}

sub _build_term {
  my ( $self ) = @_;
  my $term_rs = $_[0]->resultset->term;
  my $term =
    Syntactic::Practice::Grammar::Term->new(
                                         resultset => $term_rs,
                                         label => $term_rs->rule->target->label,
                                         id    => $term_rs->id );

  return $term;
}

sub BUILD {
  my ( $self ) = @_;

  if ( grep { $self->label eq $_ }
       Syntactic::Practice::Util->get_recursive_labels )
  {
    apply_all_roles( $self, 'Syntactic::Practice::Roles::Category::Recursive' );
  } else {
    apply_all_roles( $self,
                     'Syntactic::Practice::Roles::Category::NonRecursive' );
  }
  return $self;
}

my $max_depth = 5;

sub licenses {
  my ( $self, $type, $depth ) = @_;
  $depth //= 0;
  return undef if $depth >= $max_depth;
  return undef unless $type->can( 'label' );
  return $depth if $self->label eq $type->label;
  return undef  if $self->is_terminal;
  my $rule = Syntactic::Practice::Grammar->new->rule( label => $self->label );
  my $min = undef;
  foreach my $term ( @{ $rule->terms } ) {

    foreach my $factor ( @{ $term->factors } ) {
      my $d = $factor->licenses( $type, $depth + 1 );
      next unless defined $d;
      unless ( defined $min ) {
        $min = $d;
        next;
      }
      $min = $d if $d < $min;
    }
  }
  return $min;
}

sub repeat {
  return $_[0]->resultset->rpt;
}

sub optional {
  return $_[0]->resultset->optional;
}

sub position {
  return $_[0]->resultset->position;
}

sub next {
  my ( $self ) = @_;
  return undef
    if $self->position >= $self->term->num_factors;    # indexed from 1
  return $self->term->factors->[ $self->position ];
}

sub as_string {
  my ( $self ) = @_;

  my $str = $self->label;
  $str = ( $self->optional ? "[$str]" : "<$str>" );
  $str .= '+' if $self->repeat;

  return $str;
}

__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Grammar::Factor::NonTerminal;

use Moose;
use namespace::autoclean;

extends 'Syntactic::Practice::Grammar::Factor';
with 'Syntactic::Practice::Roles::Category::NonTerminal';

__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Grammar::Factor::Phrasal;

use Moose;
use namespace::autoclean;

extends 'Syntactic::Practice::Grammar::Factor::NonTerminal';
with 'Syntactic::Practice::Roles::Category::Phrasal';

__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Grammar::Factor::Terminal;

use Moose;
use namespace::autoclean;

extends 'Syntactic::Practice::Grammar::Factor';
with 'Syntactic::Practice::Roles::Category::Terminal';

__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Grammar::Factor::Lexical;

use Moose;
use namespace::autoclean;

extends 'Syntactic::Practice::Grammar::Factor::Terminal';
with 'Syntactic::Practice::Roles::Category::Lexical';

__PACKAGE__->meta->make_immutable;

package Syntactic::Practice::Grammar::Factor::Literal;

use Moose;
use namespace::autoclean;

extends 'Syntactic::Practice::Grammar::Factor::Terminal';

has '+label' => ( is       => 'ro',
                  isa      => 'Str',
                  required => 1 );

sub as_string {
  my ( $self ) = @_;

  my $str = $self->label;

  return qq{"$str"};
}

__PACKAGE__->meta->make_immutable();
