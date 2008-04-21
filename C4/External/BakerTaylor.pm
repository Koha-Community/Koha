package C4::External::BakerTaylor;
# Copyright (C) 2008 LibLime
# <jmf at liblime dot com>
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use XML::Simple;
use LWP::Simple;
# use LWP::UserAgent;
use HTTP::Request::Common;
use C4::Context;
use C4::Debug;

use strict;
use warnings;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
use vars qw($user $pass $agent $image_url $link_url);

BEGIN {
	require Exporter;
	$VERSION = 0.01;
	@ISA = qw(Exporter);
	@EXPORT_OK = qw(&availability &content_cafe &image_url &link_url &http_jacket_link);
	%EXPORT_TAGS = (all=>\@EXPORT_OK);
}
INIT {
	&initialize;
}

sub initialize {
	$user     = (@_ ? shift : C4::Context->preference('BakerTaylorUsername')    ) || ''; # LL17984
	$pass     = (@_ ? shift : C4::Context->preference('BakerTaylorPassword')    ) || ''; # CC82349
	$link_url = (@_ ? shift : C4::Context->preference('BakerTaylorBookstoreURL'));
	# https://ocls.mylibrarybookstore.com/MLB/actions/searchHandler.do?nextPage=bookDetails&parentNum=10923&key=
	$image_url = "http://contentcafe2.btol.com/buynow/Jacket.aspx?UserID=$user&Password=$pass&Product=";
	$agent = "Koha/$VERSION [en] (Linux)";
			#"Mozilla/4.76 [en] (Win98; U)",	#  if for some reason you want to go stealth, you might prefer this
}

sub image_url (;$) {
	($user and $pass) or return undef;
	my $isbn = (@_ ? shift : '');
	$isbn =~ s/(p|-)//g;	# sanitize
	return $image_url . $isbn;
}
sub link_url (;$) {
	my $isbn = (@_ ? shift : '');
	$isbn =~ s/(p|-)//g;	# sanitize
	$link_url or return undef;
	return $link_url . $isbn;
}
sub content_cafe_url ($) {
	($user and $pass) or return undef;
	my $isbn = (@_ ? shift : '');
	$isbn =~ s/(p|-)//g;	# sanitize
	return "http://contentcafe2.btol.com/ContentCafeClient/ContentCafe.aspx?UserID=$user&Password=$pass&Options=Y&ItemKey=$isbn";
}
sub http_jacket_link ($) {
	my $isbn = shift or return undef;
	$isbn =~ s/(p|-)//g;	# sanitize
	my $image = availability($isbn);
	my $alt = "Buy this book";
	$image and $image = qq(<img class="btjacket" alt="$alt" src="$image" />);
	my $link = &link_url($isbn);
	unless ($link) {return $image || '';}
	return sprintf qq(<a class="btlink" href="%s">%s</a>),$link,($image||$alt);
}

sub availability ($) {
	my $isbn = shift or return undef;
	($user and $pass) or return undef;
	$isbn =~ s/(p|-)//g;	# sanitize
	my $url = "http://contentcafe2.btol.com/ContentCafe/InventoryAvailability.asmx/CheckInventory?UserID=$user&Password=$pass&Value=$isbn";
	$debug and warn __PACKAGE__ . " request:\n$url\n";
	my $content = get($url);
	$debug and print STDERR $content, "\n";
	warn "could not retrieve $url" unless $content;
	my $xmlsimple = XML::Simple->new();
	my $result = $xmlsimple->XMLin($content);
	if ($result->{Error}) {
		warn "Error returned to " . __PACKAGE__ . " : " . $result->{Error};
	}
	my $avail = $result->{Availability};
	return ($avail and $avail !~ /^false$/i) ? &image_url($isbn) : 0;
}

1;

__END__

=head1 NAME

C4::External::BakerTaylor - Functions for retrieving content from Baker and Taylor, inventory availability and "Content Cafe".
The settings for this module are controlled by System Preferences:

These can be overridden for testing purposes using the initialize function.

=head1 FUNCTIONS

=head1 availability($isbn);

=head2 $isbn is a isbn string

=head1 NOTES

A request with failed authentication might see this back from Baker + Taylor: 

<?xml version="1.0" encoding="utf-8"?>
<InventoryAvailability xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" DateTime="2008-03-07T22:01:25.6520429-05:00" xmlns="http://ContentCafe2.btol.com">
  <Key Type="Undefined">string</Key>
  <Availability>false</Availability>
  <Error>Invalid UserID</Error>
</InventoryAvailability>

Such response will trigger a warning for each request (potentially many).  Point being, do not leave this module configured with incorrect username and password in production.

=head1 SEE ALSO

C4::Amazon
LWP::UserAgent

=head1 AUTHOR

Joe Atzberger
atz AT liblime DOT com

=cut
