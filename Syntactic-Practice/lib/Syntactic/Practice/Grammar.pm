package Syntactic::Practice::Grammar;

use Syntactic::Practice::Util;
use Syntactic::Practice::Grammar::Rule;
use Syntactic::Practice::Grammar::Symbol::Lexical;
use Syntactic::Practice::Grammar::Symbol::Phrasal;

use Moose;

has 'locale' => ( is      => 'ro',
                  isa     => 'Str',
                  default => 'en_US.UTF-8' );

sub _lookup_rule {
  my ( $self, $identifier ) = @_;

  my $cond = { 'LOWER(target.label)' => { 'LIKE' => lc( $identifier ) } };
  my $rs = $self->{rule_rs}->search( $cond );

  my @rule;
  while ( my $r = $rs->next() ) {
    my $rule = { identifier => $r->target->label,
                 symbols    => [] };
    my $nodes = $r->rule_nodes;
    while ( my $n = $nodes->next ) {
      my $class =
        'Syntactic::Practice::Grammar::Symbol::' . ucfirst $n->cat->ctype;
      my $symbol = $class->new( label    => $n->cat->label,
                                name     => $n->cat->longname,
                                optional => $n->optional,
                                repeat   => $n->rpt, );
      $rule->{symbols}->[ $n->position - 1 ] = $symbol;
    }
    push( @rule, Syntactic::Practice::Grammar::Rule->new( $rule ) );
  }
    use Data::Dumper;
    warn Data::Dumper::Dumper( \@rule );
  return @rule;
}

my %rule;

sub rule {
  my ( $self, @opt ) = @_;

  my $opt;
  if ( scalar @opt == 1 && ref $opt[0] eq 'HASH' ) {
    $opt = $opt[0];
  } else {
    $opt = {@opt};
  }

  my $identifier = $opt->{identifier};

  my @rule =
    exists $rule{$identifier}
    ? @{ $rule{$identifier} }
    : $self->_lookup_rule( $identifier );

  $rule{$identifier} = \@rule;

  return @{ $rule{$identifier} }
    if wantarray();
  return $rule{$identifier};
}

around 'new' => sub {
  my ( $orig, $self, @arg ) = @_;

  my $schema = Syntactic::Practice::Util->get_schema();

  my $rule_rs = $schema->resultset( 'PhraseStructureRule' )->search(
                                       {},
                                       {
                                         prefetch => [
                                           'target', { 'rule_nodes' => ['cat'] }
                                         ]
                                       } );

  my $obj = $self->$orig( @arg );
  $obj->{schema}  = $schema;
  $obj->{rule_rs} = $rule_rs;

  return $obj;
};

no Moose;
__PACKAGE__->meta->make_immutable( inline_constructor => 0 );
