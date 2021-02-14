#interface for storing posts locally

package TweetPics::Persistence;

use strict;
use warnings;

use TweetPics::Post;

sub write_post
{
	die "Persistence::write_post called in interface class\n";
}

1;
