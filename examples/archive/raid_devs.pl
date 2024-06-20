#!/usr/bin/env perl

use 5.018;
use strict;
use warnings;

use Sys::Filesystem;
use Data::Printer class =>
    { expand => 'all', show_methods => 'none', parents => 0 };

my $fs          = Sys::Filesystem->new();
my @filesystems = $fs->filesystems( mounted => 1 );
for (@filesystems) {
    printf(
        "mount_point: %s\nformat: %s\ndevice: %s\nmounted: %s\nlabel: %s\nvolume: %s\nspecial: %s\noptions: %s\n\n",
        $fs->mount_point($_), $fs->format($_), $fs->device($_),
        $fs->mounted($_),     $fs->label($_),  $fs->volume($_),
        $fs->special($_),     $fs->options($_),
          );
}

__END__

my @raid_devices;

my @block_devices = Sys::Filesystem::get_block_devices();

# Filter for RAID devices
foreach my $device (@block_devices) {
    if ($device =~ /^\/dev\/md\d+$/) {
        push @raid_devices, $device;
    }
}

# Print the list of RAID devices
foreach my $raid_device (@raid_devices) {
    print "$raid_device\n";
}


# p $block_devices;
