package Disk::SmartTools;

use 5.018;
use strict;
use warnings;
use Carp;
use lib 'lib';

use version; our $VERSION = version->declare("v1.5.3");

use Exporter   qw( );
use List::Util qw( uniq );

our @EXPORT      = ();
our @EXPORT_OK   = ();
our %EXPORT_TAGS = ( all => \@EXPORT_OK );    # Optional.

sub import {
    my $class = shift;
    my (@packages) = @_;

    my ( @pkgs, @rest );
    for (@packages) {
        if (/^::/) {
            push @pkgs, __PACKAGE__ . $_;
        }
        else {
            push @rest, $_;
        }
    }

    for my $pkg (@pkgs) {
        my $mod = ( $pkg =~ s{::}{/}gr ) . ".pm";
        require $mod;

        my $exports = do { no strict "refs"; \@{ $pkg . "::EXPORT_OK" } };
        $pkg->import(@$exports);
        @EXPORT    = uniq @EXPORT,    @$exports;
        @EXPORT_OK = uniq @EXPORT_OK, @$exports;
    }

    @_ = ( $class, @rest );
    goto &Exporter::import;
}

1;    # End of Disk::SmartTools

=pod

=encoding utf-8

=head1 NAME

Disk::SmartTools - Provide tools to work with disks via S.M.A.R.T.

=head1 VERSION

Version v1.5.3

=head1 SYNOPSIS

Disk::SmartTools provides a loader for sub-modules where a leading :: denotes a package to load.

    use Disk::SmartTools qw( ::Disk ::Utils );

This is equivalent to:

    user Disk::SmartTools::Disk  qw(:all);
    user Disk::SmartTools::Utils qw(:all);

=head1 SUBROUTINES/METHODS

Modules do specific functions.  Load as neccessary.

=cut

# =head2 How it works

# The Disk::SmartTools module simply imports functions from Disk::SmartTools::*
# modules.  Each module defines a self-contained functions, and puts
# those function names into @EXPORT.  Disk::SmartTools defines its own
# import function, but that does not matter to the plug-in modules.

# This function is taken from brian d foy's Test::Data module. Thanks brian!

=head1 SEE ALSO

L<Disk::SmartTools::Disks>,
L<Disk::SmartTools::OS>,
L<Disk::SmartTools::Syntax>,
L<Disk::SmartTools::Utils>

=head1 AUTHOR

Matt Martini, C<< <matt at imaginarywave.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-disk-smarttools at rt.cpan.org>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=Disk-SmartTools>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Disk::SmartTools

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

