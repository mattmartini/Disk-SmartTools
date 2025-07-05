#!/usr/bin/env perl
use Test2::V0;
use strict;
use warnings;

BEGIN {
    plan skip_all => 'Release candidate tests not required for installation'
        unless $ENV{ RELEASE_TESTING };
}
use Test::Kwalitee 'kwalitee_ok';
kwalitee_ok(qw(-use_strict -has_meta_yml));
done_testing;
