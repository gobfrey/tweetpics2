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

my $post = $source->next_post();
my $post2 = $source->next_post();

isa_ok($post, 'TweetPics::Post');
isa_ok($post2, 'TweetPics::Post');

my $msg1 = $post->get_message();
my $msg2 = $post2->get_message();
isnt($msg1, undef, 'post has message');
isnt($msg2, undef, 'post has message');
isnt($msg1, $msg2, 'two messages are different');

my $id1 = $post->get_source_id();
my $id2 = $post2->get_source_id();
isnt($id1, undef, 'post has source_id');
isnt($id2, undef, 'post has source_id');
isnt($id1, $id2, 'two source_ids are different');



isnt($post->get_datestamp, undef, 'post has datestamp');
is($post->get_source_name, 'twitter', 'source name is twitter');


done_testing();
