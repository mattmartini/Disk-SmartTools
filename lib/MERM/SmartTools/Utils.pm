package MERM::SmartTools::Utils;

use lib 'lib';
use MERM::SmartTools::Syntax;
use Exporter qw(import);

use File::Temp;
use Term::ReadKey;
use Term::ANSIColor;
use IO::Interactive qw(is_interactive);
use IPC::Cmd        qw[can_run run];

use version; our $VERSION = version->declare("v1.5.2");

our %EXPORT_TAGS = (

                    ftypes => [ qw(
                                    file_is_plain
                                    file_is_symbolic_link
                                    file_is_pipe
                                    file_is_socket
                                    file_is_block
                                    file_is_character
                                )
                              ],

                    fattr => [ qw(
                                   file_exists
                                   file_readable
                                   file_writeable
                                   file_executable
                                   file_is_empty
                                   file_size_equals
                                   file_owner_effective
                                   file_owner_real
                                   file_is_setuid
                                   file_is_setgid
                                   file_is_sticky
                                   file_is_ascii
                                   file_is_binary
                               )
                             ],

                    dirs => [ qw(
                                  dir_exists
                                  dir_readable
                                  dir_writeable
                                  dir_executable
                                  dir_suffix_slash
                              )
                            ],

                    misc => [ qw(
                                  mk_temp_dir
                                  mk_temp_file
                                  display_menu
                                  get_keypress
                                  prompt
                                  yes_no_prompt
                                  valid
                                  banner
                                  stat_date
                                  status_for
                                  ipc_run_l
                                  ipc_run_s
                              )
                            ],

                    named_constants => [ qw(
                                             $EMPTY_STR
                                             $SPACE
                                             $SINGLE_QUOTE
                                             $DOUBLE_QUOTE
                                             $COMMA
                                         )
                                       ]

                   );

# add all the other ":class" tags to the ":all" class, deleting duplicates
{
    my %seen;
    push @{ $EXPORT_TAGS{ all } }, grep { !$seen{ $_ }++ } @{ $EXPORT_TAGS{ $_ } }
        foreach keys %EXPORT_TAGS;
}
Exporter::export_ok_tags('all');

sub _define_named_constants {
    Readonly our $EMPTY_STR    => q{};
    Readonly our $SPACE        => q{ };
    Readonly our $SINGLE_QUOTE => q{'};
    Readonly our $DOUBLE_QUOTE => q{"};
    Readonly our $COMMA        => q{,};
    return;
}
_define_named_constants();

sub mk_temp_dir {

    my $temp_dir = File::Temp->newdir( DIR     => '/tmp',
                                       CLEANUP => 1 );

    return ($temp_dir);
}    # mk_temp_dir

sub mk_temp_file {
    my $temp_dir = shift || '/tmp';

    my $temp_file = File::Temp->new(
                                     DIR    => $temp_dir,
                                     SUFFIX => '.test',
                                     UNLINK => 1
                                   );

    print $temp_file 'super blood wolf moon' . "\n";

    return ($temp_file);
}    # mk_temp_file

sub display_menu {
    my $msg         = shift;
    my (@choices)   = @_;
    my $num_choices = $#choices;
    if ( $num_choices > 36 ) { die "Error: Too many choices in menu.\n" }
    my $j;
    for ( my $i = 0; $i <= $num_choices; $i++ ) {
        if ( $i < 10 ) {
            $j = $i;
        }
        else {
            $j = chr( 87 + $i );
        }
        printf( "  %s - %s\n", $j, $choices[$i] );
    }

    print colored ( $msg, 'blue' );
    return get_keypress($num_choices);
}

sub get_keypress {
    my $num_choices = shift
        || die "You must provide a max number of choices.\n";
    open( my $TTY, '<', "/dev/tty" ) or croak "Can't read from tty.\n";
    ReadMode "raw";
    my $key  = ReadKey 0, $TTY;
    my $kval = ord($key) - 48;
    ReadMode "normal";
    close($TTY);
    print "$key\n";

    if ( $kval == -38 ) { $kval = 0; }
    if ( $kval >= 49 )  { $kval -= 39; }
    if ( $kval < 0 || $kval > $num_choices ) {
        die "Invalid choice.\n";
    }
    return $kval;
}

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

sub yes_no_prompt {
    my ( $msg, $default ) = @_;
    my $str;

    if ( defined $default ) {
        $msg .= ($default) ? ' ([Y]/N)? ' : ' (Y/[N])? ';
    }
    else {
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

sub valid {
    my $str     = shift;
    my $valid   = shift;
    my $okempty = shift;

    return unless ($valid);    #no valid options give, so return undef

    return   if ( !$str && !$okempty );    # return undef if no str and okempty
    return 1 if ( !$str && $okempty );     # return true if no str and okempty

    #valid is a sub ref -- call it
    return &$valid($str) if ( ref($valid) eq 'CODE' );

    #default -- simply grep for valid reponse in array ref
    return 1 if grep { /^$str$/i } @$valid;

    return 0;                              # "Invalid choice"
}

sub banner {
    my $banner = shift;
    my $fh     = shift || \*STDOUT;

    my $width;
    if ( is_interactive() ) {
        ($width) = GetTerminalSize();
    }
    else {
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
    }
    else {
        $format = $dir_format ? "%04d/%02d/%02d" : "%04d%02d%02d";
        $date = sprintf(
                         $format,
                         sub { ( $_[5] + 1900, $_[4] + 1, $_[3] ) }
                         ->( localtime($mtime) )
                       );
    }
    return $date;
}

sub status_for {
    my ($file) = @_;
    Readonly my @STAT_FIELDS =>
        qw( dev ino mode nlink uid gid rdev size atime mtime ctime blksize blocks );

    # The hash to be returned...
    my %stat_hash = ( file => $file );

    # Load each stat datum into an appropriately named entry of the hash...
    @stat_hash{ @STAT_FIELDS } = stat $file;

    return \%stat_hash;

    # usage: print status_for($file)->{mtime};
}

sub dir_suffix_slash {
    my $dir = shift;

    $dir .= ( substr( $dir, -1, 1 ) eq '/' ) ? '' : '/';
    return $dir;
}

sub file_exists {
    my $file = shift;

    if ( -e $file ) {
        return 1;
    }
    else {
        return 0;
    }
    return;
}

sub file_readable {
    my $file = shift;

    if ( -e -r $file ) {
        return 1;
    }
    else {
        return 0;
    }
    return;
}

sub file_writeable {
    my $file = shift;

    if ( -e -w $file ) {
        return 1;
    }
    else {
        return 0;
    }
    return;
}

sub file_executable {
    my $file = shift;

    if ( -e -x $file ) {
        return 1;
    }
    else {
        return 0;
    }
    return;
}

sub file_is_plain {
    my $file = shift;

    if ( -e -f $file ) {
        return 1;
    }
    else {
        return 0;
    }
    return;
}

sub file_is_symbolic_link {
    my $file = shift;

    if ( -e -l $file ) {
        return 1;
    }
    else {
        return 0;
    }
    return;
}

sub file_is_pipe {
    my $file = shift;

    if ( -e -p $file ) {
        return 1;
    }
    else {
        return 0;
    }
    return;
}

sub file_is_socket {
    my $file = shift;

    if ( -e -S $file ) {
        return 1;
    }
    else {
        return 0;
    }
    return;
}

sub file_is_block {
    my $file = shift;

    if ( -e -b $file ) {
        return 1;
    }
    else {
        return 0;
    }
    return;
}

sub file_is_character {
    my $file = shift;

    if ( -e -c $file ) {
        return 1;
    }
    else {
        return 0;
    }
    return;
}

sub file_is_empty {
    my $file = shift;

    if ( -e -z $file ) {
        return 1;
    }
    else {
        return 0;
    }
    return;
}

sub file_size_equals {
    my $file = shift;
    my $size = shift;

    unless ( file_exists($file) ) { return 0; }

    my $file_size = -s $file;
    if ( $file_size == $size ) {
        return 1;
    }
    else {
        return 0;
    }
    return;
}

sub file_owner_effective {
    my $file = shift;

    if ( -e -o $file ) {
        return 1;
    }
    else {
        return 0;
    }
    return;
}

sub file_owner_real {
    my $file = shift;

    if ( -e -O $file ) {
        return 1;
    }
    else {
        return 0;
    }
    return;
}

sub file_is_setuid {
    my $file = shift;

    if ( -e -u $file ) {
        return 1;
    }
    else {
        return 0;
    }
    return;
}

sub file_is_setgid {
    my $file = shift;

    if ( -e -g $file ) {
        return 1;
    }
    else {
        return 0;
    }
    return;
}

sub file_is_sticky {
    my $file = shift;

    if ( -e -k $file ) {
        return 1;
    }
    else {
        return 0;
    }
    return;
}

sub file_is_ascii {
    my $file = shift;

    if ( -e -T $file ) {
        return 1;
    }
    else {
        return 0;
    }
    return;
}

sub file_is_binary {
    my $file = shift;

    if ( -e -B $file ) {
        return 1;
    }
    else {
        return 0;
    }
    return;
}

sub dir_exists {
    my $dir = shift;

    if ( -e -d $dir ) {
        return 1;
    }
    else {
        return 0;
    }
    return;
}

sub dir_readable {
    my $dir = shift;

    if ( -e -d -r $dir ) {
        return 1;
    }
    else {
        return 0;
    }
    return;
}

sub dir_writeable {
    my $dir = shift;

    if ( -e -d -w $dir ) {
        return 1;
    }
    else {
        return 0;
    }
    return;
}

sub dir_executable {
    my $dir = shift;

    if ( -e -d -x $dir ) {
        return 1;
    }
    else {
        return 0;
    }
    return;
}

# execute the cmd and return array of output or undef on failure
sub ipc_run_l {
    my ($arg_ref) = @_;
    $arg_ref->{ debug } ||= 0;
    warn "cmd: $arg_ref->{ cmd }\n" if $arg_ref->{ debug };

    my ( $success, $error_message, $full_buf, $stdout_buf, $stderr_buf )
        = run(
               command => $arg_ref->{ cmd },
               verbose => $arg_ref->{ verbose } || 0,
               timeout => $arg_ref->{ timeout } || 10,
             );

    # each element of $stdout_buf can contain multiple lines
    # flatten to one line per element in result returned
    if ($success) {
        my @result;
        foreach my $lines ( @{ $stdout_buf } ) {
            foreach my $line ( split( /\n/, $lines ) ) {
                push @result, $line;
            }
        }
        return @result;
    }
    return;
}

# execute the cmd return 1 on success 0 on failure
sub ipc_run_s {
    my ($arg_ref) = @_;
    $arg_ref->{ debug } ||= 0;
    warn "cmd: $arg_ref->{ cmd }\n" if $arg_ref->{ debug };

    if (
          scalar run(
                      command => $arg_ref->{ cmd },
                      buffer  => $arg_ref->{ buf },
                      verbose => $arg_ref->{ verbose } || 0,
                      timeout => $arg_ref->{ timeout } || 10,
                    )
       )
    {
        return 1;
    }
    return 0;
}

1;    # End of MERM::SmartTools::Utils

=pod

=encoding utf-8

=head1 NAME

MERM::SmartTools::Utils - functions to assist in the testing of MERM::SmartTools

=head1 VERSION

Version v1.5.2

=head1 SYNOPSIS

MERM::SmartTools::Utils - provides functions to assist in the testing of MERM::SmartTools.


    use MERM::SmartTools::Utils;

    my $fexists  = file_exists('/bla/somefile');
    my $canreadf  = file_readable('/bla/somefile');
    my $canwritef = file_writeable('/bla/somefile');
    my $canexecf = file_executable('/bla/somefile');

    my $isemptyfile = file_is_empty('/bla/somefile');
    my $fileissize = file_size_equals('/bla/somefile', $number_of_bytes);

    my $isplainfile = file_is_plain('/bla/somefile');
    my $issymlink = file_is_symbolic_link('/bla/somefile');
    ...

    my $dexists  = dir_exists('/somedir');
    my $canreadd  = dir_readable('/somedir');
    my $canwrited = dir_writeable('/somedir');

    my $td = mk_temp_dir();
    my $tf = mk_temp_file($td);

    my $slash_added_dir = dir_suffix_slash('/dir/path/no/slash');

    my $file_date     = stat_date( $test_file, 0, 'daily' );    # 20240221
    my $file_date     = stat_date( $test_file, 1, 'monthly' );  # 2024/02

    banner( "Hello World", $outputFH );

    my $msg    = 'Pick a choice from the list:';
    my @items  = ( 'choice one', 'choice two', 'choice three', );
    my $choice = display_menu( $msg, @items );


=head1 EXPORT_TAGS

=over 4

=item B<:ftypes>

=over 8

=item file_is_plain

=item file_is_symbolic_link

=item file_is_pipe

=item file_is_socket

=item file_is_block

=item file_is_character

=back

=item B<:fattr>

=over 8

=item file_exists

=item file_readable

=item file_writeable

=item file_executable

=item file_is_empty

=item file_size_equals

=item file_owner_effective

=item file_owner_real

=item file_is_setuid

=item file_is_setgid

=item file_is_sticky

=item file_is_ascii

=item file_is_binary

=back

=item B<:dirs>

=over 8

=item dir_exists

=item dir_readable

=item dir_writeable

=item dir_executable

=item dir_suffix_slash

=back

=item B<:misc>

=over 8

=item mk_temp_dir

=item mk_temp_file

=item display_menu

=item get_keypress

=item prompt

=item yes_no_prompt

=item valid

=item banner

=item stat_date

=item status_for

=item ipc_run_l

=item ipc_run_s

=back

=item B<:named_constants>

=over 8

=item $EMPTY_STR

=item $SPACE

=item $SINGLE_QUOTE

=item $DOUBLE_QUOTE

=item $COMMA

=back

=back

=head1 SUBROUTINES

=head2 mk_temp_dir

Create a temporary directory in tmp for use in testing


=head2 mk_temp_file

Create a temporary file in tmp or supplied dir for use in testing

=head2 display_menu

Display a menu of options

=head3 settings

=over 4

=item choices

array of menu items

=back

=head2 get_keypress

Return a single keypress

=head3 settings

=over 4

=item msg

text to display

=item default

default value, if any

=back

=head2 prompt

Prompt user for input

=head3 settings

=over 4

=item msg

text to display

=item default

default value, if any

=back

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

=head2 banner

print a banner

=head2 stat_date

return the state date of a file
format YYYYMMDD, or YYYY/MM/DD if dir_format is true
or if date_type is monthly
format YYYYMM or YYYY/MM

=head2 status_for

return hash_ref of file stat info.
print status_for($file)->{mtime}
available keys:
dev ino mode nlink uid gid rdev size atime mtime ctime blksize blocks 


=head2 dir_suffix_slash

ensures a dir ends in a slash by adding one if neccessary

=head2 file_exists

Tests for file existance.

=head2 file_readable

Tests for file existence and is readable.

=head2 file_writeable

Tests for file existance and is writeable.

=head2 file_executable

Tests for file existance and is executable.

=head2 file_is_plain

Tests that file is a regular file.

=head2 file_is_symbolic_link

Tests that file is a symbolic link.

=head2 file_is_pipe

Tests that file is a named pipe.

=head2 file_is_socket

Tests that file is a socket.

=head2 file_is_block

Tests that file is a block special file.

=head2 file_is_character

Tests that file is a block character file.

=head2 file_is_empty

Check if the file is zero sized.

=head2 file_size_equals

Check if the file size equals given size.

=head2 file_owner_effective

Check if the file is owned by the effective uid.

=head2 file_owner_real

Check if the file is owned by the real uid.

=head2 file_is_setuid

Check if the file has setuid bit set.

=head2 file_is_setgid

Check if the file has setgid bit set.

=head2 file_is_sticky

Check if the file has sticky bit set.

=head2 file_is_ascii

Check if the file is an ASCII or UTF-8 text file (heuristic guess).

=head2 file_is_binary

Check if the file is a "binary" file (opposite of file_is_ascii).

=head2 dir_exists

Tests for dir existance.

=head2 dir_readable

Tests for dir existance and is readable.

=head2 dir_writeable

Tests for dir existance and is writeable.

=head2 dir_executable

Tests for dir existance and is exacutable.

=head2 _define_named_constants

Define named constants as Readonly.

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

This software is Copyright © 2024 by Matt Martini.

This is free software, licensed under:

    The GNU General Public License, Version 3, June 2007

=cut

__END__
