#!/bin/bash

perl -I ./ -e '
use Data::Dumper;
use C4::SIP::ILS;
use C4::SIP::Sip::Configuration;
my $code = "MAIN";
my $conf = C4::SIP::Sip::Configuration->new("SIPconfig.xml");
my $ils  = C4::SIP::ILS->new($conf->{institutions}->{$code});
print "XML for $code: ", Dumper($conf->{institutions}->{$code}), "\n";
print "ILS for $code: ", Dumper($ils), "\n";
print "\$ils->checkout_ok(): ", ($ils->checkout_ok() ? "Y" : "N"), "\n";
print "\$ils->checkin_ok() : ", ($ils->checkin_ok()  ? "Y" : "N"), "\n";
print "\$ils->offline_ok() : ", ($ils->offline_ok()  ? "Y" : "N"), "\n";
print "\n";
'
