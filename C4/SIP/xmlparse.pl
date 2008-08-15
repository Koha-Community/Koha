#!/usr/bin/perl
#
# This file reads a SIPServer xml-format configuration file and dumps it
# to stdout.  Just to see what the structures look like.
#
# The 'new XML::Simple' option must agree exactly with the configuration
# in Sip::Configuration.pm
#
use strict;
use English;

use XML::Simple qw(:strict);
use Data::Dumper;

my $parser = new XML::Simple( KeyAttr   => { login => '+id',
					     institution => '+id',
					     service => '+port', },
			      GroupTags =>  { listeners => 'service',
					      accounts => 'login',
					      institutions => 'institution', },
			      ForceArray=> [ 'service',
					     'login',
					     'institution' ],
			      ValueAttr =>  { 'error-detect' => 'enabled',
					     'min_servers' => 'value',
					     'max_servers' => 'value'} );

my $ref = $parser->XMLin(@ARGV ? shift : 'SIPconfig.xml');

print Dumper($ref); 
