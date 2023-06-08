package TweetPics::UtilsTest;

use File::Basename;
use File::Path qw/make_path/;

use strict;
use warnings;

#returns the data that is available at a URL
sub download_from_url
{
	my ($url) = @_;
	use LWP::Simple;

	use constant RETRIES => 3;
	use constant WAIT_TIME => 5;

	foreach (1..RETRIES)
	{
		my $image_data = get($url);
		return $image_data if $image_data;
		sleep WAIT_TIME; #wait and retry
	}

	die "Couldn't download $url\n";
}


1;

