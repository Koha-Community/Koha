#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
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


=head1 NAME

opac-ISBDdetail.pl : script to show a biblio in ISBD format


=head1 DESCRIPTION

This script needs a biblionumber as parameter 

It shows the biblio

The template is in <templates_dir>/catalogue/ISBDdetail.tmpl.
this template must be divided into 11 "tabs".

The first 10 tabs present the biblio, the 11th one presents
the items attached to the biblio

=head1 FUNCTIONS

=over 2

=cut

use strict;
use C4::Auth;
use C4::Context;
use C4::Output;
use CGI;
use MARC::Record;
use C4::Biblio;
use C4::Acquisition;
use C4::Review;
use C4::Serials;    # uses getsubscriptionfrom biblionumber
use C4::Koha;
use C4::Members;    # GetMember
use C4::External::Amazon;

my $query = CGI->new();
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-ISBDdetail.tmpl",
        query           => $query,
        type            => "opac",
        authnotrequired => 1,
        debug           => 1,
    }
);

my $biblionumber = $query->param('biblionumber');
my $itemtype     = &GetFrameworkCode($biblionumber);
my $tagslib      = &GetMarcStructure( 1, $itemtype );

my $marcflavour      = C4::Context->preference("marcflavour");
my $record = GetMarcBiblio($biblionumber);

# some useful variables for enhanced content;
# in each case, we're grabbing the first value we find in
# the record and normalizing it
my $upc = GetNormalizedUPC($record,$marcflavour);
my $ean = GetNormalizedEAN($record,$marcflavour);
my $oclc = GetNormalizedOCLCNumber($record,$marcflavour);
my $isbn = GetNormalizedISBN(undef,$record,$marcflavour);
my $content_identifier_exists = 1 if ($isbn or $ean or $oclc or $upc);
$template->param(
    normalized_upc => $upc,
    normalized_ean => $ean,
    normalized_oclc => $oclc,
    normalized_isbn => $isbn,
	content_identifier_exists => $content_identifier_exists,
);

#coping with subscriptions
my $subscriptionsnumber = CountSubscriptionFromBiblionumber($biblionumber);
my $dbh = C4::Context->dbh;
my $dat                 = TransformMarcToKoha( $dbh, $record );
my @subscriptions       =
  GetSubscriptions( $dat->{title}, $dat->{issn}, $biblionumber );
my @subs;
foreach my $subscription (@subscriptions) {
    my %cell;
	my $serials_to_display;
    $cell{subscriptionid}    = $subscription->{subscriptionid};
    $cell{subscriptionnotes} = $subscription->{notes};
    $cell{branchcode}        = $subscription->{branchcode};

    #get the three latest serials.
	$serials_to_display = $subscription->{opacdisplaycount};
	$serials_to_display = C4::Context->preference('OPACSerialIssueDisplayCount') unless $serials_to_display;
	$cell{opacdisplaycount} = $serials_to_display;
    $cell{latestserials} =
      GetLatestSerials( $subscription->{subscriptionid}, $serials_to_display );
    push @subs, \%cell;
}

$template->param(
    subscriptions       => \@subs,
    subscriptionsnumber => $subscriptionsnumber,
);

my $ISBD = C4::Context->preference('ISBD');

# my @blocs = split /\@/,$ISBD;
# my @fields = $record->fields();
my $res;

# foreach my $bloc (@blocs) {
#     $bloc =~ s/\n//g;
my $bloc = $ISBD;
my $blocres;
my ($holdingbrtagf,$holdingbrtagsubf) = &GetMarcFromKohaField("items.holdingbranch",$itemtype);

foreach my $isbdfield ( split /#/, $bloc ) {

    #         $isbdfield= /(.?.?.?)/;
    $isbdfield =~ /(\d\d\d)([^\|])?\|(.*)\|(.*)\|(.*)/;
    my $fieldvalue    = $1;
    my $subfvalue = $2;
    my $textbefore    = $3;
    my $analysestring = $4;
    my $textafter     = $5;

    #         warn "==> $1 / $2 / $3 / $4";
    #         my $fieldvalue=substr($isbdfield,0,3);
    if ( $fieldvalue > 0 ) {
        my $hasputtextbefore = 0;
        my @fieldslist = $record->field($fieldvalue);
        @fieldslist = sort {$a->subfield($holdingbrtagsubf) cmp $b->subfield($holdingbrtagsubf)} @fieldslist if ($fieldvalue eq $holdingbrtagf);

        #         warn "ERROR IN ISBD DEFINITION at : $isbdfield" unless $fieldvalue;
        #             warn "FV : $fieldvalue";
        if ($subfvalue ne ""){
          foreach my $field ( @fieldslist ) {
            foreach my $subfield ($field->subfield($subfvalue)){
              warn $fieldvalue."$subfvalue";    
              my $calculated = $analysestring;
              my $tag        = $field->tag();
              if ( $tag < 10 ) {
              }
              else {
                my $subfieldvalue =
                GetAuthorisedValueDesc( $tag, $subfvalue,
                  $subfield, '', $tagslib );
                my $tagsubf = $tag . $subfvalue;
                $calculated =~
                      s/\{(.?.?.?.?)$tagsubf(.*?)\}/$1$subfieldvalue$2\{$1$tagsubf$2\}/g;
                $calculated =~s#/cgi-bin/koha/[^/]+/([^.]*.pl\?.*)$#opac-$1#g;
            
                # field builded, store the result
                if ( $calculated && !$hasputtextbefore )
                {    # put textbefore if not done
                $blocres .= $textbefore;
                $hasputtextbefore = 1;
                }
            
                # remove punctuation at start
                $calculated =~ s/^( |;|:|\.|-)*//g;
                $blocres .= $calculated;
                            
              }         
            }          
          }
          $blocres .= $textafter if $hasputtextbefore;
        } else {    
        foreach my $field ( @fieldslist ) {
          my $calculated = $analysestring;
          my $tag        = $field->tag();
          if ( $tag < 10 ) {
          }
          else {
            my @subf = $field->subfields;
            for my $i ( 0 .. $#subf ) {
            my $valuecode   = $subf[$i][1];
            my $subfieldcode  = $subf[$i][0];
            my $subfieldvalue =
            GetAuthorisedValueDesc( $tag, $subf[$i][0],
              $subf[$i][1], '', $tagslib );
            my $tagsubf = $tag . $subfieldcode;

            $calculated =~ s/                  # replace all {{}} codes by the value code.
                              \{\{$tagsubf\}\} # catch the {{actualcode}}
                            /
                              $valuecode     # replace by the value code
                           /gx;

            $calculated =~
        s/\{(.?.?.?.?)$tagsubf(.*?)\}/$1$subfieldvalue$2\{$1$tagsubf$2\}/g;
        $calculated =~s#/cgi-bin/koha/[^/]+/([^.]*.pl\?.*)$#opac-$1#g;
            }

            # field builded, store the result
            if ( $calculated && !$hasputtextbefore )
            {    # put textbefore if not done
            $blocres .= $textbefore;
            $hasputtextbefore = 1;
            }

            # remove punctuation at start
            $calculated =~ s/^( |;|:|\.|-)*//g;
            $blocres .= $calculated;
          }
        }
        $blocres .= $textafter if $hasputtextbefore;
        }       
    }
    else {
        $blocres .= $isbdfield;
    }
}
$res .= $blocres;

# }
$res =~ s/\{(.*?)\}//g;
$res =~ s/\\n/\n/g;
$res =~ s/\n/<br\/>/g;

# remove empty ()
$res =~ s/\(\)//g;

my $reviews = getreviews( $biblionumber, 1 );
foreach ( @$reviews ) {
    my $borrower_number_review = $_->{borrowernumber};
    my $borrowerData           = GetMember($borrower_number_review,'borrowernumber');
    # setting some borrower info into this hash
    $_->{title}     = $borrowerData->{'title'};
    $_->{surname}   = $borrowerData->{'surname'};
    $_->{firstname} = $borrowerData->{'firstname'};
}


$template->param(
    ISBD         => $res,
    biblionumber => $biblionumber,
    reviews             => $reviews,
);

## Amazon.com stuff
#not used unless preference set
if ( C4::Context->preference("OPACAmazonEnabled") == 1 ) {

    my $amazon_details = &get_amazon_details( $isbn, $record, $marcflavour );

    foreach my $result ( @{ $amazon_details->{Details} } ) {
        $template->param( item_description => $result->{ProductDescription} );
        $template->param( image            => $result->{ImageUrlMedium} );
        $template->param( list_price       => $result->{ListPrice} );
        $template->param( amazon_url       => $result->{url} );
    }

    my @products;
    my @reviews;
    for my $details ( @{ $amazon_details->{Details} } ) {
        next unless $details->{SimilarProducts};
        for my $product ( @{ $details->{SimilarProducts}->{Product} } ) {
            push @products, +{ Product => $product };
        }
        next unless $details->{Reviews};
        for my $product ( @{ $details->{Reviews}->{AvgCustomerRating} } ) {
            $template->param( rating => $product * 20 );
        }
        for my $reviews ( @{ $details->{Reviews}->{CustomerReview} } ) {
            push @reviews,
              +{
                Summary => $reviews->{Summary},
                Comment => $reviews->{Comment},
              };
        }
    }
    $template->param( SIMILAR_PRODUCTS => \@products );
    $template->param( AMAZONREVIEWS    => \@reviews );
}

output_html_with_http_headers $query, $cookie, $template->output;
