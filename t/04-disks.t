#!/usr/bin/env perl

use Test2::V0;
use lib 'lib';

use MERM::SmartTools::Syntax;
use MERM::SmartTools::Disks qw(:all);
use MERM::SmartTools::OS    qw(:all);

plan tests => 1;

my $disk_prefix;
my $OS = get_os;
if ( $OS eq 'Linux' ) {
    $disk_prefix = '/dev/sd';
} elsif ( $OS eq 'Darwin' ) {
    $disk_prefix = '/dev/disk';
}
is( disk_prefix(), $disk_prefix,
    "disk_prefix - the correct disk prefix returns true." );

# skip_all("no tests yet.");

done_testing;
