# NAME
Disk::SmartTools - Provide tools to work with disks via S.M.A.R.T.

# VERSION
Version v2.1.8

# SYNOPSIS

This module provides tools to access the S.M.A.R.T. features of a system's disks.
It will allow the collection of information on the installed disks and *RAID* arrays.
Queries via `smartctl` will gather the current attributes of the disks.  Internal 
tests of the disks can be initiated.  

The sub-modules provide this and other utility functionality.

# SUB-MODULES
The sub-modules provide the functionality described below.  For more details see `perldoc <Sub-module_Name>`.

## Disk::SmartTools
`Disk::SmartTools` provides a loader for sub-modules where a leading `::` denotes a package to load.

    use Disk::SmartTools qw( ::Disks ::Utils );

This is equivalent to:

    use Disk::SmartTools::Disks qw(:all);
    use Disk::SmartTools::Utils qw(:all);

## Disk::SmartTools::Disks
This module provides the disk related functions.

    use Disk::SmartTools::Disks;

    my $smart_cmd = get_smart_cmd();
    my @disks = os_disks();
    my @smart_disks = get_smart_disks(@disks);
    $smart_test_started = smart_test_for($disk);

## Disk::SmartTools::Syntax
Provide consistent feature setup. Put all of the "use" setup cmds in one
place. Then import them into other modules.

Use this in other modules:

    package Disk::SmartTools::Example;

    use Disk::SmartTools::Syntax;

    # Rest of Code...

This is equivalent to:

    package Disk::SmartTools::Example;

    use feature :5.18;
    use utf8;
    use strict;
    use warnings;
    use autodie;
    use open qw(:std :utf8);
    use version;
    use Readonly;
    use Carp;
    use English qw( -no_match_vars );

    # Rest of Code...


## Disk::SmartTools::Utils


## Disk::SmartTools::OS
OS discovery and functions

    use Disk::SmartTools::OS;

    my $OS = get_os();
    my $hostname = get_hostname();
    my $system_is_linux = is_linux();

# EXAMPLES
Two example programs demonstrate how the `Disk::SmartTools` modules can be used.

## smart_show.pl
Display SMART information on disks.

    $ smart_show.pl

Asks for the type of SMART information to display then reports for each
physical disk in the system.

    Display SMART information
    -------------------------
    0 - All SMART Info
    1 - Info
    2 - Overall-Health
    3 - SelfTest History
    4 - Error Log
    5 - Temperature Graph
    6 - Power_On_Hours
    7 - Power_Cycle_Count
    8 - Temperature_Celsius
    9 - Reallocated_Sector_Ct
    a - Offline_Uncorrectable
    b - Raw_Read_Error_Rate
    c - Seek_Error_Rate

## smart_run_tests.pl
Runs a SMART test on all disks.  Typically run as a crontab.
 
    $ smart_run_tests.pl <args>

    --test_type : Length of SMART test, short (default) or long
    --dry_run : Don't actually perform SMART test
    --debug : Turn debugging on
    --verbose : Generate debugging info on stderr
    --silent : Do not print report on stdout
    --help : This helpful information.

# INSTALLATION

To install this module, run the following commands:

    perl Makefile.PL
    make
    make test
    make install

# SUPPORT AND DOCUMENTATION

After installing, you can find documentation for this module with the
perldoc command.

    perldoc Disk::SmartTools

You can also look for information at:

- [RT, CPAN's request tracker (report bugs here)](https://rt.cpan.org/NoAuth/Bugs.html?Dist=Disk-SmartTools)

- [CPAN Ratings](https://cpanratings.perl.org/d/Disk-SmartTools)

- [Search CPAN](https://metacpan.org/release/Disk-SmartTools)

# TEMPLATE

    module-starter \
        --module=Disk::SmartTools \
        --module=Disk::SmartTools::Syntax \
        --module=Disk::SmartTools::OS \
        --module=Disk::SmartTools::Utils \
        --module=Disk::SmartTools::Disks \
        --builder=ExtUtils::MakeMaker \
        --author='Matt Martini' \
        --email=matt@imaginarywave.com \
        --ignore=git \
        --license=gpl3 \
        --genlicense \
        --minperl=5.018 \
        --verbose

# LICENSE AND COPYRIGHT

This software is Copyright © 2024-2025 by Matt Martini.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

