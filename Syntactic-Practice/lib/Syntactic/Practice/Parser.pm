package Syntactic::Practice::Parser;

use Syntactic::Practice::Tree::Null;
use Syntactic::Practice::Tree::Lexical;
use Syntactic::Practice::Tree::Phrasal;
use Syntactic::Practice::Grammar;

use Moose;

has current_depth => ( is => 'rw',
                       isa => 'PositiveInt',
                       default => 0
                     );

has max_depth => ( is => 'ro',
                   isa => 'PositiveInt',
                   default => 5
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
  my ( $from, $rule ) =
    @{ $opt }{qw( from rule )};

  $from = 0 unless defined $from;

  my $num_words = scalar( @{ $self->sentence } );
  return ( { error => "insufficient words to license phrase" } )
    if ( $from >= $num_words );

  ( $rule ) = $self->grammar->rule( identifier => (defined $rule ? $rule : 'S') )
    unless ref $rule;

  confess( "bad phrase rule: [$opt->{rule}]!" ) unless $rule;

  my $target_label = $rule->identifier;

  my @symbol_list = $rule->symbols;

  my @error = ();

  my @daughter = ( [] );
  for ( my $symbol_num = 0; $symbol_num < scalar @symbol_list; $symbol_num++ ) {
    my $symbol       = $symbol_list[$symbol_num];
    my $symbol_label = $symbol->label;

    my $optional = $symbol->optional;
    my $repeat   = $symbol->repeat;

    my $optAtPos = {};

    for ( my $daughter_num = 0; $daughter_num < scalar @daughter; $daughter_num++ ) {
      my $daughter = $daughter[$daughter_num];

      my $curpos = ( scalar @$daughter ? $daughter->[-1]->topos : $from );

      next if $curpos == $num_words;

      if ( $optional && !exists $optAtPos->{$curpos} ) {
        my $tree = Syntactic::Practice::Tree::Null->new( label => $symbol->label,
                                                         frompos => $curpos );
        $optAtPos->{$curpos} = $tree;
        splice( @daughter, $daughter_num, 0, ( [ @$daughter, $tree ] ) );
        next;
      }

      my @result;
      if( $symbol->is_terminal ){
        my $tree = $self->sentence->[$curpos];
        if ( $tree->label eq $symbol->label ){
          push( @result, $tree )
        }else{
          push( @result, { error =>
'['.$tree->daughters."] (position [$curpos]) with label [".$tree->label."] not licensed by [$symbol_label]"
                         } );
        }
      }else{
        push( @result, ( $self->ingest( { from => $curpos,
                                          rule => $symbol->label } ) ) );
      }

      # remove placeholder ; replaced below unless there is an error
      splice( @daughter, $daughter_num, 1 );

      if ( ref $result[0] eq 'HASH' && exists $result[0]->{error} ) {
        push( @error, $result[0] );
        $daughter_num--;
        next;
      }

      foreach my $d ( @result ) {
        my @new = ( [ @$daughter, $d ] );
        push( @new, [ @$daughter, $d ] ) if ( $repeat );
        splice( @daughter, $daughter_num, 0, ( @new ) );
      }
    }
  }

  my @return = ();
  while ( my $d = shift( @daughter ) ) {
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

  return( @return ) if scalar @return;
  return( @error );
}

around 'ingest' => sub {
  my ( $orig, $self, @arg ) = @_;

  $self->current_depth( $self->current_depth + 1 );

  return ( { error => 'exceeded maximum recursion depth ['.$self->max_depth.']' } )
    if ( $self->current_depth > $self->max_depth );

  my( @result ) = $self->$orig( @arg );

  $self->current_depth( $self->current_depth - 1 );

  return @result;
};


no Moose;
__PACKAGE__->meta->make_immutable;
