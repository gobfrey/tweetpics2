package TweetPics::Persistence::WebsiteIndexes;

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
		renderer => $tt,
		images_per_index => 20,
		index_number => 1,
		current_images => []
	}, $class;
}

sub _build_index
{
	my ($self, $include_next) = @_;

	my $previous_path = undef;
	if ($self->{index_number} > 1)
	{
		$previous_path = $self->{base_web_path} . $self->_previous_index_filename;
	}

	my $next_path = undef;
	if ($include_next)
	{
		$next_path = $self->{base_web_path} . $self->_next_index_filename
	}

	my $data = {
		base_path => $self->{base_web_path},
		image_data => $self->{current_images},
		next_path => $next_path,
		previous_path => $previous_path
	};

	my $html;
	$self->{renderer}->process('index.tt', $data, \$html) or die $self->{renderer}->error(), "\n";

	my $filename = $self->_current_index_filename;

	TweetPics::Utils::write_to_file($self->{base_path} . $filename, $html);

}



sub write_post
{
	my ($self, $post) = @_;

	my $prev_filename = undef;
	if ($self->{index_number} > 1)
	{
		$prev_filename = $self->{base_path} . $self->_previous_index_filename;
	}

	#write the last page and move onto the next
	if (scalar @{$self->{current_images}} >= $self->{images_per_index})
	{
		$self->_build_index(1);

		$self->{current_images} = [];
		$self->{index_number}++;
	}

	my $image_data = $self->_post_images_data($post);

	push @{$self->{current_images}}, @{$image_data};

	$self->_build_index(undef, $prev_filename);
}

sub post_exists
{
	return 0; #always rebuild all indexes
}

sub _current_index_filename
{
	my ($self) = @_;

	return $self->_generate_index_filename($self->{index_number});
}

sub _previous_index_filename
{
	my ($self) = @_;

	die "Cannot generate index filename for < 1" unless $self->{index_number} > 1;

	return $self->_generate_index_filename($self->{index_number}-1);
}

sub _next_index_filename
{
	my ($self) = @_;

	return $self->_generate_index_filename($self->{index_number}+1);
}

sub _generate_index_filename
{
	my ($self, $index_number) = @_;

	return 'index.html' if ($index_number == 1); 

	return 'index_' . $index_number . '.html';

}

sub _post_images_data
{
	my ($self, $post) = @_;

	my $paths = [];

	my $images = $post->get_images;

	foreach my $image (@{$images})
	{
		push @{$paths}, {
			src => $self->_image_web_path($post,$image),
			is_wide => ($image->is_wide ? 1 : 0),
			post_path => $self->_post_web_path($post),
			post_message => $post->get_message
		};
	}

	return $paths;
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

1;
