package MERM::SmartTools::Utils;

use 5.018;
use strict;
use warnings;

use YAML::XS qw(LoadFile);
use Regexp::Parser;
use File::Temp;
use Term::ReadKey;
use IO::Interactive;

=head1 NAME

MERM::SmartTools::Utils - functions to assist in the testing of MERM::SmartTools

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

MERM::SmartTools::Utils - provides functions to assist in the testing of MERM::SmartTools.


    use MERM::SmartTools::Utils;


    my $fexists  = file_exists('/bla/somefile');
    my $canreadf  = file_readable('/bla/somefile');
    my $canwritef = file_writeable('/bla/somefile');

    my $fexists  = dir_exists('/somedir');
    my $canreadf  = dir_readable('/somedir');
    my $canwritef = dir_writeable('/somedir');


=cut

use parent qw(Exporter);

our %EXPORT_TAGS = (
    all => [
        qw(
            mk_temp_dir
            mk_temp_file
            prompt
            yes_no_prompt
            valid
            banner
            file_exists
            file_readable
            file_writeable
            dir_exists
            dir_readable
            dir_writeable
            dir_suffix_slash
            stat_date
        )
    ]
);

=head1 EXPORT

mk_temp_dir
mk_temp_file
prompt
yes_no_prompt
valid
banner
file_existsd
file_readable
file_writeable
dir_exists
dir_readabled
dir_writeable
dir_suffix_slash
stat_date

=head1 SUBROUTINES

=head2 mk_temp_dir

Create a temporary directory in tmp for use in testing

=cut

sub mk_temp_dir {

    my $temp_dir = File::Temp->newdir( DIR     => '/tmp',
                                       CLEANUP => 1 );

    return ($temp_dir);
}    # mk_temp_dir

=head2 mk_temp_file

Create a temporary file in tmp or supplied dir for use in testing

=cut

sub mk_temp_file {
    my $temp_dir = shift || '/tmp';

    my $temp_file = File::Temp->new( DIR    => $temp_dir,
                                     SUFFIX => '.test',
                                     UNLINK => 1
    );

    print $temp_file 'super blood wolf moon' . "\n";

    return ($temp_file);
}    # mk_temp_file

=head2 prompt

Prompt user for input

=head3 settings

=over 4

=item msg

text to display

=item default

default value, if any

=back

=cut

sub prompt {
    my ( $msg, $default ) = @_;
    my $str;

    $msg .= " [$default]" if ($default);

    while ( ( $str ne $default ) && !$str ) {
        print "$msg ? ";
        $str = <STDIN>;
        chomp $str;
        $str = ($default) ? $default : $str unless ($str);
    }

    return $str;
}

=head2 yes_no_prompt

boolean prompt

=head3 settings

=over 4

=item msg

text to display

=item default

0 --> no, 1 --> yes, undef --> none

=back

Returns: 1 -- yes, 0 -- no

=cut

sub yes_no_prompt {
    my ( $msg, $default ) = @_;
    my $str;

    if ( defined $default ) {
        $msg .= ($default) ? ' ([Y]/N)? ' : ' (Y/[N])? ';
    } else {
        $msg .= ' (Y/N)? ';
    }

    while ( $str !~ /[yn]/i ) {
        print "$msg";
        $str = <STDIN>;
        chomp $str;
        if ( defined $default ) {
            $str = ($default) ? 'y' : 'n' unless ($str);
        }
    }

    return ( $str =~ /y/i ) ? 1 : 0;
}

=head2 valid

helper function for the prompt

returns undef if selection is valid , errmsg if error

=head3 Params

=over 4

=item str

user response

=item valid

either ref_array of valid answers or ref_sub that returns true/false

=item okempty

is empty string ok

=back

=cut

sub valid {
    my $str     = shift;
    my $valid   = shift;
    my $okempty = shift;

    return unless ($valid);    #no valid options give, so -- true by default

    return if ( !$str && $okempty );

    #valid is a sub ref -- call it
    return &$valid($str) if ( ref($valid) eq 'CODE' );

    #default -- simply grep for valid reponse in array ref
    return if grep {/^$str$/i} @$valid;

    return "Invalid choice";
}

=head2 banner

print a banner

=cut

sub banner {
    my $banner = shift;
    my $fh     = shift || \*STDOUT;

    my $width;
    if ( is_interactive() ) {
        ($width) = GetTerminalSize();
    } else {
        $width = 80;
    }

    my $spacer = ( $width - 2 ) - length($banner);
    my $lspace = int( $spacer / 2 );
    my $rspace = $lspace + $spacer % 2;

    print $fh "#" x $width . "\n";
    print $fh "#" . " " x ( $width - 2 ) . "#" . "\n";
    print $fh "#" . " " x $lspace . $banner . " " x $rspace . "#" . "\n";
    print $fh "#" . " " x ( $width - 2 ) . "#" . "\n";
    print $fh "#" x $width . "\n";
    print $fh "\n";

    return;
}

=head2 stat_date

return the state date of a file
format YYYYMMDD, or YYYY/MM/DD if dir_format is true
or if date_type is monthly
format YYYYMM or YYYY/MM

=cut

sub stat_date {
    my $file        = shift;
    my $dir_format  = shift || 0;
    my $date_format = shift || 'daily';
    my ( $date, $format );

    my $mtime = ( stat $file )[9];

    if ( $date_format eq 'monthly' ) {
        $format = $dir_format ? "%04d/%02d" : "%04d%02d";
        $date = sprintf(
            $format,
            sub { ( $_[5] + 1900, $_[4] + 1 ) }
                ->( localtime($mtime) )
        );
    } else {
        $format = $dir_format ? "%04d/%02d/%02d" : "%04d%02d%02d";
        $date = sprintf(
            $format,
            sub { ( $_[5] + 1900, $_[4] + 1, $_[3] ) }
                ->( localtime($mtime) )
        );
    }
    return $date;
}

=head2 dir_suffix_slash

ensures a dir ends in a slash by adding one if neccessary

=cut

sub dir_suffix_slash {
    my $dir = shift;

    $dir .= ( substr( $dir, -1, 1 ) eq '/' ) ? '' : '/';
    return $dir;
}

=head2 file_exists

tests for file existance

=cut

sub file_exists {
    my $file = shift;

    if ( -f $file ) {
        return 1;
    } else {
        return 0;
    }
    return;
}

=head2 file_readable

Tests for file existence and is readable

=cut

sub file_readable {
    my $file = shift;

    unless ( file_exists($file) ) {
        return 0;
    }

    if ( -r $file ) {
        return 1;
    } else {
        return 0;
    }
    return;
}

=head2 file_writeable

tests for file existance and is readable and is writeable

=cut

sub file_writeable {
    my $file = shift;

    unless ( file_readable($file) ) {
        return 0;
    }

    if ( -w $file ) {
        return 1;
    } else {
        return 0;
    }
    return;
}

=head2 dir_exists

tests for dir existance

=cut

sub dir_exists {
    my $dir = shift;

    if ( -d $dir ) {
        return 1;
    } else {
        return 0;
    }
    return;
}

=head2 dir_readable

tests for dir existance and is readable

=cut

sub dir_readable {
    my $dir = shift;

    unless ( dir_exists($dir) ) {
        return 0;
    }

    if ( -r $dir ) {
        return 1;
    } else {
        return 0;
    }
    return;
}

=head2 dir_writeable

tests for dir existance and is readable and is writeable

=cut

sub dir_writeable {
    my $dir = shift;

    unless ( dir_readable($dir) ) {
        return 0;
    }

    if ( -w $dir ) {
        return 1;
    } else {
        return 0;
    }
    return;
}

=head1 AUTHOR

Matt Martini, C<< <matt at imaginarywave.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-merm-smarttools at rt.cpan.org>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=MERM-SmartTools>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc MERM::SmartTools::Utils


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

1;    # End of MERM::SmartTools::Utils
