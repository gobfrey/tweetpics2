package TweetPics::Persistence::Website;

use Template;

use TweetPics::Persistence;
use TweetPics::Source;
use TweetPics::Utils;
@ISA = ( 'TweetPics::Persistence' );

use strict;
use warnings;

use JSON;

sub new
{
	my ($class, $path, $base_web_path) = @_;

	die "No base path in Persistence::Website\n" unless
		$path && -d $path;

	#ensure there's a trailing slash
	$path .= '/' unless ($path =~ m#/$#);

	$base_web_path = '/' unless $base_web_path;
	$base_web_path .= '/' unless ($base_web_path =~ m#/$#);

	my $tt = Template->new({
			#		INCLUDE_PATH => "$FindBin::Bin/../../../../templates",
		INCLUDE_PATH => '/home/adamfiel/adamfield.net/tweetpics/new_version/templates',
		INTERPOLATE => 1
	}) or die "$Template::ERROR\n";

	return bless {
		base_path => $path,
		base_web_path => $base_web_path,
		renderer => $tt
	}, $class;
}

sub write_post
{
	my ($self, $post) = @_;

	my $image_paths = [];
	my $images = $post->get_images();
	foreach my $image (@{$images})
	{
		$self->_write_image($post, $image);
		push @{$image_paths}, $self->_image_web_path($post, $image);
	}

	my $data =
	{
		base_path => $self->{base_web_path},
		post => $post,
		image_paths => $image_paths
	};

	my $html;
	$self->{renderer}->process('post.tt', $data, \$html) or die $self->{renderer}->error(), "\n";

	TweetPics::Utils::write_to_file($self->_post_file_path($post), $html);
}

sub post_exists
{
	my ($self, $post) = @_;

	my $path = $self->_post_file_path($post);

	return 1 if -e $path;
	return 0;
}


sub _post_file_path
{
	my ($self, $post) = @_;

	return $self->_post_base_path($post) . 'index.html';
}

sub _image_file_path
{
	my ($self, $post, $image) = @_;

	return $self->_post_base_path($post) . $image->get_filename;

}

sub _post_base_path
{
	my ($self, $post) = @_;

	my $path = $self->{base_path};
	$path .= $post->get_source_name . '/';
	$path .= $post->get_source_id . '/';

	return $path;
}

sub _image_web_path
{
	my ($self, $post, $image) = @_;

	return $self->_post_web_path($post) . $image->get_filename;
}

sub _post_web_path
{
	my ($self, $post) = @_;
	my $path = $self->{base_web_path} . $post->get_source_name . '/' . $post->get_source_id . '/';
}

sub _write_image
{
	my ($self, $post, $image) = @_;

	my $image_path .= $self->_image_file_path($post, $image);
	TweetPics::Utils::write_to_file($image_path, $image->get_data());
}

1;
