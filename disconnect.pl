#!/bin/perl
#
#-----------------------------------------------------------------------
#  Script Name:		disconnect.pl
#  Function:		disconnects windows share sessions with any sort of idle time and doesn't //have any open files; combine with cron for windows
#			derived from a PHP version by David @ PHP4IT.com 2006-01-14
#  Author:		Lantrix @ techdebug.com
#
#  Version:		$Id: disconnect.pl,v 1.1 2008/03/07 03:17:31 ted Exp $
#######################################
use strict;

#######################################
#
# Configuration & Setup
#
sub trim($);
# Variables
my $line;
my $cmd;
my $out;
my $idle_time;
my $open_files;
my $disconnect;
my $computer_name;
my $files;
# Arrays
my @open_files = ();
my @disconnect_these = ();


#######################################
#
# function definition
#
# whitespace trim function
sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

#######################################
#
# main section
#

$cmd = "net session";
$out = system`($cmd)`;
foreach $line ($out) {
	$line = trim($line);
	if (substr($line, 0, 2) = "\\\\") {
		my @t = split(/:/, $line);
		$idle_time = substr(@t[0], -1);
		$files = split(' ', @t[0]);
		@open_files = @open_files[sizeof($files)-2];
		if ($idle_time > 0 || !$open_files) {
			$computer_name = trim(substr($line, 0, 17));
			@disconnect_these = (@disconnect_these, $computer_name);
			#print "$computer_name\t$idle_time\t$open_files\n";
		}
	}
}
if (sizeof(@disconnect_these)) {
	foreach $disconnect (@disconnect_these) {
		#system("net session $disconnect /delete /Y");
	}
}
