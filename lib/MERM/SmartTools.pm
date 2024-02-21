package MERM::SmartTools;

use 5.018;
use strict;
use warnings;
use Carp;

=head1 NAME

MERM::SmartTools - Provide tools to work with disks via S.M.A.R.T.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

MERM::SmartTools provides a loader for sub-modules.

    use MERM::SmartTools;

=cut

$Exporter::Verbose = 0;

sub import {
    my $self       = shift;
    my (@packages) = @_;
    my $caller     = caller;

    foreach my $package (@packages) {
        my $full_package = "MERM::SmartTools::$package";
        eval "require $full_package";
        if ($@) {
            carp "Could not require MERM::SmartTools::$package: $@";
        }

        $full_package->Exporter::export($caller);
    }
    return;
}

=head1 SUBROUTINES/METHODS

Modules do specific functions.  Load as neccessary.

=head2 How it works

The MERM::SmartTools module simply imports functions from MERM::SmartTools::*
modules.  Each module defines a self-contained functions, and puts
those function names into @EXPORT.  MERM::SmartTools defines its own
import function, but that does not matter to the plug-in modules.

This function is taken from brian d foy's Test::Data module. Thanks brian!


=head1 SEE ALSO

L<MERM::SmartTools::Disks>,
L<MERM::SmartTools::OS>,
L<MERM::SmartTools::Syntax>,
L<MERM::SmartTools::Utils>

=head1 AUTHOR

Matt Martini, C<< <matt at imaginarywave.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-merm-smarttools at rt.cpan.org>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=MERM-SmartTools>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc MERM::SmartTools


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

1;    # End of MERM::SmartTools
