package Syntactic::Practice::Constituent;

use Syntactic::Practice::Types;
use Moose;

my %constByNameByLabel = ();

has name => ( is  => 'ro',
              isa => 'Str' );

has label => ( is       => 'ro',
               isa      => 'Str',
               required => 1, );

has decomposition => ( is  => 'ro',
                       isa => 'ArrayRef',
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

  $constByNameByLabel{ $arg->{label} } = {} unless exists $constByNameByLabel{ $arg->{label} };

  my $last_wordpos = scalar $#{ $arg->{sentence} };

  if ( exists $arg->{name} ) {
    die "Constituent name $arg->{name} is already taken."
      if ( exists $constByNameByLabel{ $arg->{label} }->{ $arg->{name} } );
  } else {
    $arg->{name} = $arg->{label} . scalar keys %{ $constByNameByLabel{ $arg->{label} } };
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

  $constByNameByLabel{ $arg->{label} }->{ $arg->{name} } = $self->$orig( %$arg );
};

no Moose;
#__PACKAGE__->meta->make_immutable;
1;
