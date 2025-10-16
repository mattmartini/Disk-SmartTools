#!/usr/bin/env perl

use Test2::V0;
use lib 'lib';

use MERM::SmartTools::Syntax;
use MERM::SmartTools qw(::OS ::Utils );

use Socket;

plan tests => 70;

#======================================#
#                banner                #
#======================================#

my $expected = <<'EOW';
################################################################################
#                                                                              #
#                                 Hello World                                  #
#                                                                              #
################################################################################

EOW

my $output;
open( my $outputFH, '>', \$output ) or croak;
banner( "Hello World", $outputFH );
close $outputFH;

is( $output, $expected, 'Banner Test' );

#======================================#
#                valid                 #
#======================================#

my @valid    = qw (bee bat bear);
my $okempty  = 1;
my $good_str = 'bat';
my $bad_str  = 'snake';

is( valid($good_str), undef,
    'valid - no valid criteria given returns undef' );
is( valid( '', \@valid, $okempty ),
    1, 'valid - empty string with okempty given returns true' );
is( valid( '', \@valid, 0 ),
    undef, 'valid - empty string without okempty given returns undef' );
is( valid( $good_str, \@valid, $okempty ),
    1, 'valid - good string with okempty given returns true' );
is( valid( $good_str, \@valid, 0 ),
    1, 'valid - good string without okempty given returns true' );
is( valid( $bad_str, \@valid, $okempty ),
    0, 'valid - bad string with okempty given returns false' );
is( valid( $bad_str, \@valid, 0 ),
    0, 'valid - bad string without okempty given returns false' );

#======================================#
#           Make test files            #
#======================================#

my $test_file = 't/perlcriticrc';

my $td = mk_temp_dir();
my $tf = mk_temp_file($td);

my $no_file = '/nonexistant_file';
my $no_dir  = '/nonexistant_dir';

my $tff = $td . "/tempfile.$$.test";
open( my $tff_h, '>', $tff ) or croak "Can't open file for writing\n";
print $tff_h "Owner Persist Iris Seven";
close($tff_h);

my $tsl = $td . "/symlink.$$.test";
symlink( $tff, $tsl );

socket( my $ts, PF_INET, SOCK_STREAM, ( getprotobyname('tcp') )[2] );
my $trf = '/bin/cat';
my $dnf = '/dev/null';

#======================================#
#            file_is_plain             #
#======================================#

is( file_is_plain($tf),  1, 'file_is_plain - plain file returns true' );
is( file_is_plain($tff), 1, 'file_is_plain - plain file returns true' );
is( file_is_plain($td),  0, 'file_is_plain - non-plain file returns false' );

#======================================#
#        file_is_symbolic_link         #
#======================================#

is( file_is_symbolic_link($tsl),
    1, 'file_is_symbolic_link - symbolic link returns true' );
is( file_is_symbolic_link($td),
    0, 'file_is_symbolic_link - non-link file returns false' );

#======================================#
#             file_is_pipe             #
#======================================#

open( my $tp, '-|', 'echo "Hello World"' ) or croak "Couldn't open pipe.\n";
is( file_is_pipe($tp), 1, 'file_is_pipe - pipe returns true' );
close($tp);
is( file_is_pipe($tf), 0, 'file_is_pipe - non-pipe returns false' );

#======================================#
#            file_is_socket            #
#======================================#

is( file_is_socket($ts), 1, 'file_is_socket - socket returns true' );
is( file_is_socket($tf), 0, 'file_is_socket - non-socket returns false' );

#======================================#
#            file_is_block             #
#======================================#

my $block_file;
if ( is_mac() ) {
    $block_file = '/dev/disk0';
}
elsif ( is_linux() ) {
    $block_file = '/dev/loop0';
}
else {
    croak "Unsupported system\n";
}
if ( file_exists($block_file) ) {
    is( file_is_block($block_file),
        1, 'file_is_block - block file returns true' );
}
else {
    plan( skip_all =>
           "Block file, $block_file, is required for file_is_block test." );
}
is( file_is_block($tf), 0, 'file_is_block - non-block file returns false' );

#======================================#
#          file_is_character           #
#======================================#

my $character_file = '/dev/zero';
if ( file_exists($character_file) ) {
    is( file_is_character($character_file),
        1, 'file_is_character - character file returns true' );
}
else {
    plan( skip_all =>
            'Character file, $character_file, is required for file_is_character test.'
        );
}
is( file_is_character($tf), 0,
    'file_is_character - non-character file returns false' );

#======================================#
#             file_exists              #
#======================================#

is( file_exists($tf), 1, 'file_exists - exigent file returns true' );
is( file_exists($no_file), 0,
    'file_exists - non-existant file returns false' );

#======================================#
#            file_readable             #
#======================================#

my $mode = oct(0000);
chmod $mode, $tff;
SKIP: {
    skip "Root user - test not valid", 1 if ( $REAL_USER_ID == 0 );
    is( file_readable($tff), 0,
        'file_readable - non-readable file returns false' );
}
$mode = oct(400);
chmod $mode, $tff;
is( file_readable($tff), 1, 'file_readable - readable file returns true' );

#======================================#
#            file_writeable            #
#======================================#

SKIP: {
    skip "Root user - test not valid", 1 if ( $REAL_USER_ID == 0 );
    is( file_writeable($tff), 0,
        'file_writeable - non-writeable file returns false' );
}
$mode = oct(200);
chmod $mode, $tff;
is( file_writeable($tf), 1, 'file_writeable - writeable file returns true' );

#======================================#
#           file_executable            #
#======================================#

is( file_executable($tff), 0,
    'file_executable - non-executable file returns false' );
$mode = oct(100);
chmod $mode, $tff;
is( file_executable($tff), 1,
    'file_executable - executable file returns true' );

#======================================#
#            file_is_empty             #
#======================================#

is( file_is_empty($dnf), 1, 'file_is_empty - empty file returns true' );
is( file_is_empty($tff), 0, 'file_is_empty - non-empty file returns false' );

#======================================#
#           file_size_equals           #
#======================================#

is( file_size_equals( $tff, 24 ),
    1, 'file_size_equals - correct size returns true' );
is( file_size_equals( $td, 1 ),
    0, 'file_size_equals - incorrect size returns false' );
is( file_size_equals( $no_file, 1 ),
    0, 'file_size_equals - non-existant file returns false' );

#======================================#
#         file_owner_effective         #
#======================================#

is( file_owner_effective($tf),
    1, 'file_owner_effective - file owned by eff id returns true' );
SKIP: {
    skip "Root user - test not valid", 1 if ( $REAL_USER_ID == 0 );
    is( file_owner_effective($trf),
        0, 'file_owner_effective - file not owned by eff id returns false' );
}

#======================================#
#           file_owner_real            #
#======================================#

is( file_owner_real($tf), 1,
    'file_owner_real - file owned by real id returns true' );
SKIP: {
    skip "Root user - test not valid", 1 if ( $REAL_USER_ID == 0 );
    is( file_owner_real($trf), 0,
        'file_owner_real - file not owned by real id returns false' );
}

#======================================#
#            file_is_setuid            #
#======================================#

is( file_is_setuid($tff), 0,
    'file_is_setuid - non-setuid file returns false' );
$mode = oct(4400);
chmod $mode, $tff;
is( file_is_setuid($tff), 1, 'file_is_setuid - setuid file returns true' );

#======================================#
#            file_is_setgid            #
#======================================#

is( file_is_setgid($tff), 0,
    'file_is_setgid - non-setgid file returns false' );
$mode = oct(2400);
chmod $mode, $tff;
is( file_is_setgid($tff), 1, 'file_is_setgid - setgid file returns true' );

#======================================#
#            file_is_sticky            #
#======================================#

is( file_is_sticky($tff), 0,
    'file_is_sticky - non-sticky file returns false' );
$mode = oct(1400);
chmod $mode, $tff;
is( file_is_sticky($tff), 1, 'file_is_sticky - sticky file returns true' );

#======================================#
#            file_is_ascii             #
#======================================#

is( file_is_ascii($tf),  1, 'file_is_ascii - ascii file returns true' );
is( file_is_ascii($trf), 0, 'file_is_ascii - non-ascii file returns false' );

#======================================#
#            file_is_binary            #
#======================================#

is( file_is_binary($trf), 1, 'file_is_binary - binary file returns true' );
is( file_is_binary($tff), 0,
    'file_is_binary - non-binary file returns false' );

#======================================#
#              dir_exists              #
#======================================#

is( dir_exists($td),     1, 'dir_exists - exigent dir returns true' );
is( dir_exists($no_dir), 0, 'dir_exists - non-existant dir returns false' );

#======================================#
#             dir_readable             #
#======================================#

$mode = oct(000);
chmod $mode, $td;
SKIP: {
    skip "Root user - test not valid", 1 if ( $REAL_USER_ID == 0 );
    is( dir_readable($td), 0, 'dir_readable - non-readable dir returns false' );
}
$mode = oct(400);
chmod $mode, $td;
is( dir_readable($td), 1, 'dir_readable - readable dir returns true' );

#======================================#
#            dir_writeable             #
#======================================#
SKIP: {
    skip "Root user - test not valid", 1 if ( $REAL_USER_ID == 0 );
    is( dir_writeable($td), 0,
        'dir_writeable - non-writeable dir returns false' );
}
$mode = oct(200);
chmod $mode, $td;
is( dir_writeable($td), 1, 'dir_writeable - writeable dir returns true' );

#======================================#
#            dir_executable            #
#======================================#
SKIP: {
    skip "Root user - test not valid", 1 if ( $REAL_USER_ID == 0 );
    is( dir_executable($td), 0,
        'dir_executable - non-executable dir returns false' );
}
$mode = oct(100);
chmod $mode, $td;
is( dir_executable($td), 1, 'dir_executable - executable dir returns true' );
$mode = oct(700);
chmod $mode, $td;

#======================================#
#           dir_suffix_slash           #
#======================================#

my $test_dir_w  = '/abc/def/';
my $test_dir_wo = '/abc/def';
is( dir_suffix_slash($test_dir_w),
    $test_dir_w,
    "dir_suffix_slash - don't change dir if has trailing slash" );
is( dir_suffix_slash($test_dir_wo),
    $test_dir_w, "dir_suffix_slash - add slash to dir if no trailing slash" );

#======================================#
#              stat_date               #
#======================================#

system("touch -t  202402201217.23 $tf");
my $expected_date = '20240220';
my $file_date     = stat_date($tf);
is( $file_date, $expected_date, "stat_date - default daily case" );

$expected_date = '2024/02/20';
$file_date     = stat_date( $tf, 1 );
is( $file_date, $expected_date, "stat_date - dir_format daily case" );

$expected_date = '202402';
$file_date     = stat_date( $tf, 0, 'monthly' );
is( $file_date, $expected_date, "stat_date - default monthly case" );

$expected_date = '2024/02';
$file_date     = stat_date( $tf, 1, 'monthly' );
is( $file_date, $expected_date, "stat_date - dir_format monthly case" );

#======================================#
#              status_for              #
#======================================#

my $file_mtime = status_for($tf)->{ mtime };
is( $file_mtime, '1708449443', 'status_for - mtime of file' );

#======================================#
#             display_menu             #
#======================================#

# my $msg    = 'Pick a choice from the list:';
# my @items  = ( 'choice one', 'choice two', 'choice three', 'ab', );
# my $choice = display_menu( $msg, @items );

#======================================#
#              ipc_run_l               #
#======================================#

my $hw_expected = "hello world";
my @hw          = ipc_run_l( { cmd => 'echo hello world' } );
my $hw_result   = join "\n", @hw;
is( $hw_result, $hw_expected, 'ipc_run_l - echo hello world' );

my $hw_ref = ipc_run_l( { cmd => 'exho hello world' } );
is( $hw_ref, undef, 'ipc_run_l - fail bad cmd: exho hello world' );

my @expected_seq = qw(1 2 3 4 5 6 7 8 9 10);
my @seq          = ipc_run_l( { cmd => 'seq 1 10', } );
is( @seq, @expected_seq, 'ipc_run_l - multiline output' );

#======================================#
#              ipc_run_s               #
#======================================#

my $buf = '';
ok( ipc_run_s( { cmd => 'echo hello world', buf => \$buf } ) );
is( $buf, $hw_expected . "\n", 'ipc_run_s - hellow world' );

ok( !ipc_run_s( { cmd => 'exho hello world', buf => \$buf } ) );

$buf = '';
ok( ipc_run_s( { cmd => 'seq 1 10', buf => \$buf } ) );

done_testing;
