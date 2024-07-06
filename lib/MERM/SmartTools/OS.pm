package MERM::SmartTools::OS;

use lib 'lib';
use MERM::SmartTools::Syntax;
use Exporter qw(import);

use version; our $VERSION = version->declare("v1.4.3");

our @EXPORT_OK = qw(
    get_os
    get_hostname
    is_linux
    is_mac
    is_sunos
);

our %EXPORT_TAGS = ( all => \@EXPORT_OK );

sub get_os {
    my $OS = qx(uname -s);
    chomp $OS;

    return $OS;
}

sub get_hostname {
    my $host = qx(uname -n);
    chomp $host;

    return $host;
}

sub is_linux {
    if ( get_os() eq "Linux" ) {
        return 1;
    }
    else {
        return 0;
    }
}

sub is_mac {
    if ( get_os() eq "Darwin" ) {
        return 1;
    }
    else {
        return 0;
    }
}

sub is_sunos {
    if ( get_os() eq "SunOS" ) {
        return 1;
    }
    else {
        return 0;
    }
}

1;    # End of MERM::SmartTools::OS

=pod

=encoding utf-8

=head1 NAME

MERM::SmartTools::OS - OS discovery and functions

=head1 VERSION

Version v1.4.3

=head1 SYNOPSIS

OS discovery and functions

    use MERM::SmartTools::OS;
    ...

=head1 EXPORT

get_os
get_hostname
is_linux
is_mac
is_sunos

=head1 SUBROUTINES

=head2 get_os

Return the OS of the current system.

=head2 get_hostname

Return the hostname of the current system.

=head2 is_linux

Return true if the current system is Linux.

=head2 is_mac

Return true if the current system is MacOS (Darwin).

=head2 is_sunos

Return true if the current system is SunOS.

=head1 AUTHOR

Matt Martini, C<< <matt at imaginarywave.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-merm-smarttools at rt.cpan.org>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=MERM-SmartTools>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc MERM::SmartTools::OS

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

