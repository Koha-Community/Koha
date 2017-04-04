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

use Modern::Perl;

use C4::Auth;
use C4::Output;
use CGI qw ( -utf8 );
use C4::Members;
use C4::Accounts;
use C4::Items;
use C4::Members::Attributes qw(GetBorrowerAttributes);

use Koha::Patrons;

use Koha::Patron::Categories;

my $input=new CGI;
my $flagsrequired = { borrowers => 'edit_borrowers' };

my $borrowernumber=$input->param('borrowernumber');

my $patron = Koha::Patrons->find( $borrowernumber );
unless ( $patron ) {
    print $input->redirect("/cgi-bin/koha/circ/circulation.pl?borrowernumber=$borrowernumber");
    exit;
}

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
        flagsrequired   => { borrowers => 'edit_borrowers',
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

    if ( $patron->category->category_type eq 'C') {
        my $patron_categories = Koha::Patron::Categories->search_limited({ category_type => 'A' }, {order_by => ['categorycode']});
        $template->param( 'CATCODE_MULTI' => 1) if $patron_categories->count > 1;
        $template->param( 'catcode' => $patron_categories->next->categorycode )  if $patron_categories->count == 1;
    }

    $template->param( adultborrower => 1 ) if ( $patron->category->category_type =~ /^(A|I)$/ );
    $template->param( picture => 1 ) if $patron->image;

    if (C4::Context->preference('ExtendedPatronAttributes')) {
        my $attributes = GetBorrowerAttributes($borrowernumber);
        $template->param(
            ExtendedPatronAttributes => 1,
            extendedattributes => $attributes
        );
    }

    $template->param(%{ $patron->unblessed });
    $template->param(
        finesview      => 1,
        borrowernumber => $borrowernumber,
        categoryname   => $patron->category->description,
        is_child       => ($patron->category->category_type eq 'C'),
    );
    output_html_with_http_headers $input, $cookie, $template->output;
}
