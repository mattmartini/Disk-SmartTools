package MERM::SmartTools::Disks;

use lib 'lib';
use MERM::SmartTools::Syntax;
use MERM::SmartTools::OS qw(:all);

use Exporter qw(import);
use IPC::Cmd qw[can_run run];

our $VERSION = '0.01';

# use parent qw(Exporter);
our @EXPORT_OK = qw(
    disk_prefix
    os_disks
    get_smart_cmd
    get_raid_cmd
    get_diskutil_cmd
    get_softraidtool_cmd
);

our %EXPORT_TAGS = ( all => \@EXPORT_OK );

sub disk_prefix {
    if (is_linux) {
        return '/dev/sd';
    }
    elsif (is_mac) {
        return '/dev/disk';
    }
    else {
        croak "Operating System not supported.\n";
    }
}

sub os_disks {
    if (is_linux) {
        return qw(a b c d e f g h i j k l m n o p q r s t u v w x y z);
    }
    elsif (is_mac) {
        return qw(0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15);
    }
    else {
        croak "Operating System not supported.\n";
    }
}

sub get_smart_cmd {
    my $cmd_path = can_run('smartctl')
        or croak "smartctl command not found.\n";

    return $cmd_path;
}

sub get_raid_cmd {
    my $cmd_path = can_run('lspci')
        or do {
            ## carp "lspci command not found.\n";
            return;
        };

    my $raid_cmd = "$cmd_path -nnd ::0104";

    return $raid_cmd;

# 03:00.0 RAID bus controller [0104]: Broadcom / LSI MegaRAID SAS 2108 [Liberator] [1000:0079] (rev 04)
# 06:00.0 RAID bus controller [0104]: HighPoint Technologies, Inc. RocketRAID 2722 [1103:2722] (rev c3)
# /usr/sbin/smartctl --health /dev/sda -d hpt,1/1/1
# /usr/sbin/smartctl --health /dev/sdc -d sat+megaraid,00
}

sub get_softraidtool_cmd {
    my $cmd_path = can_run('softraidtool')
        or do {
            ## carp "softraidtool command not found.\n";
            return;
        };

    return $cmd_path;
}

sub get_diskutil_cmd {
    my $cmd_path = can_run('diskutil')
        or do {
            ## carp "diskutil command not found.\n";
            return;
        };

    return $cmd_path;
}

1;    # End of MERM::SmartTools::Disks

=pod

=encoding utf-8

=head1 NAME

MERM::SmartTools::Disks - Provides disk related functions.

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

Provides disk related functions.

    use MERM::SmartTools::Disks;
    ...

=head1 EXPORT

disk_prefix
os_disks
get_smart_cmd
get_raid_cmd
get_diskutil_cmd
get_softraidtool_cmd

=head1 SUBROUTINES/METHODS

=head2 disk_prefix

Returns the proper disk prefix depending on the OS.

=head2 os_disks

Returns a list of posible disks based on OS.

=head2 get_smart_cmd

Find the path to smartctl or quit.

=head2 get_raid_cmd

Find the path to lspci or return undef.

=head2 get_softraidtool_cmd

Find the path to softraidtool or return undef.

=head2 get_diskutil_cmd

Find the path to diskutil or return undef.

=head1 AUTHOR

Matt Martini, C<< <matt at imaginarywave.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-merm-smarttools at rt.cpan.org>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=MERM-SmartTools>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc MERM::SmartTools::Disks

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=MERM-SmartTools>

=item * CPAN Ratings

L<https://cpanratings.perl.org/d/MERM-SmartTools>

=item * Search CPAN

L<https://metacpan.org/release/MERM-SmartTools>

=back

=head1 ACKNOWLEDGEMENTS

=head1 LICENSE AND COPYRIGHT

This software is Copyright ©️  2024 by Matt Martini.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut

__END__

