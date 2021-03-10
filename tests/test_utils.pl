#!/usr/bin/perl

use FindBin;
use lib "$FindBin::Bin/../lib";

use Test::More;

use strict;
use warnings;

use_ok( 'TweetPics::Utils' );

my $url = 'https://www.wikipedia.org/static/favicon/wikipedia.ico';
my $filename = TweetPics::Utils::url_filename($url);
is($filename, 'wikipedia.ico');

my $content = TweetPics::Utils::download_from_url($url);
cmp_ok(length($content), '>', 100,'image is more than 100 bytes');

my $bad_url = 'http://blah.blah.blah/blahblahblaj.txt';
eval {$content = TweetPics::Utils::download_from_url($bad_url);};
like($@,qr/^Couldn't download.*/,'bad URL causes exception');

my $dirs = TweetPics::Utils::directories_in_directory("$FindBin::Bin/../");

is_deeply([sort @{$dirs}], [sort('www','bin','lib','var','tests','templates')], 'directories_in_directories');



done_testing();
