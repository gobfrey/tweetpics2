package TweetPics::Utils;

use strict;
use warnings;

#returns the data that is available at a URL
sub download_from_url
{
	my ($url) = @_;
	use LWP::Simple;

	foreach (1..3)
	{
		my $image_data = get($url);
		return $image_data if $image_data;
		sleep(5); #wait and retry
	}

	die "Couldn't download image at $url\n";
}


#returns the filename part of a URL
sub url_filename
{
	my ($url) = @_;

	use URI;

	my $uri = URI->new($url);
	my $filename = ($uri->path_segments)[-1];

	return $filename;
}



1;

