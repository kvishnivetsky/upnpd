#!/usr/bin/perl

use strict;
use utf8;
use XML::Simple;
use WWW::Curl::Easy;

my $buffer;
my @pairs;
my %FORM;

# Read in text
$ENV{'REQUEST_METHOD'} =~ tr/a-z/A-Z/;
if ($ENV{'REQUEST_METHOD'} eq "POST") {
	read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
}else{
	$buffer = $ENV{'QUERY_STRING'};
}
# Split information into name/value pairs
@pairs = split(/&/, $buffer);
foreach my $pair (@pairs) {
	(my $name, my $value) = split(/=/, $pair);
	$value =~ tr/+/ /;
	$value =~ s/%(..)/pack("C", hex($1))/eg;
	$FORM{$name} = $value;
}
my $DLNA_SERVER_URL = $FORM{'controlURL'};
my $DLNA_OBJ_ID = $FORM{'obj-id'};
my $DLNA_START_INDEX = $FORM{'start-index'};

my $response_body;
my $curl = WWW::Curl::Easy->new;

my $POST_DATA = '<?xml version="1.0"?>
<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
<s:Body>
<u:Browse xmlns:u="urn:schemas-upnp-org:service:ContentDirectory:1">
<ObjectID>'.$DLNA_OBJ_ID.'</ObjectID><BrowseFlag>BrowseDirectChildren</BrowseFlag>'.
'<Filter>dc:title,av:mediaClass,dc:date,@childCount,res,upnp:class,res@resolution,upnp:album,upnp:genre,upnp:albumArtURI,upnp:albumArtURI@dlna:profileID,dc:creator,res@size,res@duration,res@bitrate,res@protocolInfo</Filter>'.
#'<Filter>*</Filter>'.
#'<Filter>@ParentID</Filter>'.
'<StartingIndex>'.($DLNA_START_INDEX+0).'</StartingIndex>
<RequestedCount>20</RequestedCount>
<SortCriteria></SortCriteria>
</u:Browse>
</s:Body>
</s:Envelope>
';

my @myheaders = ("User-Agent: DLNA Browser beta", "SOAPAction: \"urn:schemas-upnp-org:service:ContentDirectory:1#Browse\"", "Content-Type: text/xml");

$curl->setopt(CURLOPT_WRITEDATA,\$response_body);
$curl->setopt(CURLOPT_URL, $DLNA_SERVER_URL);
$curl->setopt(CURLOPT_HEADER, 1);
$curl->setopt(CURLOPT_HTTPHEADER, \@myheaders);
$curl->setopt(CURLOPT_POST, 1);
$curl->setopt(CURLOPT_POSTFIELDS, $POST_DATA);
$curl->setopt(CURLOPT_POSTFIELDSIZE, length($POST_DATA));

my $response = "";
my $retcode = $curl->perform;
if ($retcode == 0) {
	my $response_code = $curl->getinfo(CURLINFO_HTTP_CODE);
	print "Status: $response_code\r\n";
	if ($response_code == 200){
		print "Content-Type: text/xml; charset=utf-8;\r\n";
		my $body = substr($response_body, index($response_body, "\r\n\r\n")+4);
		$response = $body;
	}else{
		print "Content-Type: text/plain; charset=utf-8\r\n";
		$response = $DLNA_SERVER_URL;
	}
} else {
	print "Status: 500 Internal server error\r\n";
	print "Content-Type: text/plain; charset=utf-8\r\n";
	# Error code, type of error, error message
	$response = sprintf("An error happened: $retcode ".$curl->strerror($retcode)." ".$curl->errbuf."\n");
}
print "\r\n";
print $response;

open(my $f, '>>', '/tmp/dlna.log') || die $!;
print $f "--------------- BROWSE --------------\n";
print $f $response;
print $f "--------------- BROWSE --------------\n";
close($f);
