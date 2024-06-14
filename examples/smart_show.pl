#!/usr/bin/env perl

################################################################################
##  smart_show.pl - show smart information for disks                          ##
##                                                                            ##
##  Useage:                                                                   ##
##                                                                            ##
##  Author:    Matt Martini                                                   ##
##                                                                            ##
##  Created:   20201006   v.1.0                                               ##
##                                                                            ##
##  Copyright ©️  2020-2024  Matt Martini <matt.martini@imaginarywave.com>     ##
##                                                                            ##
################################################################################

########################################
#      Requirements and Packages       #
########################################

use lib '../lib';
use MERM::SmartTools::Syntax;
use MERM::SmartTools qw( ::OS ::Disks ::Utils );

# use experimental qw( switch );    # TODO Remove switch

use FindBin qw($Bin);
use Term::ReadKey;
use Term::ANSIColor;
use IPC::Cmd qw[can_run run];

#use Term::ANSIColor qw(:constants);
use Data::Dumper;
use Data::Printer class =>
    { expand => 'all', show_methods => 'none', parents => 0 };

Readonly my $PROGRAM => 'smart_show.pl';
use version; Readonly my $VERSION => version->declare("v3.0.2");

########################################
#      Define Global Variables         #
########################################
$Data::Dumper::Indent = 3;    # pretty print with array indices

#$Term::ANSIColor::AUTORESET = 1;
local $OUTPUT_AUTOFLUSH = 1;

# my $bindir = "$Bin/";

# Default config params
my %config = (
               debug   => 0,    # debugging
               silent  => 0,    # Do not print report on stdout
               verbose => 0,    # Generate debugging info on stderr
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

my @attributes = (
                   'All SMART Info',        'Info',
                   'Overall-Health',        'SelfTest History',
                   'Error Log',             'Temperature Graph',
                   'Power_On_Hours',        'Power_Cycle_Count',
                   'Temperature_Celsius',   'Reallocated_Sector_Ct',
                   'Offline_Uncorrectable', 'Raw_Read_Error_Rate',
                   'Seek_Error_Rate'
                 );

########################################
#            Main Program              #
########################################

if ( $REAL_USER_ID != 0 ) { die "You must be root to run this program.\n" }

my $cmd_path = get_smart_cmd();
get_os_options( \%disk_info );

print colored ( "Display SMART information\n" . "-" x 26 . "\n", 'white' );

my $choice = display_menu( "Choose attribute to display: ", @attributes );
my $cmd_type
    = $choice == 1 ? ' --info '
    : $choice == 2 ? ' --health '
    : $choice == 3 ? ' --log=selftest '
    : $choice == 4 ? ' --log=error '
    : $choice == 5 ? ' --log=scttemp '
    :                ' --all ';
Readonly my $MAX_ALL_CHOICE => 5;

if ( $disk_info{ has_disks } == 1 ) {
    DISK:
    foreach my $disk ( @{ $disk_info{ disks } } ) {
        my $disk_path = $disk_info{ disk_prefix } . $disk;

        next DISK unless ( -r $disk_path );

        print colored ( $disk_path . "\n", 'bold magenta' );
        my $cmd_wargs = $cmd_path . $cmd_type . $disk_path;
        warn $cmd_wargs if $config{ debug };

        my $buf = '';
        if ( scalar run( command => $cmd_wargs, verbose => 0, buffer => \$buf ) ) {
            foreach my $line ( split( /\n/, $buf ) ) {
                if (     ( $choice <= $MAX_ALL_CHOICE )
                      || ( $line =~ m{$attributes[$choice]}i ) )
                {
                    say $line;
                }
            }
        }
        else {
            warn "Could not get info for $disk_path\n";
        }
    }
}

if ( $disk_info{ has_raid } == 1 ) {
    RDISK:
    foreach my $rdisk ( @{ $disk_info{ rdisks } } ) {
        my $rdisk_base = $disk_info{ rdisk_prefix };
        my $raid_flag  = $disk_info{ raid_flag };

        # next RDISK unless ( -r $rdisk_base );

        print colored ( $rdisk_base . ' - ' . $rdisk . "\n", 'bold magenta' );
        my $rcmd_wargs = $cmd_path . $cmd_type . $rdisk_base . $raid_flag . $rdisk;
        warn $rcmd_wargs if $config{ debug };

        my $buf = '';
        if ( scalar run( command => $rcmd_wargs, verbose => 0, buffer => \$buf ) ) {
            foreach my $line ( split( /\n/, $buf ) ) {
                if (     ( $choice <= $MAX_ALL_CHOICE )
                      || ( $line =~ m{$attributes[$choice]}i ) )
                {
                    say $line;
                }
            }
        }
        else {
            warn "Could not get info for $rdisk_base - $rdisk\n";
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
            shibumi => { disks => [ 0, 4, 5, 6, 7 ] },
            cathal  => {
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

