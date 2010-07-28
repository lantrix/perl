#!/usr/bin/perl -w
# $Id: dg_sqllog.pl,v 1.2 2010/07/28 07:08:43 ted Exp $

# This is a very fast script.  As long as your database can keep up, there
# should be no problems. If you try this, make sure the this process gets started before DG or DG
# will freeze until this starts.  During bootup, this can be a real pain.

# Derived from version by Jason M Kusar (jkusar_ @ pixelvizions_ ._com) remove spaces and _

# Newer version by Lantrix http://techdebug.com/dansguardian/
# - fixed problem of high CPU usage by perl
# - Tested on OpenBSD 4.4
# - Reworked to log all fields for default logging under Dansguardian 2.10.x.x
# - Tested agains PostgreSQL x.x

use IO::File;
use DBI;
use strict;

my $conn;
my $status;
my $ret;

# Setup your parameters here
my $dbtype="Pg";				# SQL Server type, usually mysql or Pg
my $server="127.0.0.1";				# SQL Server IP
my $port=5432;					# TCP Port for SQL server
my $user="filter";				# SQL username
my $pass="dansfilter";				# SQL password
my $db="logging";				# Database to store logs in
my $table="filter";				# Table to store logs in
my $logfile="/var/log/dansguardian/access.log"; # location of logfile

my $dbh=DBI->connect("DBI:$dbtype:database=$db;host=$server;port=$port",$user,$pass) or die "Can't connect to db: ", DBI->errstr;
# Prepareing the statement ahead of time GREATLY increases the speed.
my $sth=$dbh->prepare("INSERT INTO $table (datetime,ident,ip,url,what,how,size,one,reason,three,statuscode,mimetype,six,seven,eight) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)");

my $tail = new IO::File;
$tail->open("<$logfile");

while(1){
	my @lines=$tail->getlines();
	if(0==scalar(@lines)){
		# wait 1 second before trying again...
		# to keep from hogging CPU cycles
		sleep 1;
	}else{
		my $line;
		foreach $line(@lines){
			chomp $line;
			chop $line;
			$line = substr $line,1;
			my($dt,$id,$ip,$url,$what,$how,$size,$one,$reason,$three,$statuscode,$mimetype,$six,$seven,$eight)=split /","/,$line;
			$sth->execute($dt,$id,$ip,$url,$what,$how,$size,$one,$reason,$three,$statuscode,$mimetype,$six,$seven,$eight);
		}
	}
}
