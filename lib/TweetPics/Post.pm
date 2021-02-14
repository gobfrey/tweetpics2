package TweetPics::Post;

use strict;
use warnings;

sub new
{
	my ($class, $data) = @_;

	my $self = bless {}, $class;

	foreach my $fieldname (
		'message', #the text associated with this pos
		'datestamp', #when it was posted
		'images', #images arrayref
		'source_name', #e.g. twitter
		'source_id' #id on the source platform
	)
	{
		$self->{$fieldname} = $data->{$fieldname};
	}

	return $self;
}

sub get_message
{
	my ($self) = @_;

	return $self->{message};
}

sub get_datestamp
{
	my ($self) = @_;

	return $self->{datestamp};
}

sub get_images
{
	my ($self) = @_;

	return $self->{images};
}

sub get_source_name
{
	my ($self) = @_;

	return $self->{source_name};
}

sub get_source_id
{
	my ($self) = @_;

	return $self->{source_id};
}

1;
