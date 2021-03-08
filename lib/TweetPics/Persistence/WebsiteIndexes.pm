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
	my ($class, $website_persistence) = @_;

	die "No website persistence in Persistence::WebsiteIndexes\n" unless $website_persistence;

	return bless {
		website => $website_persistence,
		base_path => $website_persistence->get_base_path,
		base_web_path => $website_persistence->get_base_web_path,
		renderer => $website_persistence->get_renderer,
		images_per_index => 30,
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

	return unless $self->_post_page_exists($post); #don't index unless the post has a page

	#write the last page and move onto the next
	if (scalar @{$self->{current_images}} >= $self->{images_per_index})
	{
		$self->_build_index(1);

		$self->{current_images} = [];
		$self->{index_number}++;
	}

	my $image_data = $self->_post_images_data($post);

	push @{$self->{current_images}}, @{$image_data};

	$self->_build_index(0);
}

sub _post_page_exists
{
	my ($self, $post) = @_;

	return $self->{website}->post_exists($post);
}

sub post_exists
{
	my ($self, $post) = @_;

	return 0; #posts never "exist" in indexes, because it's always a complete rewrite
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
			src => $self->{website}->image_web_path($post,$image),
			is_wide => ($image->is_wide ? 1 : 0),
			post_path => $self->{website}->post_web_path($post),
			post_message => $post->get_message
		};
	}

	return $paths;
}


1;
