#!/usr/bin/perl

use FindBin;
use lib "$FindBin::Bin/../lib";

use Test::More;

use strict;
use warnings;

use_ok( 'TweetPics::Post' );

my $post = TweetPics::Post->new({
	message => 'Hello World',
	datestamp => '2010-01-01',
	source_name => 'twitter',
	source_id => '12345566'
});
isa_ok($post, 'TweetPics::Post','Post Object Constructed');

is($post->get_message(), 'Hello World', 'get message OK');
is($post->get_datestamp(), '2010-01-01', 'get datestamp OK');
is($post->get_source_name(), 'twitter', 'get source name OK');
is($post->get_source_id(), '12345566', 'get filename OK');


done_testing();
