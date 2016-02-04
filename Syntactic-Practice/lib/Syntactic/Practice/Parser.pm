package Syntactic::Practice::Parser;

=head1 NAME

Syntactic::Practice::Parser - A natural language parser

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use Moose;
use MooseX::Params::Validate;
use MooseX::Method::Signatures;

with 'MooseX::Log::Log4perl';

has max_depth => ( is      => 'ro',
                   isa     => 'PositiveInt',
                   default => 5 );

has allow_partial => ( is      => 'ro',
                       isa     => 'Bool',
                       default => 0 );

has allow_duplicates => ( is      => 'ro',
                          isa     => 'Bool',
                          default => 0 );

has prune_nulls => ( is      => 'ro',
                     isa     => 'Bool',
                     default => 1 );

has sentence => ( is       => 'ro',
                  isa      => 'ArrayRef[TerminalAbstractTree]',
                  required => 1, );

method ingest ( PositiveInt :$frompos,
                SyntacticCategory :$category ) {

  my $num_words = scalar( @{ $self->sentence } );
  if ( $frompos >= $num_words ) {
    $self->log->error( "insufficient words to license phrase" );
    return ();
  }

  my %tree_params = ( frompos  => $frompos,
                      depth    => $self->{current_depth},
                      sentence => $self->sentence,
                      label    => $category->label, );

  my $msg = '%2d: %-2s %s [%s]';

  if ( $category->is_terminal ) {
    my $target = $self->sentence->[$frompos];
    $tree_params{label} = $target->label;
    $target = $target->new( %$target, %tree_params, );
    my @data = ( $frompos, $category->label, ' ->', $target->string );
    if ( $target->label eq $category->label ) {
      $data[2] = ' ->';
      $self->log->info( sprintf( " $msg", @data ) );
      return ( $target );
    }
    $data[2] = '!->';
    $self->log->info( sprintf( " $msg", @data ) );
    return ();
  }

  my $rule = Syntactic::Practice::Grammar::Rule->new( category => $category );

  unless ( $rule ) {
    $self->log->debug(
                    sprintf( 'bad rule identifier: [%s]!', $category->label ) );
    return ();
  }

  my @return = ();
  my $terms  = $rule->terms;
  foreach my $term ( @$terms ) {    # TODO: support multiple terms
    $tree_params{term} = $term;

    my ( $target );
    if ( $term->is_start ) {
      $target = Syntactic::Practice::Tree::Abstract::Start->new( %tree_params );
      $tree_params{label} = $target->label;
    } else {
      $target =
        Syntactic::Practice::Tree::Abstract::Phrasal->new( %tree_params );
    }

    my @d_list = ( [] );
    foreach my $factor ( @{ $term->factors } ) {
      $target->factor( $factor ) unless $target->is_start;
      my $factor_label = $factor->label;

      my $optional = $factor->optional;
      my $repeat   = $factor->repeat;

      my $optAtPos = {};

      for ( my $dlist_idx = 0; $dlist_idx < scalar @d_list; $dlist_idx++ ) {
        my @daughter = @{ $d_list[$dlist_idx] };

        my $curpos = ( scalar @daughter ? $daughter[-1]->topos : $frompos );

        next if $curpos == $num_words;

        if ( $optional && !exists $optAtPos->{$curpos} ) {
          my %mother = ( $factor->is_start ? () : ( mother => $target ) );
          my $class = 'Syntactic::Practice::Tree::Abstract::Null';
          my $tree = $class->new( depth    => $self->{current_depth} + 1,
                                  term     => $term,
                                  category => $factor->category,
                                  factor   => $factor,
                                  frompos  => $curpos,
                                  sentence => $self->sentence,
                                  label    => $factor_label,
                                  %mother, );
          $optAtPos->{$curpos} = $tree;
          splice( @d_list, $dlist_idx, 0, ( [ @daughter, $tree ] ) );
          next;
        }

        splice( @d_list, $dlist_idx, 1 );
        my @tree = $self->ingest( frompos  => $curpos,
                                  category => $factor->category );

        unless ( @tree ) {
          my @s = @{ $self->sentence };
          unless ( $factor->is_terminal ) {
            my $string = join( ' ', map { $_->string } @s[ $curpos .. $#s ] );
            my @data = ( $curpos, $factor_label, '!->', $string );
            $self->log->info( sprintf( $msg, @data ) );
          }

          $dlist_idx--;
          next;
        }
        foreach my $tree ( @tree ) {
          $tree->mother( $target );

          my @new = ( [ @daughter, $tree ] );
          push( @new, [ @daughter, $tree ] ) if ( $repeat );
          splice( @d_list, $dlist_idx, 0, ( @new ) );
        }
      }
    }
    while ( my $d = shift( @d_list ) ) {
      my @d;
      if ( $self->prune_nulls ) {
        @d =
          grep { !$_->isa( 'Syntactic::Practice::Tree::Abstract::Null' ) } @$d;
      } else {
        @d = @$d;
      }
      next unless scalar @d;

      my $tree =
        $target->new( %$target,
                      %tree_params,
                      frompos   => $d[0]->frompos,
                      topos     => $d[-1]->topos,
                      daughters => \@d );

      foreach my $sib ( @d ) {
        next unless $sib->isa( 'Tree' );
        my @sibs = grep { $sib->cmp( $_ ) != 0 } @d;
        $sib->sisters( \@sibs );
        $sib->mother( $tree );
      }
      my @data = ( $d[0]->frompos, $tree->label, ' ->', $tree->string );
      $self->log->info( sprintf( $msg, @data ) );
      $self->log->info( $tree->factor->as_string )
        if !$tree->is_start && defined $tree->factor;

      if ( grep { $tree->cmp( $_ ) == 0 } @return ) {
        next unless $self->allow_duplicates;
      }
      push( @return, $tree );
    }
  }

  return ( @return ) if scalar @return;

  return ();
}

sub BUILD {
  my ( $self ) = @_;

  my @s = @{ $self->sentence };
  my $string;
  if ( scalar @s == 1 ) {
    $string = $s[0]->daughters;
  } else {
    $string = join( ' ', map { $_->string } @s );
  }

  $self->log->debug( "Parsing string [$string]" );

  $self->{current_depth} = 0;
  $self->{cached}        = {};
}

around ingest => sub {
  my ( $orig, $self, @args ) = @_;

  my ( %params ) =
    validated_hash( \@args,
                    frompos  => { isa => 'PositiveInt',       optional => 0 },
                    category => { isa => 'SyntacticCategory', optional => 0 },
    );
  my ( $frompos, $category ) = ( @params{qw(frompos category)} );
  my $label = $category->label;

  if ( $self->{current_depth}++ >= $self->max_depth ) {
    --$self->{current_depth};
    $self->log->debug(
                'exceeded maximum recursion depth [' . $self->max_depth . ']' );
    return ();
  }

  $self->{cached}->{$frompos} = {}
    unless exists $self->{cached}->{$frompos};

  my $cache = $self->{cached}->{$frompos};

  my @result;
  if ( exists $cache->{$label} ) {

    push( @result, @{ $cache->{$label} } );

    my $num_parses = scalar @result;
    $self->log->info( "cache hit. [$frompos,$label] - $num_parses parse(s)" );
  } else {
    $cache->{$label} = \@result;

    push( @result, $self->$orig( @args ) );
  }

  my $num_tokens = scalar @{ $self->sentence };

  if ( $self->{current_depth}-- == 0 ) {

    # only execute this code after final ingestion

    my @complete = grep { $_->topos == $num_tokens } @result;

    if ( !scalar @complete && !$self->allow_partial ) {
      $self->log->debug(
               sprintf( 'Incomplete parse;  Fewer than %d tokens were ingested',
                        $num_tokens ) );
      return ();
    }

    return @complete;
  }
  return @result;
};

no Moose;
__PACKAGE__->meta->make_immutable;
