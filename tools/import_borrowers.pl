#!/usr/bin/perl

# Copyright 2007 Liblime Ltd
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

# Script to take some borrowers data in a known format and load it into Koha
#
# File format
#
# cardnumber,surname,firstname,title,othernames,initials,streetnumber,streettype,
# address line , address line 2, city, zipcode, email, phone, mobile, fax, work email, work phone,
# alternate streetnumber, alternate streettype, alternate address line 1, alternate city,
# alternate zipcode, alternate email, alternate phone, date of birth, branchcode,
# categorycode, enrollment date, expiry date, noaddress, lost, debarred, contact surname,
# contact firstname, contact title, borrower notes, contact relationship, ethnicity, ethnicity notes
# gender, username, opac note, contact note, password, sort one, sort two
#
# any fields except cardnumber can be blank but the number of fields must match
# dates should be in the format you have set up Koha to expect
# branchcode and categorycode need to be valid

use strict;
use C4::Auth;
use C4::Output;
use C4::Date;
use C4::Context;
use C4::Members;

use Text::CSV;
use CGI;

my @columnkeys = (
    'cardnumber',    'surname',      'firstname',        'title',
    'othernames',    'initials',     'streetnumber',     'streettype',
    'address',       'address2',     'city',             'zipcode',
    'email',         'phone',        'mobile',           'fax',
    'emailpro',      'phonepro',     'B_streetnumber',   'B_streettype',
    'B_address',     'B_city',       'B_zipcode',        'B_email',
    'B_phone',       'dateofbirth',  'branchcode',       'categorycode',
    'dateenrolled',  'dateexpiry',   'gonenoaddress',    'lost',
    'debarred',      'contactname',  'contactfirstname', 'contacttitle',
    'borrowernotes', 'relationship', 'ethnicity',        'ethnotes',
    'sex',           'userid',       'opacnote',         'contactnote',
    'password',      'sort1',        'sort2'
);

my $input = new CGI;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "tools/import_borrowers.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { tools => 1 },
        debug           => 1,
    }
);

my $uploadborrowers      = $input->param('uploadborrowers');
my $overwrite_cardnumber = $input->param('overwrite_cardnumber');

$template->param( SCRIPT_NAME => $ENV{'SCRIPT_NAME'} );

if ( $uploadborrowers && length($uploadborrowers) > 0 ) {
    my $csv         = Text::CSV->new();
    my $imported    = 0;
    my $alreadyindb = 0;
    my $overwritten = 0;
    my $invalid     = 0;
    while ( my $borrowerline = <$uploadborrowers> ) {

        my $status  = $csv->parse($borrowerline);
        my @columns = $csv->fields();
        my %borrower;
        if ( @columns == @columnkeys ) {

            @borrower{@columnkeys} = @columns;
            if ( my $member =
                GetMember( $borrower{'cardnumber'}, 'cardnumber' ) )
            {

                # borrower exists
                if ($overwrite_cardnumber) {
                    $borrower{'borrowernumber'} = $member->{'borrowernumber'};
                    ModMember(%borrower);
                    $overwritten++;
                }
                else {
                    $alreadyindb++;
                }
            }
            else {
                my $borrowernumber = AddMember(%borrower);
                if ($borrowernumber) {
                    $imported++;
                }
                else {
                    $invalid;
                }
            }
        }
        else {
            $invalid++;
        }
    }
    $template->param( 'uploadborrowers' => 1 );
    $template->param(
        'uploadborrowers' => 1,
        'imported'        => $imported,
        'overwritten'     => $overwritten,
        'alreadyindb'     => $alreadyindb,
        'invalid'         => $invalid,
        'total'           => $imported + $alreadyindb + $invalid + $overwritten,
    );

}
output_html_with_http_headers $input, $cookie, $template->output;

