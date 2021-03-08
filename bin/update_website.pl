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

my $website_persistence = TweetPics::Persistence::Website->new("$FindBin::Bin/../www/", '/');
my $source = TweetPics::Source::LocalDisk->new("$FindBin::Bin/../var/persistence");
my $updater = TweetPics::Updater->new($source, $website_persistence);
$updater->update_missing_posts;


my $index_persistence = TweetPics::Persistence::WebsiteIndexes->new($website_persistence);
$source = TweetPics::Source::LocalDisk->new("$FindBin::Bin/../var/persistence");
$updater = TweetPics::Updater->new($source, $index_persistence);
$updater->update_all_posts;

