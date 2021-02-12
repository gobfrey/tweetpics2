#!/usr/bin/perl

use FindBin;
use lib "$FindBin::Bin/../lib";

use Test::More;

use strict;
use warnings;

use_ok( 'TweetPics::Source::Twitter' );



done_testing();
