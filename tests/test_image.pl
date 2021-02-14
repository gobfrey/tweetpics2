#!/usr/bin/perl

use FindBin;
use lib "$FindBin::Bin/../lib";

use Test::More;

use strict;
use warnings;

use_ok( 'TweetPics::Image' );

my $image = TweetPics::Image->new({ filename => 'foo.jpg', data => 'ABC123'});
isa_ok($image, 'TweetPics::Image','Image Object Constructed');

is($image->get_filename(), 'foo.jpg', 'get filename OK');
is($image->get_data(), 'ABC123', 'get data OK');

my $url = 'https://www.wikipedia.org/static/favicon/wikipedia.ico';
$image = TweetPics::Image->new_from_url($url);
isa_ok($image, 'TweetPics::Image','Image Object Constructed');

is($image->get_filename(), 'wikipedia.ico', 'get filename OK');
cmp_ok(length($image->get_data()), '>', 100,'image is more than 100 bytes');



done_testing();
