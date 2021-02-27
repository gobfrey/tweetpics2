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

	return $self->_create_post_from_tweet($tweet) if $tweet;
	return undef;
}

sub _create_post_from_tweet
{
	my ($self, $tweet) = @_;

	return undef unless $tweet;

	my $images = $self->_create_images_from_tweet($tweet);

	my $text = $tweet->{text};
	$text = $tweet->{full_text} if $tweet->{full_text};

	my $data = {
		message => $text,
		images => $images,
		datestamp => $tweet->{created_at}, 
		source_name => 'twitter',
		source_id => $tweet->{id}
	};

	my $post = TweetPics::Post->new($data);

	return $post;
}

sub _create_images_from_tweet
{
	my ($self, $tweet) = @_;

	my $images = [];
	if (
		$tweet->{extended_entities}
		&& $tweet->{extended_entities}->{media}
	)
	{
		foreach my $media (@{$tweet->{extended_entities}->{media}})
		{
			next unless $media->{type} eq 'photo';
			push @{$images}, TweetPics::Image->new_from_url($media->{media_url});
		}
	}

	return $images;
}

sub _next_interesting_tweet
{
	my ($self) = @_;

	while (1)
	{
		my $tweet = $self->_next_tweet;

		last if !defined $tweet;

		if ($self->_tweet_is_interesting($tweet))
		{
			return $tweet;
		}
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
		screen_name => 'gobfrey', #move to config
		count => 200,
		exclude_replies => 'true',
		include_rts => 'false',
		trim_user => 'true',
		tweet_mode => 'extended'
	};

	$params->{max_id} = $self->{max_id} if $self->{max_id};

	my $statuses = $self->{twitter}->user_timeline($params);

	$self->{tweets} = $statuses;
	$self->{max_id} = ($statuses->[$#{$statuses}]->{id} - 1) if scalar @{$statuses};
}

sub _initialise_twitter
{
	my ($self) = @_;

	my $cfg = TweetPics::Config->new();

	my $client = Twitter::API->new_with_traits(
		traits              => [ 'Enchilada','RateLimiting' ],
		consumer_key        => $cfg->value('secrets','twitter','consumer_key'),
		consumer_secret     => $cfg->value('secrets','twitter','consumer_secret'),
		access_token        => $cfg->value('secrets','twitter','access_token'),
		access_token_secret => $cfg->value('secrets','twitter','access_token_secret')
	);

	return $client;
}



1;

