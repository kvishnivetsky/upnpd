#!/usr/bin/perl

use strict;
use utf8;
use XML::Simple;
use WWW::Curl::Easy;
use DBI;
use Data::Dumper;

my $dir = '/var/spool/upnpd';
my $virtual_dir = '/upnp';

opendir(my $devdir, $dir) || die "Opendir failure: $!";
my @device_files = grep { /^([\-0-9a-f]+)\.xml/ } readdir($devdir);
closedir($devdir);

print "Status: 200 OK\r\n";
print "Content-type: text/xml; charset=utf-8\r\n";
print "\r\n";
print "<?xml version=\"1.0\" ?>\n";
print "<devices>\n";

foreach my $device_file(@device_files) {
	print '<device uuid="'.substr($device_file,0,-4).'" file="'.$virtual_dir.'/'.$device_file.'" />';
}
print "</devices>\n";
