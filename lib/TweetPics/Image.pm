package TweetPics::Image;

use strict;
use warnings;

sub new
{
	my ($class) = @_;

	my $self = bless
	{
		source_url => undef,
		source_filename => undef,
		type => undef,
		data => undef
	}, $class;

	return $self;
}

sub set_source_url
{
	my ($self,$value) = @_;

	$self->{source_url} = $value;
}

sub get_source_url
{
	my ($self) = @_;

	return $self->{source_url};
}

sub set_source_filename
{
	my ($self,$value) = @_;

	$self->{source_filename} = $value;
}

sub get_source_filename
{
	my ($self) = @_;

	return $self->{source_filename};
}

sub set_type
{
	my ($self,$value) = @_;

	$self->{type} = $value;
}

sub get_type
{
	my ($self) = @_;

	return $self->{type};
}

sub set_data
{
	my ($self,$value) = @_;

	$self->{data} = $value;
}

sub get_data
{
	my ($self) = @_;

	return $self->{data};
}


1;
