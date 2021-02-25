#!/usr/bin/perl

use FindBin;
use lib "$FindBin::Bin/../lib";

use strict;
use warnings;

use TweetPics::Config;
use TweetPics::Updater;
use TweetPics::Persistence::Website;
use TweetPics::Persistence::WebsiteIndexes;
use TweetPics::Source::LocalDisk;

my $persistence = TweetPics::Persistence::Website->new("$FindBin::Bin/../../www/new_version", '/new_version/');
my $source = TweetPics::Source::LocalDisk->new("$FindBin::Bin/../var/persistence");
my $updater = TweetPics::Updater->new($source, $persistence);
$updater->update_missing_posts;


$persistence = TweetPics::Persistence::WebsiteIndexes->new("$FindBin::Bin/../../www/new_version", '/new_version/');
$source = TweetPics::Source::LocalDisk->new("$FindBin::Bin/../var/persistence");
$updater = TweetPics::Updater->new($source, $persistence);
$updater->update_all_posts;

