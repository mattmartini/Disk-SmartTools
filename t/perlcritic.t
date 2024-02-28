#!/usr/bin/env perl

use Test2::V0;
use lib 'lib';

use MERM::SmartTools::Syntax;

use FindBin qw($RealBin);

# perlcritic config set in this file

local $ENV{PERLCRITIC} = $RealBin . '/perlcriticrc';

eval {
    require Test::Perl::Critic;
    import Test::Perl::Critic;
    1;
} or do {
    plan( skip_all => 'Test::Perl::Critic required to criticise code' );
};

all_critic_ok();
