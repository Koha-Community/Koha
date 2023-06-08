#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.


use Modern::Perl;

use CGI qw ( -utf8 );

use C4::Auth qw( get_template_and_user );
use C4::Koha qw(
    getitemtypeimagelocation
    GetNormalizedISBN
    GetNormalizedUPC
);
use C4::Biblio;
use C4::Members qw( GetAllIssues );
use C4::External::BakerTaylor qw( image_url link_url );
use MARC::Record;

use C4::Output qw( output_html_with_http_headers );
use C4::Charset qw( StripNonXmlChars );
use Koha::Patrons;

use Koha::ItemTypes;
use Koha::Ratings;

my $query = CGI->new;

# if opacreadinghistory is disabled, leave immediately
if ( ! C4::Context->preference('opacreadinghistory') ) {
    print $query->redirect("/cgi-bin/koha/errors/404.pl");
    exit;
}

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-readingrecord.tt",
        query           => $query,
        type            => "opac",
    }
);

my $itemtypes = { map { $_->{itemtype} => $_ } @{ Koha::ItemTypes->search_with_localization->unblessed } };

# get the record
my $order = $query->param('order') || '';
if ( $order eq 'title' ) {
    $template->param( orderbytitle => 1 );
}
elsif ( $order eq 'author' ) {
    $template->param( orderbyauthor => 1 );
}
else {
    $order = "date_due desc";
    $template->param( orderbydate => 1 );
}


my $limit = $query->param('limit');
$limit //= '';
$limit = ( $limit eq 'full' ) ? 0 : 50;

my $issues = GetAllIssues( $borrowernumber, $order, $limit );

my $itype_attribute =
  ( C4::Context->preference('item-level_itypes') ) ? 'itype' : 'itemtype';

my $opac_summary_html = C4::Context->preference('OPACMySummaryHTML');
foreach my $issue ( @{$issues} ) {
    $issue->{normalized_isbn} = GetNormalizedISBN( $issue->{isbn} );
    if ( $issue->{$itype_attribute} ) {
        $issue->{translated_description} =
          $itemtypes->{ $issue->{$itype_attribute} }->{translated_description};
        $issue->{imageurl} =
          getitemtypeimagelocation( 'opac',
            $itemtypes->{ $issue->{$itype_attribute} }->{imageurl} );
    }

    if (   C4::Context->preference('BakerTaylorEnabled')
        || C4::Context->preference('SyndeticsEnabled')
        || C4::Context->preference('SyndeticsCoverImages') )
    {
        my $marcxml = C4::Biblio::GetXmlBiblio( $issue->{biblionumber} );
        if ( $marcxml ) {
            $marcxml = StripNonXmlChars( $marcxml );
            my $marc_rec =
              MARC::Record::new_from_xml( $marcxml, 'UTF-8',
                C4::Context->preference('marcflavour') );
            $issue->{normalized_upc} = GetNormalizedUPC( $marc_rec, C4::Context->preference('marcflavour') );
        }
    }
    # My Summary HTML
    if ($opac_summary_html) {
        my $my_summary_html = $opac_summary_html;
        $issue->{author}
          ? $my_summary_html =~ s/{AUTHOR}/$issue->{author}/g
          : $my_summary_html =~ s/{AUTHOR}//g;
        my $title = $issue->{title};
        $title =~ s/\/+$//;    # remove trailing slash
        $title =~ s/\s+$//;    # remove trailing space
        $title
          ? $my_summary_html =~ s/{TITLE}/$title/g
          : $my_summary_html =~ s/{TITLE}//g;
        $issue->{normalized_isbn}
          ? $my_summary_html =~ s/{ISBN}/$issue->{normalized_isbn}/g
          : $my_summary_html =~ s/{ISBN}//g;
        $issue->{biblionumber}
          ? $my_summary_html =~ s/{BIBLIONUMBER}/$issue->{biblionumber}/g
          : $my_summary_html =~ s/{BIBLIONUMBER}//g;
        $issue->{MySummaryHTML} = $my_summary_html;
    }
    # Star ratings
    if ( C4::Context->preference('OpacStarRatings') eq 'all' ) {
        my $ratings = Koha::Ratings->search({ biblionumber => $issue->{biblionumber} });
        $issue->{ratings} = $ratings;
        $issue->{my_rating} = $borrowernumber ? $ratings->search({ borrowernumber => $borrowernumber })->next : undef;
    }
}

if (C4::Context->preference('BakerTaylorEnabled')) {
	$template->param(
		JacketImages=>1,
		BakerTaylorEnabled  => 1,
		BakerTaylorImageURL => &image_url(),
		BakerTaylorLinkURL  => &link_url(),
		BakerTaylorBookstoreURL => C4::Context->preference('BakerTaylorBookstoreURL'),
	);
}

for(qw(AmazonCoverImages GoogleJackets)) { # BakerTaylorEnabled handled above
	C4::Context->preference($_) or next;
	$template->param($_=>1);
	$template->param(JacketImages=>1);
}

$template->param(
    READING_RECORD => $issues,
    limit          => $limit,
    readingrecview => 1,
    OPACMySummaryHTML => $opac_summary_html ? 1 : 0,
);

output_html_with_http_headers $query, $cookie, $template->output, undef, { force_no_caching => 1 };
