package TweetPics::Utils;

use File::Basename;
use File::Path qw/make_path/;

use strict;
use warnings;

#returns the data that is available at a URL
sub download_from_url
{
	my ($url) = @_;

	use LWP::UserAgent;
	use open qw(:std :utf8);

	my $retries = 5;

	while ($retries)
	{
		$retries--;	
		my $ua = LWP::UserAgent->new( ssl_opts => { verify_hostname => 0 } );
		$ua->agent('TweetPics');
		my $response = $ua->get($url);

		if ( $response->is_success ) {
		    return $response->decoded_content;
		}
	}

	die "Couldn't download $url\n";
}

sub json_at_url
{
	my ($url) = @_;

	use JSON qw/decode_json/;

	my $content = TweetPics::Utils::download_from_url($url);
	return decode_json($content) if $content;
	return undef;

}

#returns the filename part of a URL
sub url_filename
{
	my ($url) = @_;

	use URI;

	my $uri = URI->new($url);
	my $filename = ($uri->path_segments)[-1];

	return $filename;
}

sub write_to_file
{
	my ($filepath, $data) = @_;

	my $dir = dirname($filepath); #lazy directory creation
	make_path($dir) unless -d $dir;

	open my $fh, ">:encoding(UTF-8)", $filepath or die "Couldn't open $filepath for writing\n";
	print $fh $data;
	close $fh;
}

sub read_from_file
{
	my ($filepath) = @_;

	open my $fh, "<", $filepath or die "Couldn't open $filepath for reading\n";
	my $data = do { local $/; <$fh> };
	close $fh;

	return $data;
}

sub directories_in_directory
{
	my ($dir) = @_;

	die "Attempt to list non-directory\n" unless -d $dir;

	opendir(DIR, $dir) or die $!;

	my $dirs = [];
	while (my $file = readdir(DIR)) {
        	next if ($file =~ m/^\./);
		next unless -d $dir.$file;
		push @{$dirs}, $file;
	}
	closedir(DIR);

	return $dirs;
}

sub files_in_directory
{
	my ($dir) = @_;

	die "Attempt to list non-directory\n" unless -d $dir;

	opendir(DIR, $dir) or die $!;

	my $files = [];
	while (my $file = readdir(DIR)) {
        	next if ($file =~ m/^\./);
		next unless -f $dir.$file;
		push @{$files}, $file;
	}
	closedir(DIR);

	return $files;
}

1;

