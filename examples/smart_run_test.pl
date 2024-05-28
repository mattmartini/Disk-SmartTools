#!/usr/bin/env perl

################################################################################
##  smart_runt_test.pl - run smart tests for disks                            ##
##                                                                            ##
##  Author:    Matt Martini                                                   ##
##                                                                            ##
##  Copyright ©️  2024  Matt Martini <matt.martini@imaginarywave.com>          ##
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

use FindBin qw($Bin);
use Readonly;
use Data::Printer class =>
    { expand => 'all', show_methods => 'none', parents => 0 };
use Term::ReadKey;
use Term::ANSIColor;
use IPC::Cmd qw[can_run run];

Readonly my $PROGRAM => 'smart_run_test.pl';
Readonly my $VERSION => '$Revision: 0.1 $';

########################################
#      Define Global Variables         #
########################################

$| = 1;
my $bindir = "$Bin/";

my ( $cmd, $base_cmd, $disk_prefix, @disks, $ropt, $raid, $rdisk, @rdisks );

########################################
#            Main Program              #
########################################

if ( $< != 0 ) { die "You must be root to run this program.\n" }

get_os_options();

p @disks;

p $raid;

exit(0);

########################################
#           Subroutines                #
########################################

sub get_os_options {
    my $OS   = qx(uname -s);
    my $host = qx(uname -n);

    # $raid = qx(lspci -nnd ::0104 -k) || '';
    if ( my $raid_path = can_run('lspci') ) {
        my $raid_cmd = "$raid_path -nnd ::0104";
        my $buf;
        if ( scalar run( command => $raid_cmd,
                         verbose => 0,
                         buffer  => \$buf,
                         timeout => 10
             )
            )
        {
            $raid = $buf;
        }
    } else {
        $raid = '';
    }

    foreach ($OS) {
        if (m|darwin|i) {
            if ( -f '/usr/local/bin/smartctl' ) {
                $cmd = '/usr/local/bin/smartctl';
            } elsif ( -f '/opt/homebrew/bin/smartctl' ) {
                $cmd = '/opt/homebrew/bin/smartctl';
            } else {
                die "smartctl not found.\n";
            }
            $disk_prefix = '/dev/disk';
            @disks       = qw(0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15);
        } elsif (m|linux|i) {
            $cmd         = '/usr/sbin/smartctl';
            $disk_prefix = '/dev/sd';
            @disks = qw(a b c d e f g h i j k l m n o p q r s t u v w x y z);
        } else {
            die "Operating system $OS is not supported.\n";
        }
    }

    unless ( -x $cmd ) {
        die "smart cmd $cmd not found.\n";
    }

    foreach ($host) {
        if (m/shibumi/i) {
            @disks = qw(4 5 6 7);
        } elsif (m/jemias/i) {
            @disks = qw(0);
        } elsif (m/kalofia/i) {
            @disks = qw(0);
        } elsif (m/varena/i) {
            @disks = qw(0 1 2);
        } elsif (m/cathal/i) {
            @disks  = qw(b c d e f g h);
            $rdisk  = 'a';
            @rdisks = qw(1/1/1 1/2/1 1/3/1 1/4/1 1/5/1 1/6/1 1/7/1 1/8/1);
        } elsif (m/ladros/i) {
            @disks  = qw();
            $rdisk  = 'c';
            @rdisks = qw(00 01 02 03);
        } else {

            # @disks defined by $OS
        }
    }

    return;
}
