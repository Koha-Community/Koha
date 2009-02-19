#!/bin/bash

perl -I ./ -e '
use Data::Dumper;
use ILS;
use Sip::Configuration;
my $code = "MAIN";
my $conf = Sip::Configuration->new("SIPconfig.xml");
my $ils  = ILS->new($conf->{institutions}->{$code});
print "XML for $code: ", Dumper($conf->{institutions}->{$code}), "\n";
print "ILS for $code: ", Dumper($ils), "\n";
print "\$ils->checkout_ok(): ", ($ils->checkout_ok() ? "Y" : "N"), "\n";
print "\$ils->checkin_ok() : ", ($ils->checkin_ok()  ? "Y" : "N"), "\n";
print "\$ils->offline_ok() : ", ($ils->offline_ok()  ? "Y" : "N"), "\n";
print "\n";
'
