#interface for storing posts locally

package TweetPics::Persistence;

use strict;
use warnings;

use TweetPics::Post;

sub write_post
{
	my ($self, $post) = @_;
	die "Persistence::write_post called in interface class\n";
}

sub post_exists
{
	my ($self, $post) = @_;
	die "Persistence::post_exist called in interface class\n";
}

1;
