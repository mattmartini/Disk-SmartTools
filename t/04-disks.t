#!/usr/bin/env perl

use Test2::V0;
use lib 'lib';

use MERM::SmartTools::Syntax;
use MERM::SmartTools::Utils qw(:all);
use MERM::SmartTools::OS    qw(:all);
use MERM::SmartTools::Disks qw(:all);

# plan tests => 2;

# disk_prefix
my $expected_disk_prefix;
my $OS = get_os();
if ( $OS eq 'Linux' ) {
    $expected_disk_prefix = '/dev/sd';
} elsif ( $OS eq 'Darwin' ) {
    $expected_disk_prefix = '/dev/disk';
}

my $prefix = disk_prefix();
is( $prefix, $expected_disk_prefix,
    "disk_prefix - the correct disk prefix returns true." );

# os_disks
my @expected_list = qw(0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15);
my @list          = os_disks();
is( @list, @expected_list, "os_disks - list of os disks is correct." );

# get_smart_cmd
my $smart_cmd = get_smart_cmd();
ok( file_executable($smart_cmd), "get_smart_cmd - smart cmd is executable." );

# get_raid_cmd
if ( is_linux() ) {
    my $raid_cmd = get_raid_cmd();
    $raid_cmd =~ s| .*$||;
    ok( file_executable($raid_cmd),
        "get_raid_cmd - raid cmd is executable." );
}

# get_diskutil_cmd
if ( is_mac() ) {
    my $diskutil_cmd = get_diskutil_cmd();
    ok( file_executable($diskutil_cmd),
        "get_diskutil_cmd - diskutil cmd is executable." );
}

# get_softraidtool_cmd
if ( is_mac() ) {
    my $softraidtool_cmd = get_softraidtool_cmd();
    ok( file_executable($softraidtool_cmd),
        "get_softraidtool_cmd - softraidtool cmd is executable." );
}

done_testing;
