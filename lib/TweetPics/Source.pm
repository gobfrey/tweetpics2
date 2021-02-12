# Interface for post source

package TweetPics::Source;

use strict;
use warnings;

use TweetPics::Post;

sub next_post
{

	die "Source::next_post called in interface class\n";
}

1;
