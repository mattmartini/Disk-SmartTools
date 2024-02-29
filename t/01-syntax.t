#!/usr/bin/env perl

use Test2::V0;
use lib 'lib';

use MERM::SmartTools::Syntax;

plan tests => 1;

ok( ( say "Hello World" eq "Hello World" ),
    "Test if use feature :5.18 loaded." );

done_testing;
