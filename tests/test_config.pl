#!/usr/bin/perl

use FindBin;
use lib "$FindBin::Bin/../lib";

use Test::More;

use strict;
use warnings;

use_ok( 'TweetPics::Config' );


my $config = TweetPics::Config->new();
$config->load_ini_file('secrets', "$FindBin::Bin/../secrets.ini.example");

my $config2 = TweetPics::Config->new();
my $value = $config2->value('secrets', 'twitter', 'consumer_key');

is($value, '<value>', 'Successfully retrieved example config value');


done_testing();
