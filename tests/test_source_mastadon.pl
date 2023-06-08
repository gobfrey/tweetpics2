#!/usr/bin/perl

use FindBin;
use lib "$FindBin::Bin/../lib";

use Test::More;
use TweetPics::Config;

use strict;
use warnings;

use_ok( 'TweetPics::Source::Mastadon' );

my $source = TweetPics::Source::Mastadon->new();
isa_ok($source, 'TweetPics::Source::Mastadon', 'Created Twitter Source');

my $first_page_url = $source->{next_page_url};
is($first_page_url, 'https://mastodonapp.uk/users/gobfrey/outbox?page=true', 'getting toots from the right address');

$source->_load_next_page();
cmp_ok(scalar @{$source->{toots}}, '>',0, 'toots loaded');
isnt($source->{next_page_url}, $first_page_url, 'next page URL changed');

my $post = $source->next_post();
my $post2 = $source->next_post();

isa_ok($post, 'TweetPics::Post');
isa_ok($post2, 'TweetPics::Post');

my $msg1 = $post->get_message();
my $msg2 = $post2->get_message();
isnt($msg1, undef, 'post has message: ' . $msg1);
isnt($msg2, undef, 'post has message: ' . $msg2);
isnt($msg1, $msg2, 'two messages are different');

my $id1 = $post->get_source_id();
my $id2 = $post2->get_source_id();
isnt($id1, undef, 'post has source_id' . $id1);
isnt($id2, undef, 'post has source_id' . $id2);
isnt($id1, $id2, 'two source_ids are different');



isnt($post->get_datestamp, undef, 'post has datestamp');
is($post->get_source_name, 'mastadon', 'source name is mastadon');


done_testing();
