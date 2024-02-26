#!/usr/bin/env perl

use Test2::V0;
use lib 'lib';

use MERM::SmartTools::Syntax;
use MERM::SmartTools::Utils qw(:all);

# plan tests => 19;

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

#-----------------------------------------------------------------------------#

my $test_file = 't/perlcriticrc';

my $td = mk_temp_dir();
my $tf = mk_temp_file($td);

my $no_file = '/nonexistant_file';
my $no_dir  = '/nonexistant_dir';

is( file_exists($tf), 1, 'file_exists - exigent file returns true' );
is( file_exists($no_file), 0,
    'file_exists - non-existant file returns false' );

is( file_is_plain($tf), 1, 'file_is_plain - plain file returns true' );
is( file_is_plain($td), 0, 'file_is_plain - non-plain file returns false' );

my $character_file = '/dev/zero';
is( file_is_character($character_file),
    1, 'file_is_character - character file returns true' );
is( file_is_character($tf), 0,
    'file_is_character - non-character file returns false' );

my $fse_file = $td . '/fse_file.test';
open( my $fse_h, '>', $fse_file ) or croak "Can't open file for writing\n";
print $fse_h "Owner Persist Iris Seven";
close($fse_h);
is( file_size_equals( $fse_file, 24 ),
    1, 'file_size_equals - correct size returns true' );
is( file_size_equals( $td, 1 ),
    0, 'file_size_equals - incorrect size returns false' );

my $symlink = $td . '/symlink.$$.test';
symlink( $fse_file, $symlink );
is( file_is_symbolic_link($symlink),
    1, 'file_is_symbolic_link - symbolic link returns true' );
is( file_is_symbolic_link($td),
    0, 'file_is_symbolic_link - non-link file returns false' );

is( file_readable($tf), 1, 'file_readable - readable file returns true' );
is( file_readable($no_file), 0,
    'file_readable - non-readable file returns false' );

is( file_writeable($tf), 1, 'file_writeable - writeable file returns true' );
is( file_writeable($no_file),
    0, 'file_writeable - non-writeable file returns false' );

is( dir_exists($td),     1, 'dir_exists - exigent dir returns true' );
is( dir_exists($no_dir), 0, 'dir_exists - non-existant dir returns false' );

is( dir_readable($td), 1, 'dir_readable - readable dir returns true' );
is( dir_readable($no_dir), 0,
    'dir_readable - non-readable dir returns false' );

is( dir_writeable($td), 1, 'dir_writeable - writeable dir returns true' );
is( dir_writeable($no_dir), 0,
    'dir_writeable - non-writeable dir returns false' );

my $test_dir_w  = '/abc/def/';
my $test_dir_wo = '/abc/def';
is( dir_suffix_slash($test_dir_w),
    $test_dir_w,
    "dir_suffix_slash - don't change dir if has trailing slash" );
is( dir_suffix_slash($test_dir_wo),
    $test_dir_w, "dir_suffix_slash - add slash to dir if no trailing slash" );

#-----------------------------------------------------------------------------#

my $expected_date = '20240219';
my $file_date     = stat_date($test_file);
is( $file_date, $expected_date, "stat_date - default daily case" );

$expected_date = '2024/02/19';
$file_date     = stat_date( $test_file, 1 );
is( $file_date, $expected_date, "stat_date - dir_format daily case" );

$expected_date = '202402';
$file_date     = stat_date( $test_file, 0, 'monthly' );
is( $file_date, $expected_date, "stat_date - default monthly case" );

$expected_date = '2024/02';
$file_date     = stat_date( $test_file, 1, 'monthly' );
is( $file_date, $expected_date, "stat_date - dir_format monthly case" );

#-----------------------------------------------------------------------------#

# my $msg    = 'Pick a choice from the list:';
# my @items  = ( 'choice one', 'choice two', 'choice three', 'ab', );
# my $choice = display_menu( $msg, @items );

#-----------------------------------------------------------------------------#

done_testing;
