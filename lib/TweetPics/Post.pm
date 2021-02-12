package TweetPics::Post;

use strict;
use warnings;

sub value_names
{
	return qw/
		message
		datestamp
		source_data
		images
	/;
}	

sub new
{
	my ($class) = @_;

	my $self = bless
	{
		message => undef,
		datestamp => undef,
		source_data => undef,
		images => undef
	}, $class;

	return $self;
}

sub set_message
{
	my ($self,$value) = @_;

	$self->{message} = $value;
}

sub get_message
{
	my ($self) = @_;

	return $self->{message};
}

sub set_datestamp
{
	my ($self,$value) = @_;

	$self->{datestamp} = $value;
}

sub get_datestamp
{
	my ($self) = @_;

	return $self->{datestamp};
}

sub set_source_data
{
	my ($self,$value) = @_;

	$self->{source_data} = $value;
}

sub get_source_data
{
	my ($self) = @_;

	return $self->{source_data};
}

sub set_images
{
	my ($self,$value) = @_;

	$self->{images} = $value;
}

sub get_images
{
	my ($self) = @_;

	return $self->{images};
}


1;
