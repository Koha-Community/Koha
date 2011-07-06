#!/usr/bin/perl

use strict;
use warnings;

use XML::SAX;
use Encode;

my $parser = XML::SAX::ParserFactory->parser(
Handler => MySAXHandler->new
);
binmode STDOUT, ':encoding(UTF-8)';
print "\x{65}\x{301}\n";
$parser->parse_string(encode_utf8("<xml>\x{65}\x{301}</xml>"));
$parser->parse_string("<xml>\xEF\xBB\xBF\x{65}\x{301}</xml>");

package MySAXHandler;

use base qw(XML::SAX::Base);
sub start_document {
 my ($self, $doc) = @_;
 # process document start event
}

sub start_element {
 my ($self, $el) = @_;
 # process element start event
}
