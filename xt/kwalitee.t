#!/usr/bin/env perl
use Test::More;
use strict;
use warnings;

BEGIN {
    plan skip_all => 'These tests are for release candidate testing'
        unless $ENV{ RELEASE_TESTING };
}

use Test::Kwalitee 'kwalitee_ok';
kwalitee_ok(qw(-use_strict));
done_testing;

