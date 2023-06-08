package TweetPics::Source::Mastadon;

use local::lib;

use TweetPics::Source;
@ISA = ( 'TweetPics::Source' );

use strict;
use warnings;

use TweetPics::Post;
use TweetPics::Image;
use LWP::Simple;

sub new
{
	my ($class) = @_;

	my $self = bless {
		next_page_url => 'https://mastodonapp.uk/users/gobfrey/outbox?page=true',
		toots => [],
	}, $class;

	return $self;
}

sub next_post
{
	my ($self) = @_;

	my $toot = $self->_next_interesting_toot();

	return $self->_create_post_from_toot($toot) if $toot;
	return undef;
}

sub _create_post_from_toot
{
	my ($self, $toot) = @_;

	return undef unless $toot;

	my $images = $self->_create_images_from_toot($toot);

	use HTML::Parse;
	use HTML::FormatText;
	my $plain_text = HTML::FormatText->new->format(parse_html($toot->{content}));

	my $id_url = $toot->{id};
	$id_url =~ m/\d*$/;
	my $id = $&;

	my $data = {
		message => $plain_text,
		images => $images,
		datestamp => $toot->{published}, 
		source_name => 'mastadonapp.uk',
		source_id => $id
	};

	my $post = TweetPics::Post->new($data);

	return $post;
}

sub _create_images_from_toot
{
	my ($self, $toot) = @_;

	my $images = [];
	if (
		$toot->{attachment}
	)
	{
		foreach my $image (@{$toot->{attachment}})
		{
			next unless $image->{mediaType} =~ m#^image/#;
			push @{$images}, TweetPics::Image->new_from_url($image->{url});
		}
	}

	return $images;
}

sub _next_interesting_toot
{
	my ($self) = @_;

	while (1)
	{
		my $toot = $self->_next_toot;

		last if !defined $toot;

		if ($self->_toot_is_interesting($toot))
		{
			return $toot;
		}
	}
	return undef;
}

sub _next_toot
{
	my ($self) = @_;

	if (!scalar @{$self->{toots}})
	{
		$self->_load_next_page;
	}

	return undef unless scalar @{$self->{toots}};

	my $toot = shift @{$self->{toots}};

	return $toot->{object};
}

sub _toot_is_interesting
{
	my ($self, $toot) = @_;

	#not interesting if it doesan't have at least one photo
	return 0 unless $toot->{attachment};

	foreach my $attachment (@{$toot->{attachment}})
	{
		return 1 if $attachment->{mediaType} =~ m#^image/#;
	}

	return 0;
}

sub _load_next_page
{
	my ($self) = @_;
	
	my $url = $self->{next_page_url};
	return unless $url;

	my $page = TweetPics::Utils::json_at_url($url);
	return unless $page;

	$self->{toots} = $page->{orderedItems};
	$self->{next_page_url} = $page->{next}; #untested -- I've only just started on mastadon. Only one page of content.
}



1;

