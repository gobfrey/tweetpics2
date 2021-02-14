#!/usr/bin/perl

use FindBin;
use lib "$FindBin::Bin/../lib";

use TweetPics::Post;
use TweetPics::Image;
use Test::More;
use File::Path qw(make_path remove_tree);
use JSON;

use strict;
use warnings;

use_ok( 'TweetPics::Persistence::LocalDisk' );


#create test directory
my $base_path = "$FindBin::Bin/var/test_persistence_localdisk";

make_path("$base_path");

my $persistence = TweetPics::Persistence::LocalDisk->new($base_path);
isa_ok($persistence, "TweetPics::Persistence::LocalDisk", 'Object Created');

my $data = {
	message => 'Hello World',
	datestamp => '2020-01-01',
	source_name => 'twitter',
	source_id => '12345'
};

my $post = TweetPics::Post->new($data);

$persistence->write_post($post);

ok(-e "$base_path/twitter/12345/data.json", 'data.json exists at correct path');

my $roundtripped_data = decode_json(TweetPics::Utils::read_from_file("$base_path/twitter/12345/data.json"));

is_deeply($data, $roundtripped_data, 'post data roundtripped');

my $data2 = {
	message => 'Hello World',
	datestamp => '2020-01-01',
	source_name => 'twitter',
	source_id => '934234566',
	images => [
		TweetPics::Image->new({
			'filename' => 'thing1.jpg',
			'data' => 'BINARY_DATA'
		}),
		TweetPics::Image->new({
			'filename' => 'thing2.jpg',
			'data' => 'BINARY_DATA'
		})
	]
};

$post = TweetPics::Post->new($data2);
$persistence->write_post($post);

ok(-e "$base_path/twitter/934234566/images/01/thing1.jpg", 'first image written');
ok(-e "$base_path/twitter/934234566/images/02/thing2.jpg", 'first image written');


remove_tree($base_path);

done_testing();

