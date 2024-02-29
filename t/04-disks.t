#!/usr/bin/env perl

use Test2::V0;
use lib 'lib';

use MERM::SmartTools::Syntax;
use MERM::SmartTools::Disks qw(:all);
use MERM::SmartTools::OS    qw(:all);

plan tests => 2;

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

my @expected_list = qw(0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15);
my @list = os_disks();
is( @list, @expected_list, "os_disks - list of os disks is correct.");

# skip_all("no tests yet.");

done_testing;
