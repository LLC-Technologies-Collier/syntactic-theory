package Syntactic::Practice::Parser;

use Syntactic::Practice::Tree::Null;
use Syntactic::Practice::Tree::Lexical;
use Syntactic::Practice::Tree::Phrasal;
use Syntactic::Practice::Grammar;

use Moose;

has max_depth => ( is => 'ro',
                   isa => 'PositiveInt',
                   default => 20
                 );

has sentence => ( is => 'ro',
                  isa => 'ArrayRef[Syntactic::Practice::Tree::Lexical]',
                  required => 1,
                );

has grammar => ( is => 'ro',
                 isa => 'Syntactic::Practice::Grammar',
                 default => sub { Syntactic::Practice::Grammar->new({locale => 'en_US.UTF-8'}) } );

sub ingest {
  my ( $self, $opt ) = @_;
  my ( $from, $target_label ) =
    @{ $opt }{qw( from rule )};

  $from = 0 unless defined $from;

  my $num_words = scalar( @{ $self->sentence } );
  return ( { error => "insufficient words to license phrase" } )
    if ( $from >= $num_words );

  $target_label //= 'S';
  my @rule = $self->grammar->rule( identifier => $target_label );

  confess( "bad phrase rule: [$opt->{rule}]!" ) unless @rule;

  my @return = ();
  my @error = ();

  my @symbol_list;
  foreach my $rule (@rule){
    push( @symbol_list, [$rule->symbols] );
  }

  foreach my $s ( @symbol_list[0] ){
    my @d_list = ( [] );

    foreach my $symbol ( @$s ) {
      my $symbol_label = $symbol->label;

      my $optional = $symbol->optional;
      my $repeat   = $symbol->repeat;

      my $optAtPos = {};

      for ( my $dlist_idx = 0; $dlist_idx < scalar @d_list; $dlist_idx++ ) {
        my $daughter = $d_list[$dlist_idx];

        my $curpos = ( scalar @$daughter ? $daughter->[-1]->topos : $from );

        next if $curpos == $num_words;

        if ( $optional && !exists $optAtPos->{$curpos} ) {
          my $tree = Syntactic::Practice::Tree::Null->new( label => $symbol->label,
                                                           frompos => $curpos );
          $optAtPos->{$curpos} = $tree;
          splice( @d_list, $dlist_idx, 0, ( [ @$daughter, $tree ] ) );
          next;
        }

        my @result;
        if ( $symbol->is_terminal ) {
          my $tree = $self->sentence->[$curpos];
          if ( $tree->label eq $symbol->label ) {
            push( @result, $tree )
          } else {
            push( @result, { error =>
                             '['.$tree->daughters."] (position [$curpos]) with label [".$tree->label."] not licensed by [$symbol_label]"
                           } );
          }
        } else {
          push( @result, ( $self->ingest( { from => $curpos,
                                            rule => $symbol->label } ) ) );
        }

        # remove placeholder ; replaced below unless there is an error
        splice( @d_list, $dlist_idx, 1 );

        if ( ref $result[0] eq 'HASH' && exists $result[0]->{error} ) {
          push( @error, $result[0] );
          $dlist_idx--;
          next;
        }

        foreach my $d ( @result ) {
          my @new = ( [ @$daughter, $d ] );
          push( @new, [ @$daughter, $d ] ) if ( $repeat );
          splice( @d_list, $dlist_idx, 0, ( @new ) );
        }
      }
    }

    while ( my $d = shift( @d_list ) ) {
      my @d = grep { $_->frompos != $_->topos } @$d;
      next unless scalar @d;
      my $tree =
        Syntactic::Practice::Tree::Phrasal->new( label     => $target_label,
                                                 frompos   => $from,
                                                 topos     => $d[-1]->topos,
                                                 daughters => \@d );
      grep { $tree->cmp( $_ ) == 0 } @return or
        push( @return, $tree );
    }
  }


  return( @return ) if scalar @return;
  return( @error );
}

around 'new' =>  sub {
  my ( $orig, $self, @arg ) = @_;

  my $obj = $self->$orig( @arg );

  $obj->{current_depth} = 0;

  return $obj;
};

around 'ingest' => sub {
  my ( $orig, $self, @arg ) = @_;

  if ( $self->{current_depth}++ >= $self->max_depth ){
    --$self->{current_depth};
    return ( { error => 'exceeded maximum recursion depth ['.$self->max_depth.']' } )
  }

  my( @result ) = $self->$orig( @arg );

  return @result if( ref $result[0] eq 'HASH' && exists $result[0]->{error} );

  if( --$self->{current_depth} == 0 ){
    # only return the trees with all symbols ingested
    my $num_symbols = scalar @{ $self->sentence };
    my @num_ingested;
    my @complete;
    foreach my $tree ( @result ){
      push( @num_ingested, ($tree->daughters)[-1]->topos );
      push( @complete, $tree ) if( $num_ingested[-1] == $num_symbols );
    }
    return { error => "Incomplete parse.  There are $num_symbols symbols in input, but only [ @num_ingested ] symbols were ingested" } unless scalar @complete;
  }

  return @result;
};


no Moose;
__PACKAGE__->meta->make_immutable;
