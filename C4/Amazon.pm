
package C4::Amazon;
# Copyright 2004-2005 Joshua Ferraro (jmf at kados dot org)
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
#
# This module dynamically pulls amazon content into Koha.  It does not
# store the data in Koha's database.  You'll need to get a developer's key
# as well as an associate's tag to use it.
# FIXME: need to write up more docs.
#
# To use this module you need to do three things:
# 1. get a dev key and associate tag from Amazon
# 2. uncomment the Amazon stuff in opac-detail.pl
# 3. add the template variables to opac-detail.tmpl
#    here's what's available: 
#    ProductDescription
#    ImageUrlMedium
#    ListPrice
#    url
#    loop SimilarProducts (Product)
#    loop Reviews (rating, Summary)
#
use strict;
require Exporter;

use vars qw($VERSION @ISA @EXPORT);

$VERSION = 0.01;

@ISA = qw(Exporter);

@EXPORT = qw(
  &get_amazon_details
);

sub get_amazon_details {

my ( $isbn ) = @_;

# insert your dev key here
my $dev_key='';

# insert your associates tag here
my $af_tag='';

my $asin=$isbn;

# old way from command line: shift @ARGV or die "Usage:perl amazon_http.ol <asin>\n";

#my $url = "http://xml.amazon.com/onca/xml3?t=" . $af_tag .
#	"&dev-t=" . $dev_key .
#	"&type=heavy&f=xml&" .
#	"AsinSearch=" . $asin;
my $url = "http://xml.amazon.com/onca/xml3?t=$dev_key&dev-t=$af_tag&type=heavy&f=xml&AsinSearch=" . $asin;

#Here's an example asin for the book "Cryptonomicon"
#0596005423";

use XML::Simple;
use LWP::Simple;
my $content = get($url);
die "could not regrieve $url" unless $content;

my $xmlsimple = XML::Simple->new();
my $response = $xmlsimple->XMLin($content,
  forcearray => [ qw(Details Product AvgCustomerRating CustomerReview) ],
);
return $response;
#foreach my $result (@{$response->{Details}}){
#	my $product_description = $result->{ProductDescription};
#	my $image = $result->{ImageUrlMedium};
#	my $price = $result->{ListPrice};
#	my $reviews = $result->{
#	return $result;
#}
}
