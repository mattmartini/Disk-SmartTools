#!perl
use 5.018;
use strict;
use warnings;
use Test::More;

plan tests => 4;

BEGIN {
    use_ok( 'MERM::SmartTools' ) || print "Bail out!\n";
    use_ok( 'MERM::SmartTools::Syntax' ) || print "Bail out!\n";
    use_ok( 'MERM::SmartTools::Utils' ) || print "Bail out!\n";
    use_ok( 'MERM::SmartTools::Disks' ) || print "Bail out!\n";
}

diag( "Testing MERM::SmartTools $MERM::SmartTools::VERSION, Perl $], $^X" );
