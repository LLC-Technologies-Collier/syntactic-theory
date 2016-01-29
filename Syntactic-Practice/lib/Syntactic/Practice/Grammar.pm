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
  my ( $self, $arg ) = @_;

  my @rs;
  if ( exists( $arg->{identifier} ) ) {
    my $identifier = $arg->{identifier};

    my $cond = { 'target.label' => $identifier };
    my $rs = $self->{rule_rs}->search( $cond );
    push( @rs, $rs );

  } elsif ( exists( $arg->{daughters} ) ) {
    foreach my $d ( @{ $arg->{daughters} } ) {
      my $d_rs = $self->{rule_rs}->search( { 'symbols.cat.label' => $d } );
      while ( my $r = $d_rs->next ) {
        my $match           = 1;
        my @symbol          = $r->symbols;
        my @daughter_symbol = @{ $arg->{daughters} };
        for ( my $i = 0; $i < scalar @daughter_symbol; $i++ ) {
          my $found_d = shift( @symbol );
          next if ( $found_d->cat->label eq $daughter_symbol[$i] );
          redo if ( $found_d->optional );
          $match = 0;
          last;
        }
        push( @rs, $d_rs ) if ( $match );
      }
    }
  } else {
    die qq{Don't know how to look up rule with arguments provided: }
      . join( ', ', keys %$arg );
  }

  my @rule;
  foreach my $rs ( @rs ) {
    while ( my $r = $rs->next() ) {
      my $rule = { identifier => $r->target->label,
                   symbols    => [] };
      my $symbols = $r->symbols;
      while ( my $sym = $symbols->next ) {
        my $class =
          'Syntactic::Practice::Grammar::Symbol::' . ucfirst $sym->cat->ctype;
        my $symbol = $class->new( label    => $sym->cat->label,
                                  name     => $sym->cat->longname,
                                  optional => $sym->optional,
                                  repeat   => $sym->rpt, );
        $rule->{symbols}->[ $sym->position - 1 ] = $symbol;
      }
      push( @rule, Syntactic::Practice::Grammar::Rule->new( $rule ) );
    }
  }
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

  my ( $key, $lookupOpt );
  if ( exists $opt->{identifier} ) {
    $key = $opt->{identifier};

    $lookupOpt = { identifier => $opt->{identifier} };
  } elsif ( exists $opt->{daughters} ) {
    $key = join( '+', @{ $opt->{daughters} } );
    $lookupOpt = { daughters => $opt->{daughters} };
  }

  my @rule = ( exists $rule{$key}
               ? @{ $rule{$key} }
               : $self->_lookup_rule( $lookupOpt ) );

  $rule{$key} = \@rule;

  return @{ $rule{$key} }
    if wantarray();
  return $rule{$key};
}

around 'new' => sub {
  my ( $orig, $self, @arg ) = @_;

  my $schema = Syntactic::Practice::Util->get_schema();

  my $obj = $self->$orig( @arg );
  $obj->{schema} = $schema;
  $obj->{rule_rs} = $schema->resultset( 'PhraseStructureRule' )->search(
                                      {},
                                      { prefetch =>
                                          [ 'target', { 'symbols' => ['cat'] } ]
                                      } );
  return $obj;
};

no Moose;
__PACKAGE__->meta->make_immutable( inline_constructor => 0 );
