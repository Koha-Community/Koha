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

use strict;
use warnings;

use CGI;

use C4::Auth;
use C4::Output;
use C4::Members;
use C4::Branch qw(GetBranches);
use List::MoreUtils qw/any uniq/;
use Koha::DateUtils;

use C4::Dates qw/format_date/;
use C4::Members::Attributes qw(GetBorrowerAttributes);

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
if ($input->param('cardnumber')) {
    $cardnumber = $input->param('cardnumber');
    $data = GetMember(cardnumber => $cardnumber);
    $borrowernumber = $data->{'borrowernumber'}; # we must define this as it is used to retrieve other data about the patron
}
if ($input->param('borrowernumber')) {
    $borrowernumber = $input->param('borrowernumber');
    $data = GetMember(borrowernumber => $borrowernumber);
}

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

my $branches = GetBranches();
foreach my $issue ( @{$issues} ) {
    $issue->{issuingbranch} = $branches->{ $issue->{branchcode} }->{branchname};
}

#   barcode export
if ( $op eq 'export_barcodes' ) {
    my $today = C4::Dates->new();
    $today = $today->output('iso');
    my @barcodes =
      map { $_->{barcode} } grep { $_->{returndate} =~ m/^$today/o } @{$issues};
    my $borrowercardnumber =
      GetMember( borrowernumber => $borrowernumber )->{'cardnumber'};
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

if ( $data->{'category_type'} eq 'C') {
    my  ( $catcodes, $labels ) =  GetborCatFromCatType( 'A', 'WHERE category_type = ?' );
    my $cnt = scalar(@$catcodes);
    $template->param( 'CATCODE_MULTI' => 1) if $cnt > 1;
    $template->param( 'catcode' =>    $catcodes->[0])  if $cnt == 1;
}

$template->param( adultborrower => 1 ) if ( $data->{'category_type'} eq 'A' );
if (! $limit){
	$limit = 'full';
}


my ($picture, $dberror) = GetPatronImage($data->{'borrowernumber'});
$template->param( picture => 1 ) if $picture;

if (C4::Context->preference('ExtendedPatronAttributes')) {
    my $attributes = GetBorrowerAttributes($borrowernumber);
    $template->param(
        ExtendedPatronAttributes => 1,
        extendedattributes => $attributes
    );
}


# Computes full borrower address
my $roadtype = C4::Koha::GetAuthorisedValueByCode( 'ROADTYPE', $data->{streettype} );
my $address = $data->{'streetnumber'} . " $roadtype " . $data->{'address'};

$template->param(
    readingrecordview => 1,
    title             => $data->{title},
    initials          => $data->{initials},
    surname           => $data->{surname},
    othernames        => $data->{othernames},
    borrowernumber    => $borrowernumber,
    firstname         => $data->{firstname},
    cardnumber        => $data->{cardnumber},
    categorycode      => $data->{categorycode},
    category_type     => $data->{category_type},
    categoryname      => $data->{description},
    address           => $address,
    address2          => $data->{address2},
    city              => $data->{city},
    state             => $data->{state},
    zipcode           => $data->{zipcode},
    country           => $data->{country},
    phone             => $data->{phone},
    phonepro          => $data->{phonepro},
    mobile            => $data->{mobile},
    email             => $data->{email},
    emailpro             => $data->{emailpro},
    branchcode        => $data->{branchcode},
    is_child          => ( $data->{category_type} eq 'C' ),
    branchname        => $branches->{ $data->{branchcode} }->{branchname},
    loop_reading      => $issues,
    activeBorrowerRelationship =>
      ( C4::Context->preference('borrowerRelationship') ne '' ),
    RoutingSerials => C4::Context->preference('RoutingSerials'),
);
output_html_with_http_headers $input, $cookie, $template->output;

