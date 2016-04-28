#!/usr/bin/perl

use strict;
use utf8;
use XML::Simple;
use WWW::Curl::Easy;
use Data::Dumper;

my $request;
read(STDIN, $request, $ENV{'CONTENT_LENGTH'});

my $firstHeader = 1;
my %headers;
my $response_body;

my $curl = new WWW::Curl::Easy;
$curl->setopt(CURLOPT_URL, $request);
$curl->setopt(CURLOPT_CUSTOMREQUEST, 'GET');
$curl->setopt(CURLOPT_USERAGENT, "Mozilla/5.0 (X11; U; Linux i686; ru; rv:1.9.2.23) Gecko/20110929 SUSE/3.6.23-0.3.1");
$curl->setopt(CURLOPT_WRITEDATA, \$response_body);
$curl->setopt(CURLOPT_HEADERFUNCTION, \&http_headers);
$curl->setopt(CURLOPT_WRITEFUNCTION, \&writeCallback );
my $retcode = $curl->perform;
undef $curl;
exit 0;

sub http_headers {
    my($data, $pointer) = @_;
    if ($firstHeader) {
	my($proto, $code, $desc) = split / /, $data;
	print "Status: $code $desc";
	$firstHeader = 0;
    } else {
	printf "%s", $data;
    }
    return length($data);
};

sub writeCallback {
    my ($data, $pointer) = @_;
    printf "%s", $data;
    return length($data);
};
