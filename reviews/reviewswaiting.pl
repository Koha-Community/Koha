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

use CGI        qw ( -utf8 );
use C4::Auth   qw( get_template_and_user );
use C4::Output qw( pagination_bar output_html_with_http_headers );
use C4::Context;
use Koha::Biblios;
use Koha::Patrons;
use Koha::Reviews;

my $query = CGI->new;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "reviews/reviewswaiting.tt",
        query         => $query,
        type          => "intranet",
        flagsrequired => { tools => 'moderate_comments' },
    }
);

my $op           = $query->param('op')     || '';
my $status       = $query->param('status') || 0;
my $reviewid     = $query->param('reviewid');
my $page         = $query->param('page')                       || 1;
my $count        = C4::Context->preference('numSearchResults') || 20;
my $total        = Koha::Reviews->search_limited( { approved => $status } )->count;
my $biblionumber = $query->param('biblionumber');

if ( $op eq 'cud-approve' ) {
    my $review = Koha::Reviews->find($reviewid);
    $review->approve if $review;
} elsif ( $op eq 'cud-unapprove' ) {
    my $review = Koha::Reviews->find($reviewid);
    $review->unapprove if $review;
} elsif ( $op eq 'cud-delete' ) {
    my $review = Koha::Reviews->find($reviewid);
    $review->delete if $review;
}

if ( $op && $biblionumber ) {
    print scalar $query->redirect("/cgi-bin/koha/catalogue/detail.pl?biblionumber=$biblionumber&activetab=comments");
    exit;    # You can only send 1 redirect!  After that, content or other headers don't matter.
}

my $reviews = Koha::Reviews->search_limited(
    { approved => $status },
    {
        rows     => $count,
        page     => $page,
        order_by => { -desc => 'datereviewed' },
    }
)->unblessed;

for my $review (@$reviews) {
    my $biblio = Koha::Biblios->find( $review->{biblionumber} );

    # setting some borrower info into this hash
    $review->{bibliotitle} = $biblio->title;

    my $borrowernumber = $review->{borrowernumber};
    my $patron         = Koha::Patrons->find($borrowernumber);
    if ($patron) {
        $review->{patron} = $patron;
    }
}

my $url = "/cgi-bin/koha/reviews/reviewswaiting.pl?status=$status";

$template->param(
    status         => $status,
    reviews        => $reviews,
    pagination_bar =>
        pagination_bar( $url, ( int( $total / $count ) ) + ( ( $total % $count ) > 0 ? 1 : 0 ), $page, "page" )
);

output_html_with_http_headers $query, $cookie, $template->output;
