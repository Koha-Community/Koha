package C4::External::Amazon;
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
use C4::Koha;
use URI::Escape;
use POSIX;
use Digest::SHA qw(hmac_sha256_base64);

use strict;
use warnings;

use vars qw($VERSION @ISA @EXPORT);

BEGIN {
    require Exporter;
    $VERSION = 0.03;
    @ISA = qw(Exporter);
    @EXPORT = qw(
        get_amazon_details
        get_amazon_tld
    );
}


sub get_amazon_tld {
    my %tld = (
        CA => '.ca',
        DE => '.de',
        FR => '.fr',
        JP => '.jp',
        UK => '.co.uk',
        US => '.com',
    );

    my $locale = C4::Context->preference('AmazonLocale');
    my $tld = $tld{ $locale } || '.com'; # default top level domain is .com
    return $tld;
}


=head1 NAME

C4::External::Amazon - Functions for retrieving Amazon.com content in Koha

=head2 FUNCTIONS

This module provides facilities for retrieving Amazon.com content in Koha

=over

=item get_amazon_detail( $isbn, $record, $marcflavour, $services )

Get editorial reviews, customer reviews, and similar products using Amazon Web Services.

Parameters:

=over

=item $isbn

Biblio record isbn

=item $record

Biblio MARC record

=item $marcflavour

MARC flavor, MARC21 or UNIMARC

=item $services

Requested Amazon services: A ref to an array. For example,
[ 'Similarities', 'EditorialReviews', 'Reviews' ].
No other service will be accepted. Services must be spelled exactly.
If no sercice is requested, AWS isn't called.

=back

=item get_amazon_tld()

Get Amazon Top Level Domain depending on Amazon local preference: AmazonLocal.
For example, if AmazonLocal is 'UK', returns '.co.uk'.

=back

=cut


sub get_amazon_details {
    my ( $isbn, $record, $marcflavour, $aws_ref ) = @_;

    return unless defined $aws_ref;
    my @aws = @$aws_ref;
    return if $#aws == -1;

    # Normalize the fields
    $isbn = GetNormalizedISBN($isbn);
    my $upc = GetNormalizedUPC($record,$marcflavour);
    my $ean = GetNormalizedEAN($record,$marcflavour);
    # warn "ISBN: $isbn | UPC: $upc | EAN: $ean";

    # Choose the appropriate and available item identifier
    my ( $id_type, $item_id ) =
        defined($isbn) && length($isbn) == 13 ? ( 'EAN',  $isbn ) :
        $isbn                                 ? ( 'ASIN', $isbn ) :
        $upc                                  ? ( 'UPC',  $upc  ) :
        $ean                                  ? ( 'EAN',  $upc  ) : ( undef, undef );
    return unless defined($id_type);

    # grab the item format to determine Amazon search index
    my %hformat = ( a => 'Books', g => 'Video', j => 'Music' );
    my $search_index = $hformat{ substr($record->leader(),6,1) } || 'Books';

    my $parameters={Service=>"AWSECommerceService" ,
        "AWSAccessKeyId"=> C4::Context->preference('AWSAccessKeyID') ,
        "Operation"=>"ItemLookup", 
        "AssociateTag"=>  C4::Context->preference('AmazonAssocTag') ,
        "Version"=>"2009-06-01",
        "ItemId"=>$item_id,
        "IdType"=>$id_type,
        "ResponseGroup"=>  join( ',',  @aws ),
        "Timestamp"=>strftime("%Y-%m-%dT%H:%M:%SZ", gmtime)
    };
    $$parameters{"SearchIndex"} = $search_index if $id_type ne 'ASIN';
    my @params;
    while (my ($key,$value)=each %$parameters){
        push @params, qq{$key=}.uri_escape($value, "^A-Za-z0-9\-_.~" );
    }

    my $url =qq{http://webservices.amazon}.  get_amazon_tld(). 
        "/onca/xml?".join("&",sort @params).qq{&Signature=}.uri_escape(SignRequest(@params),"^A-Za-z0-9\-_.~" );

    my $content = get($url);
    warn "could not retrieve $url" unless $content;
    my $xmlsimple = XML::Simple->new();
    my $response = $xmlsimple->XMLin(
        $content,
        forcearray => [ qw(SimilarProduct EditorialReview Review Item) ],
    ) unless !$content;
    return $response;
}

sub SignRequest{
    my @params=@_;
    my $tld=get_amazon_tld(); 
    my $string = qq{GET\nwebservices.amazon$tld\n/onca/xml\n} . join("&",sort @params);
    return hmac_sha256_base64($string,C4::Context->preference('AWSPrivateKey')) . '=';
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
