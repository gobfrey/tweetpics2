package TweetPics::Utils;

use strict;
use warnings;

#returns the data that is available at a URL
sub download_from_url
{
	my ($url) = @_;
	use LWP::Simple;

	foreach (1..3)
	{
		my $image_data = get($url);
		return $image_data if $image_data;
		sleep(5); #wait and retry
	}

	die "Couldn't download $url\n";
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

	open my $fh, ">", $filepath or die "Couldn't open $filepath for writing\n";
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

