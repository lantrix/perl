#!/usr/bin/perl -w

#This is a very fast script.  As long as your database can keep up, there
#should be no problems.  Our database is on a Athlon XP 1700+ with 512MB of
#ram and sits on the same 100Mb network as the filter.  If you try this, make
#sure the this process gets started before DG or DG will freeze until this
#starts.  During bootup, this can be a real pain.
#
#Hope this helps someone.
#--Jason M Kusar (jkusar_ @ pixelvizions_ ._com) remove spaces and _ 


use IO::File;
use DBI;
use strict;

my $server="192.168.1.7";
my $port=3306;
my $user="filter";
my $pass="filter";
my $db="filter";
my $table="log";

my
$dbh=DBI->connect("DBI:mysql:database=$db;host=$server;port=$port",$user,$pa
ss)
                or die "Can't connect to db: ", DBI->errstr;
# Prepareing the statement ahead of time GREATLY increases the speed.
my $sth=$dbh->prepare("INSERT INTO $table
(datetime,ident,ip,url,what,how,size)
                                       VALUES(?,?,?,?,?,?,?)");
open(FIFO, "< /var/log/dansguardian/access.log")
                or die "Can't open log FIFO: $!\n";
LOG: while (1) {
                my $message = <FIFO>;
                next LOG unless defined $message; # interrupted or nothing
logged
                chomp $message;
                chop $message;
                $message = substr $message,1;
                my($dt,$id,$ip,$url,$what,$how,$size)=split /","/,$message;
                $sth->execute($dt,$id,$ip,$url,$what,$how,$size);
}

