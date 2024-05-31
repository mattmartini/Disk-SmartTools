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

use lib '../lib';
use MERM::SmartTools::Syntax;
use MERM::SmartTools        qw( ::OS ::Disks );
use MERM::SmartTools::Utils qw(:all);

use English;
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
local $OUTPUT_AUTOFLUSH = 1;
my $bindir = "$Bin/";

my ( $cmd, $base_cmd, $disk_prefix, @disks, $ropt, $raid, $rdisk, @rdisks );

########################################
#            Main Program              #
########################################

if ( $REAL_USER_ID != 0 ) { die "You must be root to run this program.\n" }

print "===---------------------------------------------===\n";

get_os_options();

say "disks:";
p @disks;

say "raid";
p $raid;

# say "possible disks";
# my @possible_disks = os_disks();
# p @possible_disks;

say "disk prefix";
my $disk_pre = disk_prefix();
p $disk_pre;

say "smart cmd";
my $smart_cmd = get_smart_cmd();
p $smart_cmd;

say "raid_cmd";
my $raid_cmd = get_raid_cmd();
p $raid_cmd;

say "softraid cmd";
my $softraid_cmd = get_softraidtool_cmd();
p $softraid_cmd;

say "diskutil cmd";
my $diskutil_cmd = get_diskutil_cmd();
p $diskutil_cmd;

exit(0);

########################################
#           Subroutines                #
########################################

sub get_os_options {
    my $OS   = get_os();
    my $host = get_hostname();

    # $raid = qx(lspci -nnd ::0104 -k) || $EMPTY_STR;
    my $raid_cmd = get_raid_cmd();
    say "raid cmd";
    p $raid_cmd;
    if ($raid_cmd) {
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
        $raid = $EMPTY_STR;
    }

    $cmd = get_smart_cmd();

    @disks = os_disks();

    unless ( -x $cmd ) {
        die "Smart cmd $cmd not found.\n";
    }

    my %host_config_for
        = (
            shibumi => { disks => [ 4, 5, 6, 7 ], rdisk => $EMPTY_STR, rdisks => [] },
            jemias  => { disks => [0],            rdisk => $EMPTY_STR, rdisks => [] },
            kalofia => { disks => [0],            rdisk => $EMPTY_STR, rdisks => [] },
            varena  => { disks => [ 0, 1, 2 ],    rdisk => $EMPTY_STR, rdisks => [] },
            cathal  => {
                disks  => [ 'b', 'c', 'd', 'e', 'f', 'g', 'h' ],
                rdisk  => 'a',
                rdisks => [
                            '1/1/1', '1/2/1', '1/3/1', '1/4/1', '1/5/1', '1/6/1', '1/7/1',
                            '1/8/1'
                          ],
                      },
            ladros => { disks  => [],
                        rdisk  => 'c',
                        rdisks => [ '00', '01', '02', '03' ]
                      }

          );
    p %host_config_for;
    say "host:";
    p $host;
    if ( defined $host_config_for{ $host } ) {
        @disks = $host_config_for{ $host }->{ disks };
    }

    return;
}
