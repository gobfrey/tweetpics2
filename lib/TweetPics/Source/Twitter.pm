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
	my ($class, $twitter_auth_params) = @_;

	return bless {
		twitter => $self->initialise_twitter($twitter_auth_params),
		tweets => [],
		twitter_params => undef
	}, $class;
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
	



}

sub _initialise_twitter
{
	my ($self, $twitter_auth_params) = @_;

	my $client = Twitter::API->new_with_traits(
		traits              => 'Enchilada',
		consumer_key        => $twitter_auth_params->{consumer_key},
		consumer_secret     => $twitter_auth_params->{consumer_secret},
		access_token        => $twitter_auth_params->{access_token},
		access_token_secret => $twitter_auth_params->{access_token_secret}
	);

	return $client;
}



1;

