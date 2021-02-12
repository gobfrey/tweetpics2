#!/usr/bin/perl

use FindBin;
use lib "$FindBin::Bin/../lib";

use Test::More;
use TweetPics::Config;

use strict;
use warnings;

use_ok( 'TweetPics::Source::Twitter' );

my $config = TweetPics::Config->new();

my $secrets_file = "$FindBin::Bin/../secrets.ini";
ok(-e $secrets_file, 'Secrets file exists');

$config->load_ini_file('secrets', "$FindBin::Bin/../secrets.ini");

isa_ok($config, 'TweetPics::Config', 'Config loaded');

my $source = TweetPics::Source::Twitter->new();
isa_ok($source, 'TweetPics::Source::Twitter', 'Created Twitter Source');
isa_ok($source->{twitter}, 'Twitter::API', 'Connected to Twitter');

done_testing();
