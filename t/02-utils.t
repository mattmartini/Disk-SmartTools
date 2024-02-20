#!/usr/bin/env perl

use Test2::V0;
use lib 'lib';

use MERM::SmartTools::Syntax;
use MERM::LogArchive::Utils qw(banner);

plan tests => 1;

my $expected = <<'EOW';
################################################################################
#                                                                              #
#                                 Hello World                                  #
#                                                                              #
################################################################################

EOW

my $output;
open( my $outputFH, '>', \$output ) or die;
banner( "Hello World", $outputFH );
close $outputFH;

is( $output, $expected, 'Banner Test' );

done_testing;
