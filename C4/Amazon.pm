package C4::Amazon;
# Copyright (C) 2006 LibLime
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
use LWP::UserAgent;
use HTTP::Request::Common;

use strict;

use vars qw($VERSION @ISA @EXPORT);

BEGIN {
	require Exporter;
	$VERSION = 0.03;
	@ISA = qw(Exporter);
	@EXPORT = qw(
		&get_amazon_details
		&check_search_inside
	);
}

=head1 NAME

C4::Amazon - Functions for retrieving Amazon.com content in Koha

=head1 FUNCTIONS

This module provides facilities for retrieving Amazon.com content in Koha

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
    my $url = "http://xml.amazon.com/onca/xml3?t=$af_tag&dev-t=$dev_key&type=heavy&f=xml&AsinSearch=" . $asin;
    my $content = get($url);
    #warn $content;
    warn "could not retrieve $url" unless $content;
    my $xmlsimple = XML::Simple->new();
    my $response = $xmlsimple->XMLin($content,
    forcearray => [ qw(Details Product AvgCustomerRating CustomerReview) ],
);
    return $response;
}

sub check_search_inside {
        my $isbn = shift;
        my $ua = LWP::UserAgent->new(
        agent => "Mozilla/4.76 [en] (Win98; U)",
        keep_alive => 1,
        env_proxy => 1,
        );
        my $available = 1;
        my $uri = "http://www.amazon.com/gp/reader/$isbn/ref=sib_dp_pt/002-7879865-0184864#reader-link";
        my $req = HTTP::Request->new(GET => $uri);
        $req->header (
                'Accept' => 'image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, image/png, */*',
                'Accept-Charset' => 'iso-8859-1,*,utf-8',
                'Accept-Language' => 'en-US' );
        my $res = $ua->request($req);
        my $content = $res->content();
        if ($content =~ m/This book is temporarily unavailable/) {
            undef $available;
        }
        return $available;
}

1;
__END__

=head1 NOTES

=head1 AUTHOR

Joshua Ferraro <jmf@liblime.com>

=cut
