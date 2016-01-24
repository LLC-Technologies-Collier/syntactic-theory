package Syntactic::Practice::Parser;

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

has grammar => ( is => 'ro',
                 isa => 'Syntactic::Practice::Grammar',
                 default => sub { Syntactic::Practice::Grammar->new({locale => 'en_US.UTF-8'}) } );

sub ingest_phrase {
  my ( $self, $opt ) = @_;
  my ( $sentence, $from ) =
    @{ $opt }{qw( sentence from )};

  $from = 0 unless defined $from;

  my( $phrasal_rule ) =
    ( ref $opt->{rule} ? $opt->{rule} : $self->grammar->rule( label => $opt->{rule} ) );

  confess( "bad phrase rule!" ) unless $phrasal_rule;

  my $num_words = scalar( @$sentence );
  return ( { error => "insufficient words to license phrase" } )
    if ( $from >= $num_words );

  my $target_label = $phrasal_rule->{label};

  my @node_list = @{ $phrasal_rule->{node} };

  my @error = ();

  my @decomp = ( [] );
  for ( my $node_num = 0; $node_num < scalar @node_list; $node_num++ ) {
    my $node       = $node_list[$node_num];
    my $node_label = $node->{label};
    my $cat_type   = $node->{cat_type};

    my $r;
    if ( $cat_type eq 'phrasal' ) {
      # TODO: support multiple rules with same label
      ($r) = $self->grammar->rule({ label => $node_label });
    } elsif ( $cat_type eq 'lexical' ) {
      $r = $node;
    }

    my %ingest_arg = ( sentence => $sentence,
                       from => $from,
                       rule => $r );

    my $optional = $node->{optional};
    my $repeat   = $node->{repeat};

    my $optAtPos = {};

    for ( my $decomp_num = 0; $decomp_num < scalar @decomp; $decomp_num++ ) {
      my $decomp = $decomp[$decomp_num];

      my $curpos = ( scalar @$decomp ? $decomp->[-1]->topos : $from );

      next if $curpos == $num_words;

      $ingest_arg{from} = $curpos;
      my @result;
      if ( $optional && !exists $optAtPos->{$curpos} ) {
        my $class;
        my %const_arg = ( frompos  => $curpos,
                          topos    => $curpos,
                          cat_type => $cat_type,
                          label    => $node_label,
                          target_label => $target_label,
                          node_num   => $node_num,
                          sentence => $sentence, );
        if ( $cat_type eq 'lexical' ) {
          $class = 'Syntactic::Practice::Lexeme';
          delete $const_arg{label};
          $const_arg{sentence} = $sentence->[$curpos]->sentence;
          $const_arg{word}     = $sentence->[$curpos]->word;
        } else {
          $class = 'Syntactic::Practice::Phrase';
        }
        my $constituent = $class->new( %const_arg );

        $optAtPos->{$curpos} = $constituent;
        push( @result, $constituent );

      }

      if( $cat_type eq 'lexical' ){
        my $lexeme = $sentence->[$curpos];
        if ( $lexeme->label eq $node_label ){
          push( @result, $lexeme )
        }else{
          push( @result, { error =>
'['.$lexeme->word."] (position [$curpos]) with label [".$lexeme->label."] not licensed by [$node_label]"
    } );
        }
      }else{
        push( @result, ( $self->ingest_phrase( \%ingest_arg ) ) );
      }



      # remove placeholder ; replaced below unless there is an error
      splice( @decomp, $decomp_num--, 1 );

      my $num_errors = 0;
      foreach my $d ( @result ) {
        if ( ref $d eq 'HASH' && exists $d->{error} ) {
          push( @error, $d );
          next;
        }
        $decomp_num++;
        splice( @decomp, $decomp_num, 0, ( [ @$decomp, $d ] ) );
        splice( @decomp, $decomp_num, 0, ( [ @$decomp, $d ] ) ) if ( $repeat );
      }
    }
  }

  my @return = ();
  while ( my $d = shift( @decomp ) ) {
    my %const_arg = ( label         => $target_label,
                       sentence      => $sentence,
                       frompos       => $from,
                       cat_type      => 'phrasal',
                       topos         => $d->[-1]->topos,
                       decomposition => $d );

    my $constituent = Syntactic::Practice::Phrase->new( %const_arg );

    push( @return, $constituent );
  }

  if( scalar @return > 1 ){
  # De-duplicate
    my @return_copy = @return;
    my @second_copy = @return_copy;
    my @unique;
    while ( my $l = shift( @second_copy ) ) {
      my @dup = grep { $l->cmp( $_ ) == 0 } @return_copy;
      my @sorted = sort { $a->name cmp $b->name } ( @dup );
      $l           = $sorted[0];
      @unique      = grep { $l->cmp( $_ ) != 0 } @return_copy;
      @return_copy = ( @unique, $l );
    }
    @return = @return_copy;
  }

  return( @return ) if scalar @return;
  return( @error );
}

around 'ingest_phrase' => sub {
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
