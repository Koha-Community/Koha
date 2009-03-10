#!/usr/bin/perl
# check the current SAX Parser

use strict;
use warnings;
use XML::SAX::ParserFactory;

my $parser = XML::SAX::ParserFactory->parser();
print "Koha wants something like:
    XML::LibXML::SAX::Parser=HASH(0x81fe220)
You have:
    $parser\n";
print "Looks " .
    ($parser =~ /^XML::LibXML::SAX::Parser=HASH/ ?
    "good.\n" : "bad, check INSTALL.* documentation.\n");
