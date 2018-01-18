#!/usr/bin/perl

# written 27/01/2000
# script to display borrowers reading record

# Copyright 2000-2002 Katipo Communications
#
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
use C4::Members;
use List::MoreUtils qw/any uniq/;
use Koha::DateUtils;
use C4::Members::Attributes qw(GetBorrowerAttributes);

use Koha::Patrons;
use Koha::Patron::Categories;

my $input = CGI->new;

#get borrower details
my $data = undef;
my $borrowernumber = undef;
my $cardnumber = undef;

my ($template, $loggedinuser, $cookie)= get_template_and_user({template_name => "members/readingrec.tt",
				query => $input,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {borrowers => 1},
				debug => 1,
				});

my $op = $input->param('op') || '';
my $patron;
if ($input->param('cardnumber')) {
    $cardnumber = $input->param('cardnumber');
    $patron = Koha::Patrons->find( { cardnumber => $cardnumber } );
}
if ($input->param('borrowernumber')) {
    $borrowernumber = $input->param('borrowernumber');
    $patron = Koha::Patrons->find( $borrowernumber );
}

unless ( $patron ) {
    print $input->redirect("/cgi-bin/koha/circ/circulation.pl?borrowernumber=$borrowernumber");
    exit;
}
$data = $patron->unblessed;
$borrowernumber = $patron->borrowernumber;

my $order = 'date_due desc';
my $limit = 0;
my $issues = ();
# Do not request the old issues of anonymous patron
if ( $borrowernumber eq C4::Context->preference('AnonymousPatron') ){
    # use of 'eq' in the above comparison is intentional -- the
    # system preference value could be blank
    $template->param( is_anonymous => 1 );
} else {
    $issues = GetAllIssues($borrowernumber,$order,$limit);
}

#   barcode export
if ( $op eq 'export_barcodes' ) {
    if ( $data->{'privacy'} < 2) {
        my $today = output_pref({ dt => dt_from_string, dateformat => 'iso', dateonly => 1 });
        my @barcodes =
          map { $_->{barcode} } grep { $_->{returndate} =~ m/^$today/o } @{$issues};
        my $borrowercardnumber = $data->{cardnumber};
        my $delimiter = "\n";
        binmode( STDOUT, ":encoding(UTF-8)" );
        print $input->header(
            -type       => 'application/octet-stream',
            -charset    => 'utf-8',
            -attachment => "$today-$borrowercardnumber-checkinexport.txt"
        );

        my $content = join $delimiter, uniq(@barcodes);
        print $content;
        exit;
    }
}

if ( $data->{'category_type'} eq 'C') {
    my $patron_categories = Koha::Patron::Categories->search_limited({ category_type => 'A' }, {order_by => ['categorycode']});
    $template->param( 'CATCODE_MULTI' => 1) if $patron_categories->count > 1;
    $template->param( 'catcode' => $patron_categories->next->categorycode )  if $patron_categories->count == 1;
}

$template->param( adultborrower => 1 ) if ( $data->{'category_type'} eq 'A' || $data->{'category_type'} eq 'I' );
if (! $limit){
	$limit = 'full';
}

$template->param( picture => 1 ) if $patron->image;

if (C4::Context->preference('ExtendedPatronAttributes')) {
    my $attributes = GetBorrowerAttributes($borrowernumber);
    $template->param(
        ExtendedPatronAttributes => 1,
        extendedattributes => $attributes
    );
}

$template->param(%$data);

$template->param(
    readingrecordview => 1,
    borrowernumber    => $borrowernumber,
    privacy           => $data->{'privacy'},
    categoryname      => $data->{description},
    is_child          => ( $data->{category_type} eq 'C' ),
    loop_reading      => $issues,
);
output_html_with_http_headers $input, $cookie, $template->output;

