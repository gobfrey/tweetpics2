package TweetPics::Updater;

use strict;
use warnings;


sub new
{
	my ($class, $source, $persistence) = @_;

	die "Updater missing source or persistence\n" unless $source && $persistence;

	return bless {
		source => $source,
		persistence => $persistence
	}, $class;
}

sub update
{
	my ($self) = @_;

	my $source = $self->{source};
	my $persistence = $self->{persistence};

	while (my $post = $source->next_post())
	{
		last if $persistence->post_exists($post); #harvest until you see one you've seen before
		$persistence->write_post($post);
	}
}

1;
