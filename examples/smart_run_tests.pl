#!/usr/bin/env perl

################################################################################
##  smart_runt_tests.pl - run smart tests for disks                           ##
##                                                                            ##
##  Author:    Matt Martini                                                   ##
##                                                                            ##
##  Copyright ©️  2024  Matt Martini <matt.martini@imaginarywave.com>          ##
##                                                                            ##
################################################################################

########################################
#      Requirements and Packages       #
########################################

use lib '../lib';
use MERM::SmartTools::Syntax;
use MERM::SmartTools qw( ::OS ::Disks ::Utils );

use Term::ANSIColor;
use IPC::Cmd qw[can_run run];

use Data::Printer class =>
    { expand => 'all', show_methods => 'none', parents => 0 };

Readonly my $PROGRAM => 'smart_run_tests.pl';
use version; Readonly my $VERSION => version->declare("v2.0.5");

########################################
#      Define Global Variables         #
########################################

my $date = sprintf(
                    "%04d%02d%02d",
                    sub { ( $_[5] + 1900, $_[4] + 1, $_[3] ) }
                    ->( localtime() )
                  );

# Default config params
my %config = (
               test_type => 'short',
               debug     => 1,         # debugging
               silent    => 0,         # Do not print report on stdout
               verbose   => 0,         # Generate debugging info on stderr
               dry_run   => 1,         # don't actually do the test
             );

my %disk_info = (
                  has_disks    => 0,
                  disks        => [],
                  disk_prefix  => '',
                  has_raid     => 0,
                  raid_flag    => '',
                  rdisk_prefix => '',
                  rdisks       => [],
                );

Readonly my $SLEEP_TIME => 5;

########################################
#            Main Program              #
########################################

# if ( $REAL_USER_ID != 0 ) { die "You must be root to run this program.\n" }

my $cmd_path = get_smart_cmd();
get_os_options( \%disk_info );

banner sprintf "%s - %s - %s - %s", 'S.M.A.R.T. test',
    $config{ test_type },
    get_hostname(), $date;

if ( $disk_info{ has_disks } == 1 ) {
    DISK:
    foreach my $disk ( @{ $disk_info{ disks } } ) {
        my $disk_path = $disk_info{ disk_prefix } . $disk;

        next DISK unless ( file_is_block($disk_path) );

        # print colored ( $disk_path . "\n", 'bold magenta' );
        say $disk_path;
        my $cmd_run_test
            = $cmd_path . ' --test=' . $config{ test_type } . ' ' . $disk_path;
        say $cmd_run_test if $config{ debug };
        next DISK         if $config{ dry_run };

        my $buf = '';
        if ( scalar run( command => $cmd_run_test, verbose => 0, buffer => \$buf ) ) {
            sleep $SLEEP_TIME;
            my $cmd_review_test = $cmd_path . ' -l selftest ' . $disk_path;

            my $buff = '';
            if (
                  scalar run( command => $cmd_review_test, verbose => 0, buffer => \$buff ) )
            {
                LINE:
                foreach my $line ( split( /\n/, $buff ) ) {
                    if ( $line =~ m{# 1}i ) {
                        print $line . "\n\n";
                    }
                }
            }
            else {
                warn "Could not retreive test result of $disk_path\n";
            }
        }
        else {
            warn "Could not get info for $disk_path\n";
        }
    }
}

if ( $disk_info{ has_raid } == 1 ) {
    DISK:
    foreach my $rdisk ( @{ $disk_info{ rdisks } } ) {
        my $rdisk_base = $disk_info{ rdisk_prefix };
        my $raid_flag  = $disk_info{ raid_flag };

        # next RDISK unless ( file_is_block($rdisk_base) );

        # print colored ( $disk_path . "\n", 'bold magenta' );
        say $rdisk_base;
        my $rcmd_run_test
            = $cmd_path
            . ' --test='
            . $config{ test_type } . ' '
            . $rdisk_base
            . $raid_flag
            . $rdisk;
        say $rcmd_run_test if $config{ debug };
        next RDISK         if $config{ dry_run };

        my $buf = '';
        if ( scalar run( command => $rcmd_run_test, verbose => 0, buffer => \$buf ) )
        {
            sleep $SLEEP_TIME;
            my $rcmd_review_test
                = $cmd_path . ' -l selftest ' . $rdisk_base . $raid_flag . $rdisk;

            my $buff = '';
            if (
                  scalar run( command => $rcmd_review_test, verbose => 0, buffer => \$buff ) )
            {
                LINE:
                foreach my $line ( split( /\n/, $buff ) ) {
                    if ( $line =~ m{# 1}i ) {
                        print $line . "\n\n";
                    }
                }
            }
            else {
                warn "Could not retreive test result of $rdisk_base\n";
            }
        }
        else {
            warn "Could not get info for $rdisk_base\n";
        }
    }
}

exit(0);

########################################
#           Subroutines                #
########################################
sub get_os_options {
    my ($disk_info_ref) = @_;
    my ( @disks, @smart_disks, $disk_prefix );

    my $OS   = get_os();
    my $host = get_hostname();
    $host =~ s{\A (.*?) [.] .* \z}{$1}xms;    # remove domain part of hostname

    $disk_prefix = get_disk_prefix();

    if (is_mac) {
        @disks = get_physical_disks();
    }
    else {
        @disks = os_disks();
    }

    @smart_disks = get_smart_disks(@disks);
    if ( scalar @smart_disks > 0 ) {
        $disk_info_ref->{ has_disks } = 1;
    }

    foreach my $smart_disk (@smart_disks) {
        $smart_disk =~ s{$disk_prefix(.+)}{$1};
    }

    $disk_info_ref->{ disks }       = \@smart_disks;
    $disk_info_ref->{ disk_prefix } = $disk_prefix;
    $disk_info_ref->{ raid_flag }   = get_raid_flag();

    # { disks => [ 0, 4, 5, 6, 7 ], rdisk => $EMPTY_STR, rdisks => [] },

    my %host_config_for
        = (
            cathal => {
                has_disks    => 1,
                disks        => [ 'b', 'c', 'd', 'e', 'f', 'g', 'h' ],
                has_raid     => 1,
                rdisk_prefix => '/dev/sda',
                rdisks       => [
                            '1/1/1', '1/2/1', '1/3/1', '1/4/1', '1/5/1', '1/6/1', '1/7/1',
                            '1/8/1'
                          ],
                      },
            ladros => { has_disks    => 1,
                        disks        => ['a'],
                        has_raid     => 1,
                        rdisk_prefix => '/dev/bus/2',
                        rdisks       => [ '00', '01', '02', '03' ]
                      }

          );

    if ( defined $host_config_for{ $host } ) {
        foreach my $key ( keys %{ $host_config_for{ $host } } ) {
            $disk_info_ref->{ $key } = $host_config_for{ $host }->{ $key };
        }
    }

    p $disk_info_ref if $config{ debug };

    return;
}
