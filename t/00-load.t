#!/usr/bin/env perl
use 5.018;
use strict;
use warnings;
use version;
use Test::More;

plan tests => 21;

BEGIN {
    my @modules = qw(
        Disk::SmartTools
    );

    foreach my $module (@modules) {
        use_ok($module) || print "Bail out!\n";

        my $var        = '$' . $module . '::VERSION';
        my $module_ver = eval "$var" or 0;
        my $ver        = version->parse("$module_ver")->numify;
        cmp_ok( $ver, '>', 0, "Version $ver > 0 in $module" );
    }

    # Modules used by above
    my @needed_modules = qw(
        Dev::Util
        Carp
        Exporter
        File::Temp
        IO::Interactive
        Import::Into
        Module::Runtime
        Term::ANSIColor
        Term::ReadKey
        Readonly
        English
        IPC::Cmd
    );

    foreach my $module (@needed_modules) {
        use_ok($module) || print "Bail out!\n";
    }

    # Moudules used for testing
    my @testing_modules = qw(
        ExtUtils::Manifest
        File::Compare
        File::Path
        FindBin
        Socket
        Test2::Tools::Ref
        Test::More
    );

    foreach my $module (@testing_modules) {
        use_ok($module) || print "Bail out!\n";
    }
}

my $module_version
    = version->parse(qq($Disk::SmartTools::VERSION))->stringify;
diag("Testing Disk::SmartTools $module_version");
diag("Perl $PERL_VERSION, $EXECUTABLE_NAME");

