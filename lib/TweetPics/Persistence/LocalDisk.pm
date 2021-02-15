package TweetPics::Persistence::LocalDisk;

use TweetPics::Persistence;
use TweetPics::Source;
use TweetPics::Utils;
@ISA = ( 'TweetPics::Persistence' );

use strict;
use warnings;

use JSON;
use File::Path qw/make_path/;

sub new
{
	my ($class, $path) = @_;

	die "No base path in Persistence::LocalDisk\n" unless
		$path && -d $path;

	#ensure there's a trailing slash
	$path .= '/' unless ($path =~ m#/$#);

	return bless {
		base_path => $path
	}, $class;
}

sub post_exists
{
	my ($self, $post) = @_;

	my $path = $self->_post_base_path($post);

	return 1 if -e $path . 'data.json';
	return 0;
}

sub write_post
{
	my ($self, $post) = @_;

	my $path = $self->_post_base_path($post);
	make_path($path) unless -d $path;

	my $data = {
		'message' => $post->get_message(),
		'datestamp' => $post->get_datestamp(),
		'source_name' => $post->get_source_name(),
		'source_id' => $post->get_source_id
	};

	my $json = encode_json($data);

	TweetPics::Utils::write_to_file($path . 'data.json', $json);

	my $images = $post->get_images();

	foreach my $i (0 .. $#{$images})
	{
		my $image_path = "$path/images/";
		$image_path .= sprintf("%02d", $i+1) . '/';
		$self->_write_image($image_path, $images->[$i]);
	}
}

sub _post_base_path
{
	my ($self, $post) = @_;

	my $path = $self->{base_path};
	$path .= $post->get_source_name . '/';
	$path .= $post->get_source_id . '/';

	return $path;
}


sub _write_image
{
	my ($self, $image_path, $image) = @_;

	make_path($image_path) unless -d $image_path;
	$image_path .= $image->get_filename;
	TweetPics::Utils::write_to_file($image_path, $image->get_data());
}

1;
