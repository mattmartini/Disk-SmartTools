#!/usr/bin/env perl
use 5.018;
use strict;
use warnings;
use Test::More;

plan tests => 24;

BEGIN {
    my @modules = qw(
        MERM::SmartTools
        MERM::SmartTools::Syntax
        MERM::SmartTools::Utils
        MERM::SmartTools::Disks
        MERM::SmartTools::OS
    );

    foreach my $module (@modules) {
        use_ok($module) || print "Bail out!\n";

        my $var = '$' . $module . '::VERSION';
        no warnings qw(numeric);
        my $ver = 0 + eval "$var";
        cmp_ok( $ver, '>', 0, "Version > 0 in $module" );
    }

    # Modules used by above
    my @needed_modules = qw(
        Carp
        File::Temp
        IO::Interactive
        Import::Into
        Module::Runtime
        Term::ANSIColor
        Term::ReadKey
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

diag("Testing MERM::SmartTools $MERM::SmartTools::VERSION");
diag("Perl $], $^X");

