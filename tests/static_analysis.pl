#!/usr/bin/perl

use local::lib;

use strict;
use warnings;

use Perl::Critic;
my $file = shift;
my $critic = Perl::Critic->new(-severity => 'brutal');
my @violations = $critic->critique($file);
print @violations;

