package Disk::SmartTools::Disks;

use lib 'lib';
use Disk::SmartTools::Syntax;
use Disk::SmartTools qw(::OS ::Utils);

use Exporter qw(import);
use IPC::Cmd qw[can_run run];

our $VERSION = version->declare("v2.0.10");

our @EXPORT_OK = qw(
    get_disk_prefix
    os_disks
    get_smart_cmd
    get_raid_cmd
    get_raid_flag
    get_softraidtool_cmd
    get_diskutil_cmd
    get_physical_disks
    get_smart_disks
    is_drive_smart
    smart_on_for
    smart_test_for
    selftest_history_for
    smart_cmd_for
);

our %EXPORT_TAGS = ( all => \@EXPORT_OK );

sub get_disk_prefix {
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
    my $disk_prefix = get_disk_prefix();
    my @disks;
    if (is_linux) {
        @disks = qw(a b c d e f g h i j k l m n o p q r s t u v w x y z);
        return map { $disk_prefix . $_ } @disks;
    }
    elsif (is_mac) {
        @disks = qw(0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15);
        return map { $disk_prefix . $_ } @disks;
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

sub get_raid_flag {
    my $raid_cmd = get_raid_cmd();
    my $buf;

    if ( defined $raid_cmd ) {
        scalar run(
                    command => $raid_cmd,
                    verbose => 0,
                    buffer  => \$buf,
                    timeout => 10,
                  );

        if ( $buf =~ m{ HighPoint }i ) {
            return ' -d hpt,';
        }

        if ( $buf =~ m{ MegaRAID }i ) {
            return ' -d sat+megaraid,';
        }
    }
    return;
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

sub get_physical_disks {
    my $diskutil_cmd = get_diskutil_cmd();
    my @disks;
    Readonly my $PHYSICAL_DISK => qr{^(/dev/disk\d+)}i;

    $diskutil_cmd .= ' list physical';
    if ($diskutil_cmd) {
        my $buf;
        if (
              scalar run(
                          command => $diskutil_cmd,
                          verbose => 0,
                          buffer  => \$buf,
                          timeout => 10
                        )
           )
        {
            foreach my $line ( split( /\n/, $buf ) ) {
                if ( $line =~ $PHYSICAL_DISK ) {
                    my $disk = $1;
                    push @disks, $disk;
                }
            }    #foreach
        }    #if run
        return @disks;
    }
    return;

}

sub get_smart_disks {
    my (@disks) = @_;

    my @smart_disks = grep { is_drive_smart($_) } @disks;
    return @smart_disks;
}

sub is_drive_smart {
    my ($disk) = @_;
    Readonly my $IS_AVAILABLE => qr{SMART support is: Available}i;
    my $smart_cmd = get_smart_cmd();
    $smart_cmd .= ' --info ' . $disk;
    if ($smart_cmd) {
        my $buf;
        if (
              scalar run(
                          command => $smart_cmd,
                          verbose => 0,
                          buffer  => \$buf,
                          timeout => 10
                        )
           )
        {
            foreach my $line ( split( /\n/, $buf ) ) {
                if ( $line =~ $IS_AVAILABLE ) {
                    return 1;
                }
            }    #foreach
        }    #if run
    }
    return 0;
}

# args: $cmd_path, $disk
sub smart_on_for {
    my ($arg_ref) = @_;

    my $cmd = $arg_ref->{ cmd_path } . ' --smart=on ' . $arg_ref->{ disk };
    unless ( ipc_run_s( { cmd => $cmd, timeout => 10 } ) ) {
        return 0;
    }
    return 1;
}

sub smart_test_for {
    my ($arg_ref) = @_;

    my $cmd
        = $arg_ref->{ cmd_path }
        . ' --test='
        . $arg_ref->{ test_type } . ' '
        . $arg_ref->{ disk };

    unless ( ipc_run_s( { cmd => $cmd, timeout => 10 } ) ) {
        return 0;
    }
    return 1;
}

sub selftest_history_for {
    my ($arg_ref) = @_;
    $arg_ref->{ debug } ||= 0;

    my $cmd = $arg_ref->{ cmd_path } . ' -l selftest ' . $arg_ref->{ disk };

    if ( my @buf = ipc_run_l( { cmd => $cmd, debug => $arg_ref->{ debug } } ) ) {
        return \@buf;
    }
    return;
}

sub smart_cmd_for {
    my ($arg_ref) = @_;
    $arg_ref->{ debug } ||= 0;

    my $cmd
        = $arg_ref->{ cmd_path } . $arg_ref->{ cmd_type } . $arg_ref->{ disk };

    if ( my @buf = ipc_run_l( { cmd => $cmd, debug => $arg_ref->{ debug } } ) ) {
        return \@buf;
    }
    return;
}

1;    # End of Disk::SmartTools::Disks

=pod

=encoding utf-8

=head1 NAME

Disk::SmartTools::Disks - Provides disk related functions.

=head1 VERSION

Version v2.0.10

=head1 SYNOPSIS

Provides disk related functions.

    use Disk::SmartTools::Disks;

    my $cmd_path = get_smart_cmd();


    ...

=head1 EXPORT

    get_disk_prefix
    os_disks
    get_smart_cmd
    get_raid_cmd
    get_raid_flag
    get_diskutil_cmd
    get_physical_disks
    get_smart_disks
    is_drive_smart
    get_softraidtool_cmd

=head1 SUBROUTINES/METHODS

=head2 B<get_disk_prefix()>

Returns the proper disk prefix depending on the OS: C</dev/sd> for linux, C</dev/disk> for macOS.

    my $disk_prefix = get_disk_prefix();

=head2 B<os_disks()>

Returns a list of possible disks based on OS, prefixed by get_disk_prefix().

    my @disks = os_disks();

=head2 B<get_smart_cmd()>

Find the path to smartctl or quit.

    my $smart_cmd = get_smart_cmd();

=head2 B<get_raid_cmd()>

Find the path to lspci or return undef.

    my $raid_cmd = get_raid_cmd();

=head2 B<get_raid_flag()>

Find the raid flag for use with the current RAID.  Currently supports Highpoint and MegaRAID controllers.

    my $raid_flag = get_raid_flag();

=head2 B<get_softraidtool_cmd()>

Find the path to softraidtool or return undef.

    my $softraid_cmd = get_softraidtool_cmd();

=head2 B<get_diskutil_cmd()>

On MacOS, find the path to diskutil or return undef.

    my $diskutil_cmd = get_diskutil_cmd();

=head2 B<get_physical_disks()>

On MacOS, find the physical disks (not synthesized or disk image)

    my @disks = get_physical_disks();

=head2 B<get_smart_disks(@disks)>

Given a list of disks, find all disks that support SMART and return as a list

    my @smart_disks = get_smart_disks(@disks);

=head2 B<is_drive_smart($disk)>

Test if a disk supports SMART

    my $drive_is_smart = is_drive_smart($disk);

=head2 B<smart_on_for($disk)>

Test is SMART is enabled for a disk

    my $smart_enabled = smart_on_for($disk);

=head2 B<smart_test_for>

Run smart test on a disk, specify test_type (short, long)

    $smart_test_started = smart_test_for($disk);

=head2 B<selftest_history_for>

Show the self-test history for a disk

    selftest_history_for($disk);

=head2 B<smart_cmd_for>

Run a smart command for a disk

    my $return_buffer_ref
        = smart_cmd_for(
                         { cmd_path => $cmd_path,
                           cmd_type => $cmd_type,
                           disk     => $current_disk
                         }
                       );

=head1 AUTHOR

Matt Martini, C<< <matt at imaginarywave.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-disk-smarttools at rt.cpan.org>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=Disk-SmartTools>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Disk::SmartTools::Disks

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=Disk-SmartTools>

=item * CPAN Ratings

L<https://cpanratings.perl.org/d/Disk-SmartTools>

=item * Search CPAN

L<https://metacpan.org/release/Disk-SmartTools>

=back

=head1 ACKNOWLEDGEMENTS

=head1 LICENSE AND COPYRIGHT

This software is Copyright © 2024-2025 by Matt Martini.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut

__END__

