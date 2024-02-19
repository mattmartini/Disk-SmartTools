#!/usr/bin/env perl
# use Test2::V0;
use Test::More;
use FindBin qw($RealBin);
use English qw(-no_match_vars);

# perlcritic config set in this file
$ENV{PERLCRITIC} = $RealBin . '/perlcriticrc';

eval { require Test::Perl::Critic; import Test::Perl::Critic; };

if ($EVAL_ERROR) {
    plan( skip_all => 'Test::Perl::Critic required to criticise code' );
}

all_critic_ok();
