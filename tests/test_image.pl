#!/usr/bin/perl

use FindBin;
use lib "$FindBin::Bin/../lib";

use Test::More;

use strict;
use warnings;

use_ok( 'TweetPics::Image' );

my $image = TweetPics::Image->new();
isa_ok($image, 'TweetPics::Image','Image Object Constructed');

is($image->get_source_url(), undef, 'source URL not defined');
$image->set_source_url('http://demo.org/image.jpg');
is($image->get_source_url(), 'http://demo.org/image.jpg', 'set and get url functions');

is($image->get_source_filename(), undef, 'source filename not defined');
$image->set_source_filename('image.jpg');
is($image->get_source_filename(), 'image.jpg', 'set and get filename functions');


done_testing();
