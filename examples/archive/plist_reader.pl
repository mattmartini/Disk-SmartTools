#!/usr/bin/env perl

use Data::Plist;
use Data::Plist::Reader;
use Data::Plist::Binaryreader;

use Data::Printer class =>
    { expand => 'all', show_methods => 'none', parents => 0 };
my $filename = 'disks_physical_internal.plist';

# my $filename = '/Users/martini/Library/Preferences/com.adobe.Photoshop.plist';
open( my $fh, '<', $filename ) or die;
my $read = Data::Plist::BinaryReader->new;

# my $plist = $read->open_fh($fh);
my $plist = $read->read($fh);
close $fh;

p $plist;
