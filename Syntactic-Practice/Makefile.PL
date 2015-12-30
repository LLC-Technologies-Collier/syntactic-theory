use 5.006;
use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'Syntactic::Practice',
    AUTHOR           => q{C.J. Adams-Collier <cjac@colliertech.org>},
    VERSION_FROM     => 'lib/Syntactic/Practice.pm',
    ABSTRACT_FROM    => 'lib/Syntactic/Practice.pm',
    LICENSE          => 'Perl_5',
    EXE_FILES        => ['bin/parse'],
    PL_FILES         => {},
    MIN_PERL_VERSION => 5.006,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More' => 0,
    },
    PREREQ_PM => {
        #'ABC'              => 1.6,
        #'Foo::Bar::Module' => 5.0401,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Syntactic-Practice-*' },
);
