package Disk::SmartTools::Syntax;

use 5.018;

use utf8;
use strict;
use warnings;
use autodie;
use open qw(:std :utf8);

use Import::Into;
use Module::Runtime;

use version; our $VERSION = version->declare("v2.0.10");

sub importables {
    my ($class) = @_;
    return (
             [ 'feature', ':5.18' ], 'utf8',
             'strict',               'warnings',
             'autodie',              [ 'open', ':std', ':utf8' ],
             'version',              'Readonly',
             'Carp',                 [ 'English', '-no_match_vars' ]
           );
}

sub import {
    my (@args) = @_;
    my $class  = shift @args;
    my $caller = caller;

    foreach my $import_proto ( $class->importables ) {
        my $module;
        ( $module, @args )
            = ( ref($import_proto) || '' ) eq 'ARRAY'
            ? @$import_proto
            : ( $import_proto, () );
        Module::Runtime::use_module($module)->import::into( $caller, @args );
    }
    return;
}

1;    # End of Disk::SmartTools::Syntax

=pod

=encoding utf-8

=head1 NAME

Disk::SmartTools::Syntax - Provide consistent feature setup.

=head1 VERSION

Version v2.0.10

=head1 SYNOPSIS

Provide consistent feature setup.  Put all of the "use" setup cmds in one place.
Then import them into other modules.

Use this in other modules:

    package Disk::SmartTools::Example;

    use Disk::SmartTools::Syntax;

    # Rest of Code...

This is equivalent to:

    package Disk::SmartTools::Example;

    use feature :5.18;
    use utf8;
    use strict;
    use warnings;
    use autodie;
    use open qw(:std :utf8);
    use version;
    use Readonly;
    use Carp;
    use English qw( -no_match_vars );

    # Rest of Code...

=head1 SUBROUTINES/METHODS

=head2 importables

Define the items to be imported.

=head2 import

Do the import.

=head1 AUTHOR

Matt Martini, C<< <matt at imaginarywave.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-disk-smarttools at rt.cpan.org>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=Disk-SmartTools>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Disk::SmartTools::Syntax


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

