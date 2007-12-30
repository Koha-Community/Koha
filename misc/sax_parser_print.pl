#!/usr/bin/perl
# check the current SAX Parser
use XML::SAX::ParserFactory;
$parser = XML::SAX::ParserFactory->parser();
print "$parser\n";

