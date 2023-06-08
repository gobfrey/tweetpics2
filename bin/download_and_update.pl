#!/usr/bin/perl

use FindBin;
use lib "$FindBin::Bin/../lib";

use strict;
use warnings;

use TweetPics::Config;
use TweetPics::Persistence::LocalDisk;
use TweetPics::Persistence::WebsiteIndexes;
use TweetPics::Persistence::WebsitePages;
use TweetPics::Source::LocalDisk;
use TweetPics::Source::Mastadon;
use TweetPics::Updater;

my $config = TweetPics::Config->new();
$config->load_ini_file('secrets', "$FindBin::Bin/../secrets.ini");

my $persistence = TweetPics::Persistence::LocalDisk->new("$FindBin::Bin/../var/persistence");
my $source = TweetPics::Source::Mastadon->new();
my $updater = TweetPics::Updater->new($source, $persistence);
$updater->update_new_posts;



my $page_persistence = TweetPics::Persistence::WebsitePages->new("$FindBin::Bin/../www/", '/');
my $index_persistence = TweetPics::Persistence::WebsiteIndexes->new($page_persistence);

$source = TweetPics::Source::LocalDisk->new("$FindBin::Bin/../var/persistence");
$updater = TweetPics::Updater->new($source, $page_persistence);
$updater->update_missing_posts;

$source = TweetPics::Source::LocalDisk->new("$FindBin::Bin/../var/persistence");
$updater = TweetPics::Updater->new($source, $index_persistence);
$updater->update_all_posts;

