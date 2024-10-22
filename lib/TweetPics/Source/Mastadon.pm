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
		next_page_url => 'https://mastodonapp.uk/api/v1/accounts/109839538378208155/statuses',
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
		datestamp => $toot->{created_at}, 
		source_name => 'mastadonapp.uk',
		source_id => $id
	};

	#print "Create: \n";

	my $post = TweetPics::Post->new($data);

	return $post;
}

sub _create_images_from_toot
{
	my ($self, $toot) = @_;

	my $images = [];
	if (
		$toot->{media_attachments}
	)
	{
		foreach my $image (@{$toot->{media_attachments}})
		{
			next unless $image->{type} eq 'image';
			push @{$images}, TweetPics::Image->new_from_url($image->{url});
		}
	}

	return $images;
}

sub _next_interesting_toot
{
	my ($self) = @_;

	#print STDERR "MAIN LOOP\n";
	while (1)
	{
		#print STDERR "Getting next toot\n";
		my $toot = $self->_next_toot;

		last if !defined $toot;

		#print STDERR "Checking if it's interesting:";
		if ($self->_toot_is_interesting($toot))
		{
			#print STDERR " IS\n";
			return $toot;
		}
		#print STDERR " NOT\n";
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

	#print STDERR "ARE THERE TOOTS?";

	return undef unless scalar @{$self->{toots}};

	my $toot = shift @{$self->{toots}};

	return $toot;
}

sub _toot_is_interesting
{
	my ($self, $toot) = @_;

	#print STDERR "Checking " . $toot->{id} . "\n";	

	#not interesting if it doesan't have at least one photo
	return 0 unless $toot->{media_attachments};

	foreach my $attachment (@{$toot->{media_attachments}})
	{
		return 1 if $attachment->{type} eq 'image';
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

	$self->{toots} = $page;
	$self->{next_page_url} = undef;
	#$self->{next_page_url} = $page->{next}; #untested -- I've only just started on mastadon. Only one page of content.
}



1;

