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
use C4::Auth;
use C4::Output;
use C4::Context;
use C4::Review;
use C4::Members;
use C4::Biblio;
use Koha::Reviews;

my $query = new CGI;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "reviews/reviewswaiting.tt",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { tools => 'moderate_comments' },
        debug           => 1,
    }
);

my $op       = $query->param('op') || '';
my $status   = $query->param('status') || 0;
my $reviewid = $query->param('reviewid');
my $page     = $query->param('page') || 1;
my $count    = C4::Context->preference('numSearchResults') || 20;
my $total    = numberofreviews($status);

if ( $op eq 'approve' ) {
    my $review = Koha::Reviews->find( $reviewid );
    $review->approve if $review;
}
elsif ( $op eq 'unapprove' ) {
    my $review = Koha::Reviews->find( $reviewid );
    $review->unapprove if $review;
}
elsif ( $op eq 'delete' ) {
    deletereview($reviewid);
}

my $reviews = Koha::Reviews->search(
    { approved => $status },
    {
        rows => $count,
        page => $page,
        order_by => { -desc => 'datereviewed' },
    }
)->unblessed;

foreach ( @$reviews ) {
    my $borrowernumber = $_->{borrowernumber};
    my $borrowerData   = GetMember('borrowernumber' => $borrowernumber);
    my $biblioData     = GetBiblioData($_->{biblionumber});
    # setting some borrower info into this hash
    $_->{bibliotitle} = $biblioData->{'title'};
    $_->{surname}     = $borrowerData->{'surname'};
    $_->{firstname}   = $borrowerData->{'firstname'};
}

my $url = "/cgi-bin/koha/reviews/reviewswaiting.pl?status=$status";

$template->param(
    status => $status,
    reviews => $reviews,
    pagination_bar => pagination_bar( $url, ( int( $total / $count ) ) + ( ( $total % $count ) > 0 ? 1 : 0 ), $page, "page" )
);

output_html_with_http_headers $query, $cookie, $template->output;
