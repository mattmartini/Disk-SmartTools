use 5.018;
use strict;
use warnings;
use ExtUtils::MakeMaker;

my %WriteMakefileArgs
    = (
        NAME               => 'Disk::SmartTools',
        AUTHOR             => q{Matt Martini <matt@imaginarywave.com>},
        VERSION_FROM       => 'lib/Disk/SmartTools.pm',
        ABSTRACT_FROM      => 'lib/Disk/SmartTools.pm',
        LICENSE            => 'gpl_3',
        MIN_PERL_VERSION   => '5.018',
        BUILD_REQUIRES     => { 'ExtUtils::MakeMaker' => '0', },
        CONFIGURE_REQUIRES => { 'ExtUtils::MakeMaker' => '0', },
        EXE_FILES          => [ 'bin/smart_show.pl', 'bin/smart_run_tests.pl' ],
        PREREQ_PM          => {
                       'Carp'            => '0',
                       'English'         => '0',
                       'Exporter'        => '0',
                       'File::Temp'      => '0',
                       'IO::Interactive' => '0',
                       'IPC::Cmd'        => '0',
                       'Import::Into'    => '0',
                       'List::Util'      => '0',
                       'Module::Runtime' => '0',
                       'Readonly'        => '0',
                       'Term::ANSIColor' => '0',
                       'Term::ReadKey'   => '0',
                       'autodie'         => '0',
                       'strict'          => '0',
                       'utf8'            => '0',
                       'version'         => '0',
                       'warnings'        => '0',
                     },
        TEST_REQUIRES => { 'English'            => '0',
                           'ExtUtils::Manifest' => '0',
                           'FindBin'            => '0',
                           'Socket'             => '0',
                           'Test2::V0'          => '0',
                           'Test::More'         => '0',
                         },
        MAN1PODS => { 'bin/smart_show.pl'      => 'blib/man1/smart_show.1',
                      'bin/smart_run_tests.pl' => 'blib/man1/smart_run_tests.1'
                    },
        dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
        clean => { FILES    => 'Disk-SmartTools-*' },
      );

# Compatibility with old versions of ExtUtils::MakeMaker
unless ( eval { ExtUtils::MakeMaker->VERSION('6.64'); 1 } ) {
    my $test_requires = delete $WriteMakefileArgs{ TEST_REQUIRES } || {};
    @{ $WriteMakefileArgs{ PREREQ_PM } }{ keys %$test_requires }
        = values %$test_requires;
}

unless ( eval { ExtUtils::MakeMaker->VERSION('6.55_03'); 1 } ) {
    my $build_requires = delete $WriteMakefileArgs{ BUILD_REQUIRES } || {};
    @{ $WriteMakefileArgs{ PREREQ_PM } }{ keys %$build_requires }
        = values %$build_requires;
}

delete $WriteMakefileArgs{ CONFIGURE_REQUIRES }
    unless eval { ExtUtils::MakeMaker->VERSION('6.52'); 1 };
delete $WriteMakefileArgs{ MIN_PERL_VERSION }
    unless eval { ExtUtils::MakeMaker->VERSION('6.48'); 1 };
delete $WriteMakefileArgs{ LICENSE }
    unless eval { ExtUtils::MakeMaker->VERSION('6.31'); 1 };

WriteMakefile(%WriteMakefileArgs);

