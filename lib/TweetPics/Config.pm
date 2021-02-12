package TweetPics::Config;

use Config::IniFiles;

use strict;
use warnings;
use feature 'state';

sub new
{
	my ($class, $ini_file_paths) = @_;

	state $instance;

	#implents singleton pattern
	if (!defined $instance)
	{
		$instance = bless {}, $class;
	}
	return $instance;
}

sub load_ini_file
{
	my ($instance, $tag, $ini_file_path) = @_;

	$instance->{$tag} = Config::IniFiles->new( -file => $ini_file_path );
}

sub value
{
	my ($instance, $tag, @path) = @_;

	return $instance->{$tag}->val(@path);
}

1;
