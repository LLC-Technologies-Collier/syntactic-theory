package Syntactic::Practice::Constituent;

use Syntactic::Practice::Types;
use Moose;

my %constByNameByLabel = ();

has name => ( is  => 'ro',
              isa => 'Str' );

has label => ( is       => 'ro',
               isa      => 'Str',
               required => 1, );

has decomposition => ( is      => 'ro',
                       isa     => 'ArrayRef',
                       default => sub { [] }, );

has sentence => ( is       => 'ro',
                  isa      => 'ArrayRef',
                  required => 1 );

has frompos => ( is       => 'ro',
                 isa      => 'PositiveInt',
                 required => 1, );

has topos => ( is  => 'ro',
               isa => 'PositiveInt' );

has cat_type => ( is       => 'ro',
                  isa      => 'SynCatType',
                  required => 1 );

around 'new' => sub {
  my ( $orig, $self, @arg ) = @_;

  my $arg;
  if ( scalar @arg == 1 && ref $arg[0] eq 'HASH' ) {
    $arg = $arg[0];
  } else {
    $arg = {@arg};
  }

  $constByNameByLabel{ $arg->{label} } = {}
    unless exists $constByNameByLabel{ $arg->{label} };

  my $last_wordpos = scalar $#{ $arg->{sentence} };

  if ( exists $arg->{name} ) {
    die "Constituent name $arg->{name} is already taken."
      if ( exists $constByNameByLabel{ $arg->{label} }->{ $arg->{name} } );
  } else {
    $arg->{name} =
      $arg->{label} . scalar keys %{ $constByNameByLabel{ $arg->{label} } };
  }

  if ( exists $arg->{topos} ) {
    if ( $arg->{topos} < $arg->{frompos} ) {
      Carp::cluck( 'To and From positions are being reversed' );
      my $tmp = $arg->{topos};
      $arg->{topos}   = $arg->{frompos};
      $arg->{frompos} = $tmp;
    }
  } else {
    $arg->{topos} = $arg->{frompos} + 1;
  }

  $constByNameByLabel{ $arg->{label} }->{ $arg->{name} } =
    $self->$orig( %$arg );
};

sub cmp {
  my ( $self, $other ) = @_;

  my $result;
  foreach my $attribute ( qw(label frompos topos cat_type) ) {
    $result = $self->$attribute cmp $other->$attribute;
    return $result unless $result == 0;
  }

  my ( @self_decomp, my @other_decomp );
  if ( $self->cat_type eq 'lexical' ) {
    @self_decomp = @{ $self->decomposition };
    @other_decomp = @{ $other->decomposition };
    for ( my $decomp_num = 0; $decomp_num < scalar @self_decomp; $decomp_num++ ) {
      $result = ( $self_decomp[$decomp_num] cmp $other_decomp[$decomp_num] );
      return $result unless $result == 0;
    }
  } elsif ( $self->cat_type eq 'phrasal' ) {
    @self_decomp = grep { $_->frompos != $_->topos } @{ $self->decomposition };
    @other_decomp = grep { $_->frompos != $_->topos } @{ $other->decomposition };
    for ( my $decomp_num = 0; $decomp_num < scalar @self_decomp; $decomp_num++ ) {
      $result =
        $self_decomp[$decomp_num]->cmp( $other_decomp[$decomp_num] );
      return $result unless $result == 0;
    }
  }

  $result = scalar @self_decomp <=> scalar @other_decomp;
  return $result unless $result == 0;

  return 0;
}

sub as_forest {
  my ( $self, $depth ) = @_;
  return '' if $self->frompos == $self->topos;
  $depth = 0 unless $depth;
  my $indent = " " x ( $depth * 2 );

  my $output = "";
  my @decomp =
    grep { !ref $_ || $_->frompos != $_->topos } @{ $self->decomposition };

  $output .= "${indent}[".$self->label."\n${indent}";
  if ( $self->cat_type eq 'phrasal' ) {
    foreach my $d ( @decomp ) {
      next if ( $d->frompos == $d->topos );
      $output .= $d->as_forest( $depth + 1 );
    }
    $output .= "\n${indent}";
  } elsif ( $self->cat_type eq 'lexical' ) {
    $output .= "[@decomp] ";
  }
  $output .= "]";
  return $output;
}

sub as_text {
  my ( $self, $depth ) = @_;
  my $output = '';

  $depth = 0 unless $depth;

  die "too deep!" if $depth > 5;

  my $indent = " " x ( $depth * 2 );
  my $is_empty = $self->frompos == $self->topos;
  $output .= $indent . $self->name . ": ";

  if ( $self->cat_type eq 'lexical' ) {
    $output .= $self->word . "\n" unless $is_empty;
    return $output;
  }
  my @decomp =
    grep { $_->frompos != $_->topos } @{ $self->decomposition };
  $output .= join( ' ', map { $_->label } @decomp ) . "\n";

  foreach my $d ( @decomp ) {
    $output .= $d->as_text( $depth + 1 ) unless $is_empty;
  }
  return $output;
}


no Moose;

#__PACKAGE__->meta->make_immutable;
1;
