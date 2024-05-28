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

use 5.018;

use utf8;
use strict;
use warnings;
use autodie;
use open qw(:std :utf8);
use experimental qw( switch );

use FindBin qw($Bin);
use Readonly;
use Term::ReadKey;
use Term::ANSIColor;
use IPC::Cmd qw[can_run run];

#use Term::ANSIColor qw(:constants);
use Data::Dumper;
use Data::Printer class =>
    { expand => 'all', show_methods => 'none', parents => 0 };

Readonly my $PROGRAM => 'smart_show.pl';
Readonly my $VERSION => '$Revision: 2.2 $';

########################################
#      Define Global Variables         #
########################################
$Data::Dumper::Indent = 3;    # pretty print with array indices

#$Term::ANSIColor::AUTORESET = 1;
$| = 1;
my $bindir = "$Bin/";

# Default config params
my %config = (
               debug   => 0,    # debugging
               silent  => 0,    # Do not print report on stdout
               verbose => 0     # Generate debugging info on stderr
             );

my ( $cmd_path, $cmd, $disk_prefix, @disks, $ropt, $raid, $rdisk, @rdisks );

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

if ( $< != 0 ) { die "You must be root to run this program.\n" }

get_os_options();
$cmd = $cmd_path;

print colored ( "Display SMART information\n" . "-" x 26 . "\n", 'white' );

my $choice = menu();

if ( $choice == 1 ) {
    $cmd .= ' --info ';
    $choice = 0;
}
elsif ( $choice == 2 ) {
    $cmd .= ' --health ';
}
elsif ( $choice == 3 ) {
    $cmd .= ' --log=selftest ';
    $choice = 0;
}
elsif ( $choice == 4 ) {
    $cmd .= '  --log=error ';
    $choice = 0;
}
elsif ( $choice == 5 ) {
    $cmd .= ' --log=scttemp ';
    $choice = 0;
}
else {
    $cmd .= ' --all ';
}

# @disks = qw(4);
foreach my $disk (@disks) {
    next unless ( -r "$disk_prefix$disk" );
    print colored ( $disk_prefix . $disk . "\n", 'bold magenta' );
    my $cmd_wargs = $cmd . $disk_prefix . $disk;

# system(   $cmd_path . ' --smart=on ' . $disk_prefix . $disk . ' > /dev/null ' );
    my $buf = '';
    if ( scalar run( command => $cmd_wargs, verbose => 0, buffer => \$buf ) ) {
        foreach my $line ( split( /\n/, $buf ) ) {
            if (     ( $choice == 0 )
                  || ( $line =~ m|$attributes[$choice]|i ) )
            {
                say $line;
            }
        }
    }
    else {
        warn "Could not get info for $disk_prefix$disk\n";
    }
}

if ( $raid =~ 'RAID' ) {
    if ( $raid =~ m|HighPoint|i ) {
        $ropt = ' -d hpt,';
    }
    elsif ( $raid =~ m|MegaRAID|i ) {
        $ropt = ' -d sat+megaraid,';
    }
    else {
        ##FIXME - added with perltidy -ame
    }
    foreach my $disk (@rdisks) {
        next unless ( -r "$disk_prefix$rdisk" );
        print colored ( $disk_prefix . $rdisk . " " . $disk . "\n", 'bold magenta' );
        open( my $fh, '-|', $cmd . $disk_prefix . $rdisk . $ropt . $disk );
        while ( my $line = <$fh> ) {
            if ( ( $choice == 0 ) || ( $line =~ m|$attributes[$choice]|i ) ) {
                print $line;
            }
        }

        # close($fh);
    }
}

exit(0);

########################################
#           Subroutines                #
########################################

sub menu {
    my $j;
    for ( my $i = 0; $i <= $#attributes; $i++ ) {
        if ( $i < 10 ) {
            $j = $i;
        }
        else {
            $j = chr( 87 + $i );
        }
        printf( "  %s - %s\n", $j, $attributes[$i] );
    }

    print colored ( "Choose attribute to display: ", 'blue' );
    return get_keypress();
}

sub get_keypress {
    open( my $TTY, '<', "/dev/tty" );
    ReadMode "raw";
    my $key  = ReadKey 0, $TTY;
    my $kval = ord($key) - 48;
    ReadMode "normal";
    close($TTY);
    print "$key\n";

    if ( $kval == -38 ) { $kval = 0; }
    if ( $kval >= 49 )  { $kval -= 39; }
    if ( $kval < 0 || $kval > $#attributes ) {
        die "Invalid choice.\n";
    }
    return $kval;
}

sub get_os_options {
    my $OS   = qx(uname -s);
    my $host = qx(uname -n);

    if ( my $raid_path = can_run('lspci') ) {
        my $raid_cmd = "$raid_path -nnd ::0104";
        my $buf;
        if (
              scalar run(
                          command => $raid_cmd,
                          verbose => 0,
                          buffer  => \$buf,
                          timeout => 10
                        )
           )
        {
            $raid = $buf;
        }
    }
    else {
        $raid = '';
    }

    $cmd_path = can_run('smartctl') or die "smarctl command not found.\n";

    foreach ($OS) {
        if (m|darwin|i) {
            $disk_prefix = '/dev/disk';
            @disks       = qw(0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15);
        }
        elsif (m|linux|i) {
            $disk_prefix = '/dev/sd';
            @disks       = qw(a b c d e f g h i j k l m n o p q r s t u v w x y z);
        }
        else {
            die "Operating system $OS is not supported.\n";
        }
    }

    foreach ($host) {
        if (m/shibumi/i) {
            @disks = qw(4 5 6 7);
        }
        elsif (m/jemias/i) {
            @disks = qw(0);
        }
        elsif (m/kalofia/i) {
            @disks = qw(0);
        }
        elsif (m/varena/i) {
            @disks = qw(0 1 2);
        }
        elsif (m/cathal/i) {
            @disks  = qw(b c d e f g h);
            $rdisk  = 'a';
            @rdisks = qw(1/1/1 1/2/1 1/3/1 1/4/1 1/5/1 1/6/1 1/7/1 1/8/1);
        }
        elsif (m/ladros/i) {
            @disks  = qw();
            $rdisk  = 'c';
            @rdisks = qw(00 01 02 03);
        }
        else {

            # @disks defined by $OS
        }
    }

    return;
}

