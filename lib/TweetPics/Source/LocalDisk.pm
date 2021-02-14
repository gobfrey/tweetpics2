package TweetPics::Source::LocalDisk;

use local::lib;

use TweetPics::Source;
@ISA = ( 'TweetPics::Source' );

use strict;
use warnings;

use TweetPics::Post;
use TweetPics::Image;
use JSON;

sub new
{
	my ($class, $path) = @_;

	die "No base path in Persistence::LocalDisk\n" unless
		$path && -d $path;

	#ensure there's a trailing slash
	$path .= '/' unless ($path =~ m#/$#);

	my $self =  bless {
		base_path => $path,
		post_refs => undef
	}, $class;

	$self->_initialise_post_refs();

	return $self;
}

sub next_post
{
	my ($self) = @_;

	my $source_name = $self->_next_post_source_name;

	if ($source_name && scalar @{$self->{post_refs}->{$source_name}})
	{
		my $source_id = shift @{$self->{post_refs}->{$source_name}};
		return $self->_hydrate_post($source_name, $source_id);
	}
	return undef;
}

sub _next_post_source_name
{
	my ($self) = @_;

	foreach my $source_name (sort keys %{$self->{post_refs}})
	{
		return $source_name if scalar @{$self->{post_refs}->{$source_name}};
	}
	return undef;
}

sub _hydrate_post
{
	my ($self, $source_name, $source_id) = @_;

	my $post_dir = $self->{base_path} . "/$source_name/$source_id/";

	my $images = $self->_hydrate_images($post_dir . 'images/');

	my $data = decode_json(TweetPics::Utils::read_from_file($post_dir . 'data.json'));
	$data->{images} = $images;

	return TweetPics::Post->new($data);

}

sub _hydrate_images
{
	my ($self, $image_base_dir) = @_;

	my $images = [];

	my $i = 1;
	my $image_dir = $image_base_dir . sprintf("%02d", $i) . '/';

	while (-e $image_dir)
	{
		my $files = TweetPics::Utils::files_in_directory($image_dir);
		my $image_file = $image_dir . $files->[0];

		my $image = TweetPics::Image->new({
			filename => $files->[0],
			data => TweetPics::Utils::read_from_file($image_file)
		});
		push @{$images},$image;

		$i++;
		$image_dir = $image_base_dir . sprintf("%02d", $i) . '/';
	}



	return $images;
}


sub _initialise_post_refs
{
	my ($self) = @_;

	my $source_names = TweetPics::Utils::directories_in_directory($self->{base_path});

	foreach my $source_name (@{$source_names})
	{
		my $post_ids = TweetPics::Utils::directories_in_directory($self->{base_path} . $source_name . '/');

		foreach my $post_id (sort {$b <=> $a} @{$post_ids})
		{
			push @{$self->{post_refs}->{$source_name}}, $post_id;
		}
	}
}


1;

