#!/usr/bin/perl

use strict;
use warnings;

use Test::Harness;

runtests(qw/
test_config.pl
test_image.pl
test_persistence_localdisk.pl
test_post.pl
test_source_twitter.pl
test_utils.pl
/);
