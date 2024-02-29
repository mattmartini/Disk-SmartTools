package MERM::SmartTools::Disks;

use lib 'lib';
use MERM::SmartTools::Syntax;
use MERM::SmartTools::OS qw(:all);

=head1 NAME

MERM::SmartTools::Disks - Provides disk related functions.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

Provides disk related functions.

    use MERM::SmartTools::Disks;
    ...

=cut

use parent qw(Exporter);

our @EXPORT_OK = qw(
    disk_prefix
    os_disks
);

our %EXPORT_TAGS = ( all => \@EXPORT_OK );

=head1 EXPORT

disk_prefix

=head1 SUBROUTINES/METHODS

=head2 disk_prefix

Returns the proper disk prefix depending on the OS.

=cut

sub disk_prefix {
    if (is_linux) {
        return '/dev/sd';
    } elsif (is_mac) {
        return '/dev/disk';
    } else {
        croak "Operating System not supported.\n";
    }
}

=head2 os_disks

Returns a list of posible disks based on OS.

=cut

sub os_disks {
    if (is_linux) {
        return qw(a b c d e f g h i j k l m n o p q r s t u v w x y z);
    } elsif (is_mac) {
        return qw(0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15);
    } else {
        croak "Operating System not supported.\n";
    }
}

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

This software is Copyright (c) 2024 by Matt Martini.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007


=cut

1;    # End of MERM::SmartTools::Disks
