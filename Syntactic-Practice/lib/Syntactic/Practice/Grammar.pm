package Syntactic::Practice::Grammar;

use Syntactic::Practice::Util;

use Moose;

has 'locale' => ( is      => 'ro',
                  isa     => 'Str',
                  default => 'en_US.UTF-8' );

sub rule {
  my ( $self, @opt ) = @_;

  my $opt;
  if ( scalar @opt == 1 && ref $opt[0] eq 'HASH' ) {
    $opt = $opt[0];
  } else {
    $opt = {@opt};
  }

  my $label = $opt->{label};

  my $cond = { 'LOWER(target.label)' => { 'LIKE' => lc( $label ) } };
  my $rs = $self->{rule_rs}->search( $cond );

  my @rule;
  while ( my $r = $rs->next() ) {
    my $rule = { label => $r->target->label,
                 id    => $r->id,
                 node  => [] };
    my $nodes = $r->rule_nodes;
    while ( my $n = $nodes->next ) {
      my $bnf = $n->cat->label;
      $bnf = ( $n->optional ? "[$bnf]" : "<$bnf>" );
      $bnf .= '+' if $n->rpt;
      my $node = { label    => $n->cat->label,
                   name     => $n->cat->longname,
                   cat_type    => $n->cat->ctype,
                   bnf      => $bnf,
                   optional => $n->optional,
                   repeat   => $n->rpt, };
      $rule->{node}->[ $n->position - 1 ] = $node;
    }
    push( @rule, $rule );
  }
  return @rule if wantarray();
  return \@rule;
}

around 'new' => sub {
  my ( $orig, $self, @arg ) = @_;

  my $schema = Syntactic::Practice::Util->new()->get_schema();

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
__PACKAGE__->meta->make_immutable(inline_constructor => 0);
