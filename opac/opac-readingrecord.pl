#!/usr/bin/perl

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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.


use strict;
use warnings;

use CGI;

use C4::Auth;
use C4::Koha;
use C4::Biblio;
use C4::Circulation;
use C4::Members;
use Koha::DateUtils;

use C4::Output;

my $query = new CGI;
my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-readingrecord.tmpl",
        query           => $query,
        type            => "opac",
        authnotrequired => 0,
        flagsrequired   => { borrow => 1 },
        debug           => 1,
    }
);

# get borrower information ....
my ( $borr ) = GetMemberDetails( $borrowernumber );

$template->param(%{$borr});

my $itemtypes = GetItemTypes();

# get the record
my $order  = $query->param('order') || '';
if ( $order eq '' ) {
    $order = "date_due desc";
    $template->param( orderbydate => 1 );
}

if ( $order eq 'title' ) {
    $template->param( orderbytitle => 1 );
}

if ( $order eq 'author' ) {
    $template->param( orderbyauthor => 1 );
}

my $limit = $query->param('limit') || 50;
if ( $limit eq 'full' ) {
    $limit = 0;
}
else {
    $limit = 50;
}

my ( $issues ) = GetAllIssues( $borrowernumber, $order, $limit );


my @loop_reading;

foreach my $issue (@{$issues} ) {
    my %line;
	
    my $record = GetMarcBiblio($issue->{'biblionumber'});

	# XISBN Stuff
	my $isbn               = GetNormalizedISBN($issue->{'isbn'});
	$line{normalized_isbn} = $isbn;
    $line{biblionumber}    = $issue->{'biblionumber'};
    $line{title}           = $issue->{'title'};
    $line{author}          = $issue->{'author'};
    $line{itemcallnumber}  = $issue->{'itemcallnumber'};
    $line{date_due}        = $issue->{'date_due'};
    $line{returndate}      = $issue->{'returndate'};
    $line{volumeddesc}     = $issue->{'volumeddesc'};
    $issue->{'itemtype'}   = C4::Context->preference('item-level_itypes') ? $issue->{'itype'} : $issue->{'itemtype'};
    if($issue->{'itemtype'}) {
        $line{'description'}   = $itemtypes->{ $issue->{'itemtype'} }->{'description'};
        $line{imageurl}        = getitemtypeimagelocation( 'opac', $itemtypes->{ $issue->{'itemtype'}  }->{'imageurl'} );
    }
    # My Summary HTML
    if (my $my_summary_html = C4::Context->preference('OPACMySummaryHTML')){
        $line{author} ? $my_summary_html =~ s/{AUTHOR}/$line{author}/g : $my_summary_html =~ s/{AUTHOR}//g;
        $line{title} =~ s/\/+$//; # remove trailing slash
        $line{title} =~ s/\s+$//; # remove trailing space
        $line{title} ? $my_summary_html =~ s/{TITLE}/$line{title}/g : $my_summary_html =~ s/{TITLE}//g;
        $line{normalized_isbn} ? $my_summary_html =~ s/{ISBN}/$line{normalized_isbn}/g : $my_summary_html =~ s/{ISBN}//g;
        $line{biblionumber} ? $my_summary_html =~ s/{BIBLIONUMBER}/$line{biblionumber}/g : $my_summary_html =~ s/{BIBLIONUMBER}//g;
        $line{MySummaryHTML} = $my_summary_html;
    }
    push( @loop_reading, \%line );
    $line{subtitle} = GetRecordValue('subtitle', $record, GetFrameworkCode($issue->{'biblionumber'}));
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

BEGIN {
	if (C4::Context->preference('BakerTaylorEnabled')) {
		require C4::External::BakerTaylor;
		import C4::External::BakerTaylor qw(&image_url &link_url);
	}
}

for(qw(AmazonCoverImages GoogleJackets)) {	# BakerTaylorEnabled handled above
	C4::Context->preference($_) or next;
	$template->param($_=>1);
	$template->param(JacketImages=>1);
}

$template->param(
    READING_RECORD => \@loop_reading,
    limit          => $limit,
    showfulllink   => 1,
	readingrecview => 1,
	count          => scalar @loop_reading,
    OPACMySummaryHTML => (C4::Context->preference("OPACMySummaryHTML")) ? 1 : 0,
);

output_html_with_http_headers $query, $cookie, $template->output;
