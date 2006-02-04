package C4::Amazon;
# Copyright 2006 LibLime
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
use strict;
require Exporter;

use vars qw($VERSION @ISA @EXPORT);

$VERSION = 0.02;
=head1 NAME

C4::Amazon - Functions for retrieving Amazon.com content in Koha

=head1 FUNCTIONS

This module provides facilities for retrieving Amazon.com content in Koha

=cut

@ISA = qw(Exporter);

@EXPORT = qw(
  &get_amazon_details
);

=head1 get_amazon_details($isbn);

=head2 $isbn is a isbn string

=cut

sub get_amazon_details {
	my ( $isbn ) = @_;

	#get rid of MARC cataloger's nonsense
	$isbn =~ s/(p|-)//g;

	# grab the developer's key: mine is 'ektostoukadou-20'
	my $dev_key=C4::Context->preference('AmazonDevKey');

	#grab the associates tag: mine is '0ZRY7YASKJS280T7YB02'
	my $af_tag=C4::Context->preference('AmazonAssocTag');

	my $asin=$isbn;
	my $url = "http://xml.amazon.com/onca/xml3?t=$dev_key&dev-t=&type=heavy&f=xml&AsinSearch=" . $asin;
	my $content = get($url);
	warn "could not retrieve $url" unless $content;
	my $xmlsimple = XML::Simple->new();
	my $response = $xmlsimple->XMLin($content,
  	forcearray => [ qw(Details Product AvgCustomerRating CustomerReview) ],
);
	return $response;
}

=head1 NOTES

=head1 AUTHOR

Joshua Ferraro <jmf@liblime.com>
=cut
