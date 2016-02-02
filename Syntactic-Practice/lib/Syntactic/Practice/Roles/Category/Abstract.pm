package Syntactic::Practice::Roles::Category::Abstract;

use Moose::Role;
use namespace::autoclean;

with 'Syntactic::Practice::Roles::Category';

my $rs_namespace = Syntactic::Practice::Util->get_rs_namespace();

my $rs_class  = 'SyntacticCategory';
my $cat_class = 'Syntactic::Practice::Grammar::Category';

has 'label' => ( is      => 'rw',
                 isa     => 'SyntacticCategoryLabel',
                 lazy    => 1,
                 builder => '_build_label' );

has 'is_start' => ( is      => 'rw',
                    isa     => 'Bool',
                    lazy    => 1,
                    builder => '_build_is_start' );

has 'is_terminal' => ( is      => 'rw',
                       isa     => 'Bool',
                       lazy    => 1,
                       builder => '_build_is_terminal' );


no Moose;
__PACKAGE__->meta->make_immutable();
