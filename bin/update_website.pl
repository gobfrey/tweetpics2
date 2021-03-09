#!/usr/bin/perl

use FindBin;
use lib "$FindBin::Bin/../lib";

use strict;
use warnings;

use TweetPics::Config;
use TweetPics::Updater;
use TweetPics::Persistence::WebsitePages;
use TweetPics::Persistence::WebsiteIndexes;
use TweetPics::Source::LocalDisk;

my $page_persistence = TweetPics::Persistence::WebsitePages->new("$FindBin::Bin/../www/", '/');
my $index_persistence = TweetPics::Persistence::WebsiteIndexes->new($page_persistence);
my $source = TweetPics::Source::LocalDisk->new("$FindBin::Bin/../var/persistence");

my $updater = TweetPics::Updater->new($source, $page_persistence);
$updater->update_missing_posts;

$updater = TweetPics::Updater->new($source, $index_persistence);
$updater->update_all_posts;

