#!/usr/bin/perl

use FindBin;
use lib "$FindBin::Bin/../lib";

use strict;
use warnings;

use TweetPics::Config;
use TweetPics::Updater;
use TweetPics::Source::Twitter;
use TweetPics::Persistence::LocalDisk;

my $config = TweetPics::Config->new();
$config->load_ini_file('secrets', "$FindBin::Bin/../secrets.ini");

my $persistence = TweetPics::Persistence::LocalDisk->new("$FindBin::Bin/../var/persistence");

my $source = TweetPics::Source::Twitter->new();

my $updater = TweetPics::Updater->new($source, $persistence);
$updater->update;

