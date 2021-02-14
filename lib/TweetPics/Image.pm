package TweetPics::Image;

use strict;
use warnings;

use TweetPics::Utils;
use LWP::Simple;

sub new
{
	my ($class, $data) = @_;

	my $self = bless {}, $class;
	
	foreach my $fieldname (
		'filename', #a filename to use when writing somewhere
		'data' #the binary of the image
	)
	{
		$self->{$fieldname} = $data->{$fieldname};
	}

	return $self;
}

sub new_from_url
{
	my ($class, $url) = @_;

	my $data =
	{
		'filename' => TweetPics::Utils::url_filename($url),
		'data' => TweetPics::Utils::download_from_url($url)
	};

	return $class->new($data);
}

sub get_filename
{
	my ($self) = @_;

	return $self->{filename};
}

sub get_data
{
	my ($self) = @_;

	return $self->{data};
}


1;
