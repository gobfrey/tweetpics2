package TweetPics::Source::Twitter;

use local::lib;

use TweetPics::Source;
@ISA = ( 'TweetPics::Source' );

use strict;
use warnings;

use TweetPics::Post;
use TweetPics::Image;
use Twitter::API;
use LWP::Simple;

sub new
{
	my ($class) = @_;

	my $self = bless {
		twitter => undef,
		tweets => [],
		twitter_params => undef,
		max_id => undef,
	}, $class;

	$self->{twitter} = $self->_initialise_twitter();

	return $self;
}

sub next_post
{
	my ($self) = @_;

	my $tweet = $self->_next_interesting_tweet();

	return $self->_create_post_from_tweet($tweet);
}

sub _create_post_from_tweet
{
	my ($self, $tweet) = @_;

	my $post = TweetPics::Post->new();
	$post->set_message($tweet->{text});
	$post->set_source_data($tweet);
	$post->set_datestamp($tweet->{created_at});

	my $images = [];
	if (
		$tweet->{extended_entities}
		&& $tweet->{extended_entities}->{media}
	)
	{
		foreach my $media (@{$tweet->{extended_entities}->{media}})
		{
			next unless $media->{type} eq 'photo';
			push @{$images}, $self->_create_image_from_tweet_media($media);
		}
	}

	$post->set_images($images);

	return $post;
}

sub _create_image_from_tweet_media
{
	my ($self, $tweet_media) = @_;

	my $image = TweetPics::Image->new();

	$image->set_source_url($tweet_media->{media_url});
	$image->set_data($self->_get_image_data($tweet_media->{media_url}));

	return $image;
}

sub _get_image_data
{
	my ($self, $url) = @_;

	foreach (1..3)
	{
		my $image_data = get($url);
		return $image_data if $image_data;
		sleep(5); #wait and retry
	}

	die "Couldn't download image at $url\n";
}

sub _next_interesting_tweet
{
	my ($self) = @_;

	while (1)
	{
		my $tweet = $self->_next_tweet;

		last if !defined $tweet;

		return $tweet if $self->_tweet_is_interesting($tweet);
	}
	return undef;
}

sub _next_tweet
{
	my ($self) = @_;

	if (!scalar @{$self->{tweets}})
	{
		$self->_load_next_page;
	}

	return undef unless scalar @{$self->{tweets}};

	my $tweet = shift @{$self->{tweets}};

	return $tweet;
}

sub _tweet_is_interesting
{
	my ($self, $tweet) = @_;

	#not interesting if it's a retweet
	return 0 if $tweet->{retweeted_status};

	#not interesting if it doesan't have at least one photo
	return 0 unless $tweet->{entities}->{media};
	foreach my $media (@{$tweet->{entities}->{media}})
	{
		return 1 if $media->{type} eq 'photo';
	}
	return 0;
}

sub _load_next_page
{
	my ($self) = @_;

	my $params = {
		screen_name => 'gobfrey',
		count => 200,
		exclude_replies => 'true',
		include_rts => 'false',
		trim_user => 'true'
	};

	$params->{max_id} = $self->{max_id} if $self->{max_id};
	my $statuses = $self->{twitter}->user_timeline($params);

	$self->{tweets} = $statuses;
	$self->{max_id} = $statuses->[$#{$statuses}]->{id};
}

sub _initialise_twitter
{
	my ($self) = @_;

	my $cfg = TweetPics::Config->new();

	my $client = Twitter::API->new_with_traits(
		traits              => 'Enchilada',
		consumer_key        => $cfg->value('secrets','twitter','consumer_key'),
		consumer_secret     => $cfg->value('secrets','twitter','consumer_secret'),
		access_token        => $cfg->value('secrets','twitter','access_token'),
		access_token_secret => $cfg->value('secrets','twitter','access_token_secret')
	);

	return $client;
}



1;

