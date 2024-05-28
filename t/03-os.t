#!/usr/bin/env perl

use Test2::V0;
use lib 'lib';

use MERM::SmartTools::Syntax;
use MERM::SmartTools qw(::OS);

# plan tests => 6;

#======================================#
#             get_hostname             #
#======================================#

my $expected_host = qx(hostname);
chomp($expected_host);
my $host = get_hostname();
is( $host, $expected_host, "get_hostname - matches hostname" );

$expected_host = qx(uname -n);
chomp($expected_host);
is( $host, $expected_host, "get_hostname - matches uname -n" );

#======================================#
#                get_os                #
#======================================#

my $expected_os = qx(uname -s);
chomp($expected_os);
my $os = get_os();
is( $os, $expected_os, "get_os - matches os" );

#======================================#
#               is_linux               #
#======================================#

if ( $expected_os eq "Linux" ) {
    is( is_linux, 1, "is_linux - true if linux" );
}
else {
    is( is_linux, 0, "is_linux - false if not linux" );
}

#======================================#
#                is_mac                #
#======================================#

if ( $expected_os eq "Darwin" ) {
    is( is_mac, 1, "is_mac - true if macOS" );
}
else {
    is( is_mac, 0, "is_mac - false if not macOS" );
}

#======================================#
#               is_sunos               #
#======================================#

if ( $expected_os eq "SunOS" ) {
    is( is_sunos, 1, "is_sunos - true if sunos" );
}
else {
    is( is_sunos, 0, "is_sunos - false if not sunos" );
}

done_testing;
