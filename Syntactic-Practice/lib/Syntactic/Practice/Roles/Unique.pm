package Syntactic::Practice::Roles::Unique;

use Data::GUID;

use Moose::Role;
use namespace::autoclean;

has '_guid' => ( is       => 'ro',
                 isa      => 'Data::GUID',
                 lazy     => 1,
                 builder  => '_build_guid',
                 init_arg => undef, );

sub _build_guid { new Data::GUID }

1;
