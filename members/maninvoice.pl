#!/usr/bin/perl

#written 11/1/2000 by chris@katipo.oc.nz
#script to display borrowers account details


# Copyright 2000-2002 Katipo Communications
# Copyright 2010 BibLibre
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

use C4::Auth;
use C4::Output;
use CGI;
use C4::Members;
use C4::Accounts;
use C4::Items;
use C4::Branch;
use C4::Members::Attributes qw(GetBorrowerAttributes);

my $input=new CGI;
my $flagsrequired = { borrowers => 1 };

my $borrowernumber=$input->param('borrowernumber');


# get borrower details
my $data=GetMember('borrowernumber'=>$borrowernumber);
my $add=$input->param('add');
if ($add){
    if ( checkauth( $input, 0, $flagsrequired, 'intranet' ) ) {
        #  print $input->header;
        my $barcode=$input->param('barcode');
        my $itemnum;
        if ($barcode) {
            $itemnum = GetItemnumberFromBarcode($barcode);
        }
        my $desc=$input->param('desc');
        my $amount=$input->param('amount');
        my $type=$input->param('type');
        my $note    = $input->param('note');
        my $error   = manualinvoice( $borrowernumber, $itemnum, $desc, $type, $amount, $note );
        if ($error) {
            my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
                {   template_name   => "members/maninvoice.tt",
                    query           => $input,
                    type            => "intranet",
                    authnotrequired => 0,
                    flagsrequired   => $flagsrequired,
                    debug           => 1,
                }
            );
            if ( $error =~ /FOREIGN KEY/ && $error =~ /itemnumber/ ) {
                $template->param( 'ITEMNUMBER' => 1 );
            }
            $template->param( 'ERROR' => $error );
            output_html_with_http_headers $input, $cookie, $template->output;
        } else {
            print $input->redirect("/cgi-bin/koha/members/boraccount.pl?borrowernumber=$borrowernumber");
            exit;
        }
    }
} else {

    my ($template, $loggedinuser, $cookie) = get_template_and_user({
        template_name   => "members/maninvoice.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { borrowers => 1,
                             updatecharges => 'remaining_permissions' },
        debug           => 1,
    });
					
  # get authorised values with type of MANUAL_INV
  my @invoice_types;
  my $dbh = C4::Context->dbh;
  my $sth = $dbh->prepare('SELECT * FROM authorised_values WHERE category = "MANUAL_INV"');
  $sth->execute();
  while ( my $row = $sth->fetchrow_hashref() ) {
    push @invoice_types, $row;
  }
  $template->param( invoice_types_loop => \@invoice_types );

    if ( $data->{'category_type'} eq 'C') {
        my  ( $catcodes, $labels ) =  GetborCatFromCatType( 'A', 'WHERE category_type = ?' );
        my $cnt = scalar(@$catcodes);
        $template->param( 'CATCODE_MULTI' => 1) if $cnt > 1;
        $template->param( 'catcode' =>    $catcodes->[0])  if $cnt == 1;
    }

    $template->param( adultborrower => 1 ) if ( $data->{'category_type'} eq 'A' );
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
                finesview => 1,
                borrowernumber => $borrowernumber,
		firstname => $data->{'firstname'},
                surname  => $data->{'surname'},
        othernames => $data->{'othernames'},
		cardnumber => $data->{'cardnumber'},
		categorycode => $data->{'categorycode'},
		category_type => $data->{'category_type'},
		categoryname  => $data->{'description'},
        address => $address,
		address2 => $data->{'address2'},
		city => $data->{'city'},
		state => $data->{'state'},
		zipcode => $data->{'zipcode'},
		country => $data->{'country'},
		phone => $data->{'phone'},
        phonepro => $data->{'phonepro'},
        mobile => $data->{'mobile'},
		email => $data->{'email'},
        emailpro => $data->{'emailpro'},
		branchcode => $data->{'branchcode'},
		branchname => GetBranchName($data->{'branchcode'}),
		is_child        => ($data->{'category_type'} eq 'C'),
		activeBorrowerRelationship => (C4::Context->preference('borrowerRelationship') ne ''),
        RoutingSerials => C4::Context->preference('RoutingSerials'),
    );
    output_html_with_http_headers $input, $cookie, $template->output;
}
