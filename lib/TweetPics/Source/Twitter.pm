package TweetPics::Source::Twitter;

use local::lib;

use TweetPics::Source;
@ISA = ( 'TweetPics::Source' );

use strict;
use warnings;

use TweetPics::Post;
use TweetPics::Image;
use Twitter::API;


sub new
{
	my ($class) = @_;

	my $self = bless {
		twitter => undef,
		tweets => [],
		twitter_params => undef
	}, $class;

	$self->{twitter} = $self->_initialise_twitter();

	return $self;
}

sub next_post
{
	my ($self) = @_;

	if (!scalar @{$self->{tweets}})
	{
		$self->_load_next_page;
	}

	return undef unless scalar @{$self->{tweets}};

	return shift @{$self->{tweets}};
}

sub _load_next_page
{
	my ($self) = @_;

	

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

