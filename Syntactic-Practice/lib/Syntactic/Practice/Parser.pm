package Syntactic::Practice::Parser;

=head1 NAME

Syntactic::Practice::Parser - A natural language parser

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use Moose;
use namespace::autoclean;
use MooseX::Params::Validate;
use MooseX::Method::Signatures;

with 'MooseX::Log::Log4perl';

has max_depth => ( is      => 'ro',
                   isa     => 'PositiveInt',
                   default => 10 );

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

my $grammar = Syntactic::Practice::Grammar->new;

# method ingest ( PositiveInt :$frompos,
#                Category :$category,
#                Maybe[Tree] :$mother
#              ) {

sub ingest {
  my ( $self, %args ) = @_;
  my ( $frompos, $category, $mother ) = @args{qw( frompos category mother )};

  my $num_words = scalar( @{ $self->sentence } );
  if ( $frompos >= $num_words ) {
    $self->log->error( "insufficient words to license phrase" );
    return ();
  }

  # avoid excessive recursion
  return ()
    if ( $mother && $category && $mother->label eq $category->label );

  my $msg = '%2d: %-2s %s [%s]';

  my $rule = $grammar->rule( label => $category->label );

  unless ( $rule ) {
    $self->log->debug(
                    sprintf( 'bad rule identifier: [%s]!', $category->label ) );
    return ();
  }

  my $analysis =
    $self->{analysis}->[$frompos]->{depth}->[ $self->{current_depth} ];

  my @trees = ();
  my $terms = $rule->terms;
  foreach my $term ( @$terms ) {    # TODO: support multiple terms
    my $t_label = $term->label;
    my $t_id    = $term->id;

    if ( exists $analysis->{term}->{ $term->id } ) {
      push( @trees, @{ $analysis->{term}->{ $term->id } } );
      next;
    }

    my @daughters_list =
      $self->process_term( term     => $term,
                           frompos  => $frompos,
                           category => $category,
                           mother   => $mother );

    my $num_daughters = scalar @daughters_list;
    $self->log->debug(
        "Process_term returned $num_daughters parses for term [$t_label($t_id)]"
    );

    my @term_trees;
    while ( my $d = shift( @daughters_list ) ) {
      my @daughters;
      $self->log->debug( "Daughters: [ @$d ]" );
      my $num_daughters = scalar @daughters;
      next unless $num_daughters >= 1;

      my $tree = $self->build_tree( frompos   => $frompos,
                                    category  => $category,
                                    mother    => $mother,
                                    daughters => \@daughters, );

      if ( grep { $tree->cmp( $_ ) == 0 } @trees, @term_trees ) {
        next unless $self->allow_duplicates;
      }
      push( @term_trees, $tree );
    }
    $analysis->{term}->{ $term->id } = \@term_trees;
    push( @trees, @term_trees );
  }

  return ( @trees );
}

#   method process_factors ( PositiveInt             :$frompos!,
#                            Factor                  :$factor!,
#                            NonTerminalAbstractTree :$target!,
#                            Maybe[Tree]             :$mother,
#                            Bool                    :$do_optional=1) {
sub process_factor {
  my ( $self, %args ) = @_;
  my ( $frompos, $factor, $do_optional, $target ) =
    @args{qw( frompos factor do_optional target )};
  my $f_label    = $factor->label;
  my $f_id       = $factor->id;
  my $f_position = $factor->position;
  $do_optional //= 1;

  my $msg      = '%2d: %-2s %s [%s]';
  my $sentence = $self->sentence;

  if ( $frompos >= $sentence->[-1]->topos ) {
    $self->log->debug( "Opting not to process factors past end of sentence" );
    return;
  }
  my $lex_label = $sentence->[0]->label;

  if ( $factor->optional && $do_optional ) {
    $self->log->debug(
             "Factor [$f_label($f_id)] at position [$f_position] is optional" );

    my $next_licenses = 0;
    for ( my $f = $factor->next; defined $f; $f = $f->next ) {
      my $next_f_label    = $f->label;
      my $next_f_id       = $f->id;
      my $next_f_position = $f->position;

      if ( defined $f->licenses( $sentence->[$frompos] ) ) {
        $self->log->debug(
"Factor [$next_f_label($next_f_id)] at position [$next_f_position] licenses [$lex_label]"
        );
        $next_licenses = 1;
        last;
      }
    }

    my @non_opt_trees = grep { scalar @$_ > 0 }
      $self->process_factor( frompos     => $frompos,
                             factor      => $factor,
                             do_optional => 0, );

    my $num_results = scalar @non_opt_trees;
    $self->log->debug( "number of results: [$num_results]; array ref values: [",
                       ( map { " @$_ " } @non_opt_trees ), ']' );

    return ( @non_opt_trees ) unless $next_licenses;

    my $class = 'Syntactic::Practice::Tree::Abstract::Null';
    my $tree = $self->build_tree( class    => $class,
                                  depth    => $self->{current_depth} + 1,
                                  term     => $factor->term,
                                  category => $factor->category,
                                  factor   => $factor,
                                  frompos  => $frompos,
                                  sentence => $sentence,
                                  label    => $f_label );

    my $tset = Syntactic::Practice::Grammar::TokenSet->new();
    $tset->append_new( $tree );

    return ( [$tree], @non_opt_trees );
  }

  my $depth = $factor->licenses( $sentence->[$frompos] );
  my @tree  = ();
  unless ( defined $depth ) {
    $self->log->debug( "Factor [$f_label] does not license [$lex_label]" );
    my $string =
      join( ' ', map { $_->string } @{$sentence}[ $frompos .. $#{$sentence} ] );
    my @data = ( $frompos, $factor->label, ' ->', $string );
    $self->log->info( sprintf( $msg, @data ) );

    return ();
  }
  @tree = $self->ingest( frompos  => $frompos,
                         category => $factor->category,
                         mother   => $target, );

  my @daughter_list;
  my @tokenset_list;
  foreach my $tree ( @tree ) {

    $self->log->debug(
"Matched factor [$f_label($f_id)] at depth [$self->{current_depth}]: $tree" );
    my @data = ( $tree->frompos, $tree->label, ' ->', $tree->string );
    $self->log->info( sprintf( $msg, @data ) );

    my $tset = Syntactic::Practice::Grammar::TokenSet->new();
    $tset->append_new( $tree );

    push( @tokenset_list, $tset );

    push( @daughter_list, [$tree] );
    next unless $factor->repeat;

    $self->log->debug( "Repeat factor [$f_label]" );

    my @daughters =
      $self->process_factor( frompos     => $frompos + 1,
                             factor      => $factor,
                             do_optional => 0, );

    push( @daughter_list, @daughters );
  }

  return @daughter_list;
}

sub append_factor_daughters {
  my ( $self, %args ) = @_;
  my ( $frompos, $d_list, $factor ) = @args{qw( frompos d_list factor )};

  my $f_label = $factor->label;
  my $f_id    = $factor->id;

  my $analysis =
    $self->{analysis}->[$frompos]->{depth}->[ $self->{current_depth} ]
    ->{factor}->{$f_id};

  unless ( scalar @$analysis ) {
    my $msg =
"Factor [$f_label($f_id)] has no results at [$frompos,$self->{current_depth},$f_id].  Failing hard.";
    $self->log->error( $msg );

    die $msg;
  }

  my @f_daughters_list = @$analysis;

  my $num_term_daughters   = scalar( @$d_list );
  my $num_factor_daughters = scalar( @f_daughters_list );
  $self->log->debug( "Pre term daughters count: [$num_term_daughters]" );
  $self->log->debug( "Factor daughters count: [$num_factor_daughters]" );

  my @new_d_list;

  my $i = 1;
  foreach my $ds ( @$d_list ) {
    $self->log->debug(
            "processing factor daughters list #$i/$num_term_daughters [@$ds]" );
    my $j           = 1;
    my $max_j       = scalar @f_daughters_list;
    my @t_daughters = ( defined $ds ? @$ds : () );
    while ( my $f_daughters = shift( @f_daughters_list ) ) {

      $self->log->debug(
              "processing factor daughter list #$j/${max_j}: [@$f_daughters]" );
      push( @new_d_list, [ @t_daughters, @$f_daughters ] );
      $self->log->debug(
         "done processing factor daughter list #$j/${max_j}: [@$f_daughters]" );
      $j++;
    }
    $self->log->debug( "Factor daughters count: [$num_factor_daughters]" );
    $self->log->debug(
       "done processing factor daughters list #$i/$num_term_daughters [@$ds]" );
    $i++;
  }
  $#{$d_list} = 0;
  push( @$d_list, @new_d_list );
  $num_term_daughters = scalar( @$d_list );
}

# method process_term ( Term                           :$term!,
#                       PositiveInt                    :$frompos!,
#                       NonTerminalCategory            :$category!,
#                       Maybe[NonTerminalAbstractTree] :$mother,
#                     ) {
sub process_term {
  my ( $self, %args ) = @_;
  my ( $frompos, $term, $category ) = @args{qw( frompos term category )};

  my $t_label = $term->label;
  my $t_id    = $term->id;
  my $t_bnf   = $term->bnf;

  $self->log->debug( "Processing term [$t_label($t_id)]: $t_bnf" );

  my %tree_params = ( frompos  => $frompos,
                      depth    => $self->{current_depth},
                      sentence => $self->sentence,
                      label    => $category->label,
                      term     => $term, );

  $tree_params{category} = $category if $category;

  my ( $target );
  if ( $term->is_start ) {
    $target = $self->build_tree(
                          class => 'Syntactic::Practice::Tree::Abstract::Start',
                          %tree_params );
    $tree_params{label} = $target->label;
  } else {

#$self->log->info('Building non-start tree.  params: ', Data::Printer::p %tree_params);
    $target = $self->build_tree(
                        class => 'Syntactic::Practice::Tree::Abstract::Phrasal',
                        %tree_params );
  }

  my $curpos         = $frompos;
  my $daughters_list = [ [] ];
  my @factors        = @{ $term->factors };
  my @return;
  for ( my $i = 0; $i < scalar @factors; $i++ ) {
    my $factor = $factors[$i];

    my $f_label            = $factor->label;
    my $f_id               = $factor->id;
    my $num_term_daughters = scalar( @$daughters_list );
    $self->log->debug(
           "Processing term [$t_label($t_id)] factor #${i} [$f_label($f_id)]" );

    $self->log->debug(
          "Pre term daughters count: [$num_term_daughters]: @$daughters_list" );

    my @s       = @{ $self->sentence };
    my $lastpos = $s[-1]->topos;

    foreach my $d ( @{$daughters_list} ) {

      if ( $d && ref $d eq 'ARRAY' && $d->[0] ) {

        #        $self->log->debug(Data::Printer::p $d->[-1]);
        $curpos = $d->[-1]->topos;
        if ( $curpos == $lastpos ) {
          $self->log->debug( "Final token processed" );
          last;
        }
        $self->log->debug( "Cursor advanced" );
      }

      $self->log->debug( "Cursor at position [$curpos]" );

      my $analysis =
        $self->{analysis}->[$frompos]->{depth}->[ $self->{current_depth} ]
        ->{factor};

      my @factor_daughters;

      my $msg =
        (  'Factor data at position '
         . "[pos=$frompos,dep=$self->{current_depth},fact=$f_label($f_id)] was "
         . 'fetched %s from cache' );

      if (    exists $analysis->{$f_id}
           && ref $analysis->{$f_id} eq 'ARRAY'
           && scalar @{ $analysis->{$f_id} } )
      {
        @factor_daughters = @{ $analysis->{$f_id} };

        $self->log->debug( sprintf( $msg, '-' ) );

      } else {
        @factor_daughters =
          $self->process_factor( frompos => $curpos,
                                 factor  => $factor,
                                 target  => $target );

        $self->log->debug( sprintf( $msg, '- not -' ) );

        if ( $self->prune_nulls ) {
          my $null_class = 'Syntactic::Practice::Tree::Abstract::Null';
          my @filtered_factor_daughters;
          foreach my $f_d_list ( @factor_daughters ) {
            my @filtered_f_d_list =
              grep { !( $_->isa( $null_class ) ) } @$f_d_list;
            next unless @filtered_f_d_list;
            push( @filtered_factor_daughters, \@filtered_f_d_list );
          }
          @factor_daughters = @filtered_factor_daughters;
        }

        push( @{ $analysis->{$f_id} }, @factor_daughters );
      }

      next unless @factor_daughters;

      $self->append_factor_daughters( d_list  => $daughters_list,
                                      frompos => $frompos,
                                      factor  => $factor, );

    }

    $self->log->debug( "Post term daughters count: [$num_term_daughters]" );
  }

  my $analysis =
    $self->{analysis}->[$frompos]->{depth}->[ $self->{current_depth} ]->{term};

  $self->log->info( "Daughters list: [@$daughters_list]" );

  $analysis->{$t_id} = $daughters_list;

  return @{ $analysis->{$t_id} };
}

# method build_tree ( Factor                           :$factor!,
#                       PositiveInt                    :$frompos!,
#                       NonTerminalCategory            :$category!,
#                       Maybe[NonTerminalAbstractTree] :$mother,
#                     ) {
sub build_tree {
  my ( $self, %args ) = @_;
  my ( $frompos, $topos,    $factor, $term,  $daughters,
       $mother,  $category, $class,  $depth, $sisters )
    = @args{
    qw( frompos topos factor term daughters mother category class depth sisters)
    };

  if ( ref $daughters eq 'ARRAY' && scalar @$daughters == 1 ) {

#        next if( ( $mother && $mother->label eq $target->label ) && $target->label eq $daughters[0]->label );
  }

  my $label = $category->label;
  unless ( $class ) {
    my $cat_class = Syntactic::Practice::Util->get_cat_for_label( $label );
    $class = "Syntactic::Practice::Tree::Abstract";
    $class .= "::$cat_class" unless $cat_class eq 'Syntactic';
    $self->log->debug( "Building tree with label [$label] of class [$class]" );
  }

  my %options = ( sentence => $self->sentence,
                  category => $category, );

  if ( $category->is_start ) {
    $options{depth} = $depth = 0;
  } elsif ( $category->is_terminal ) {
    $daughters = undef;
  }

  if ( defined $daughters ) {
    $options{frompos} = $frompos = $daughters->[0]->frompos;
    $options{topos}   = $topos   = $daughters->[-1]->topos;
  }

  if ( defined $depth ) {
    if ( $depth == 0 ) {
      $options{depth}   = 0;
      $options{mother}  = $mother = undef;
      $options{frompos} = $frompos = 0;
      $options{sisters} = $sisters = undef;
    }
  }

  if ( defined $frompos ) {
    $options{frompos} = $frompos;
  }

  if ( defined $topos ) {
    $options{frompos} = $frompos;
  }

  if ( defined $mother ) {
    $options{mother} = $mother;
  }

  if ( defined $factor ) {
    $options{factor} = $factor;
    $options{term} = $term = $factor->term;
  }

  my $tset = Syntactic::Practice::Grammar::TokenSet->new();
  $options{constituents} = $tset;
  if( defined $daughters ){
    foreach my $daughter (  @$daughters ) {
      $tset->append_new( $daughter );
    }
  }

  my $tree = $class->new( %options );

  if ( defined $daughters ) {
    foreach my $sib ( @$daughters ) {
      next unless $sib->isa( 'Tree' );
      my @sibs = grep { $sib->cmp( $_ ) != 0 } @$daughters;
      $sib->sisters( \@sibs );
      $sib->mother( $tree );
    }
  }

  my @data = ( $tree->frompos, $tree->label, ' ->', $tree->string );
  my $msg = '%2d: %-2s %s [%s]';

  $self->log->info( sprintf( $msg, @data ) );
  $self->log->info( "$factor" ) if defined $factor;

  return $tree;
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
  $self->{analysis}      = [];

  foreach my $lexeme ( @s ) {
    my $label   = $lexeme->label;
    my $frompos = $lexeme->frompos;
    $self->log->debug( "pre-caching: $frompos -> $label" );
    $self->{cached}->{$frompos} = { $label   => [$lexeme],
                                    terminal => $lexeme };
    $self->{analysis}->[$frompos]->{depth} = [];
  }

  return $self;
}

sub _incr_depth {
  my ( $self ) = @_;

  if ( $self->{current_depth} >= $self->{max_depth} ) {
    $self->log->debug(
                'exceeded maximum recursion depth [' . $self->max_depth . ']' );
    return undef;
  }

  ++$self->{current_depth};
}

sub _decr_depth {
  my ( $self ) = @_;
  --$self->{current_depth};
}

around process_factor => sub {
  my ( $orig, $self, @args ) = @_;

  return () unless defined $self->_incr_depth;

  my @daughters = $self->$orig( @args );

  $self->_decr_depth;

  return @daughters;
};

around ingest => sub {
  my ( $orig, $self, @args ) = @_;

  my ( %params ) =
    validated_hash( \@args,
                    frompos  => { isa => 'PositiveInt', optional => 0 },
                    category => { isa => 'Category',    optional => 0 },
                    mother   => { isa => 'Maybe[Tree]', optional => 0 }, );

  my ( $frompos, $category, $mother ) =
    ( @params{qw(frompos category mother)} );
  my $label = $category->label;

  my $depth = $self->_incr_depth;
  return unless defined $depth;

  my $analysis = $self->{analysis}->[$frompos]->{depth};

  $analysis->[ $self->{current_depth} ] = { factor => {},
                                            term   => {},
                                            label  => {} }
    unless exists $analysis->[ $self->{current_depth} ];

  $analysis = $analysis->[ $self->{current_depth} ];

  $self->{cached}->{$frompos} = {}
    unless exists $self->{cached}->{$frompos};

  my $cache = $self->{cached}->{$frompos};

  my @data = ( $frompos, $label );
  my $msg = '%2d: %-2s %s [%s]';

  my @result;

  if ( $category->is_terminal ) {
    my $tree = $cache->{terminal};
    my %tree_params = ( frompos  => $frompos,
                        mother   => $mother,
                        depth    => $self->{current_depth},
                        sentence => $self->sentence );

    push( @result, $tree->new( %$tree, %tree_params ) )
      if $label eq $tree->label;

  } else {

    if ( exists $cache->{$label} && $cache->{$label} ne 'incomplete' ) {

      push( @result, @{ $cache->{$label} } );

      my $num_parses = scalar @result;
      $self->log->info( "cache hit. [$frompos,$label] - $num_parses parse(s)" );
    } else {
      if ( exists $cache->{$label} && $cache->{$label} eq 'incomplete' ) {
        $self->log->info(
          "cache re-miss. [$frompos,$label] - depth [$self->{current_depth}]" );
      } else {
        $cache->{$label} = 'incomplete';
        $self->log->info(
             "cache miss. [$frompos,$label] - depth [$self->{current_depth}]" );
      }
      push( @result, $self->$orig( @args ) );
      $cache->{$label} = [@result];
      my $num_parses = scalar @result;
      $self->log->info(
"cache filled at [$frompos,$label] - $num_parses parse(s) ; depth [$self->{current_depth}]"
      );

    }

    my @filtered;
    while ( my $tree = shift( @result ) ) {
      next
        if ( !$self->allow_duplicates && grep { $tree->cmp( $_ ) == 0 }
             @result );

      push( @filtered, $tree );
    }
    @result = @filtered;
  }

  $analysis->{label}->{$label} = \@result;

  $depth = $self->_decr_depth();

  if ( $depth == 0 ) {

    # only execute this code after final ingestion

    if ( !$self->allow_partial ) {
      my $num_tokens = scalar @{ $self->sentence };
      my @complete;
      foreach my $r ( @result ) {
        push( @complete, $r ) if $r->topos == $num_tokens;
        $self->log->debug( Data::Printer::p $r );
      }

      my $num_complete = scalar @complete;
      if ( !scalar @complete ) {
        $self->log->debug(
             sprintf( 'Incomplete parse;  %d tokens were ingested.  %d needed.',
                      $num_complete, $num_tokens,
             ) );
        return ();
      }
      @result = @complete;
    }

    #@result = map { $_->to_concrete } @result;
  }

  if ( scalar @result ) {
    foreach my $tree ( @result ) {
      $self->log->info( sprintf( $msg, @data, ' ->', $tree->string ) );
    }
  } else {
    my @s = @{ $self->sentence };
    my $string = join( ' ', map { $_->string } @s[ $frompos .. $#s ] );
    $self->log->info( sprintf( $msg, @data, '!->', $string ) );
  }
  return @result;
};

__PACKAGE__->meta->make_immutable;
