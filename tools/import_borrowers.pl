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
use C4::Dates qw(format_date_in_iso);
use C4::Context;
use C4::Members;
use C4::Members::Attributes;
use C4::Members::AttributeTypes;

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
if (C4::Context->preference('ExtendedPatronAttributes')) {
    push @columnkeys, 'patron_attributes';
}

my $input = new CGI;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "tools/import_borrowers.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { tools => 'import_patrons' },
        debug           => 1,
    }
);

my $uploadborrowers      = $input->param('uploadborrowers');
my $matchpoint           = $input->param('matchpoint');
if ($matchpoint) {
    $matchpoint =~ s/^patron_attribute_//;
}
my $overwrite_cardnumber = $input->param('overwrite_cardnumber');

$template->param( SCRIPT_NAME => $ENV{'SCRIPT_NAME'} );

if (C4::Context->preference('ExtendedPatronAttributes')) {
    $template->param(ExtendedPatronAttributes => 1);
}

if ( $uploadborrowers && length($uploadborrowers) > 0 ) {
    my $csv         = Text::CSV->new();
    my $imported    = 0;
    my $alreadyindb = 0;
    my $overwritten = 0;
    my $invalid     = 0;
    my $matchpoint_attr_type; 

    if (C4::Context->preference('ExtendedPatronAttributes')) {
        $matchpoint_attr_type = C4::Members::AttributeTypes->fetch($matchpoint);
    }

    while ( my $borrowerline = <$uploadborrowers> ) {
        my $status  = $csv->parse($borrowerline);
        my @columns = $csv->fields();
        my %borrower;
        my $patron_attributes;
        if ( @columns == @columnkeys ) {
            @borrower{@columnkeys} = @columns;
            my @attrs;
            if (C4::Context->preference('ExtendedPatronAttributes')) {
                my $attr_str = $borrower{patron_attributes};
                delete $borrower{patron_attributes};
                my $ok = $csv->parse($attr_str);
                my @list = $csv->fields();
                # FIXME error handling
                $patron_attributes = [ map { map { my @arr = split /:/, $_, 2; { code => $arr[0], value => $arr[1] } } $_ } @list ];
            }
			foreach (qw(dateofbirth dateenrolled dateexpiry)) {
				my $tempdate = $borrower{$_} or next;
				$borrower{$_} = format_date_in_iso($tempdate) || '';
			}
            my $borrowernumber;
            if ($matchpoint eq 'cardnumber') {
                my $member = GetMember( $borrower{'cardnumber'}, 'cardnumber' );
                if ($member) {
                    $borrowernumber = $member->{'borrowernumber'};
                }
            } elsif (C4::Context->preference('ExtendedPatronAttributes')) {
                if (defined($matchpoint_attr_type)) {
                    foreach my $attr (@$patron_attributes) {
                        if ($attr->{code} eq $matchpoint and $attr->{value} ne '') {
                            my @borrowernumbers = $matchpoint_attr_type->get_patrons($attr->{value});
                            $borrowernumber = $borrowernumbers[0] if scalar(@borrowernumbers) == 1;
                            last;
                        }
                    }
                }
            }
            
            if ( $borrowernumber) 
            {
                # borrower exists
                if ($overwrite_cardnumber) {
                    $borrower{'borrowernumber'} = $borrowernumber;
                    ModMember(%borrower);
                    if (C4::Context->preference('ExtendedPatronAttributes')) {
                        C4::Members::Attributes::SetBorrowerAttributes($borrower{'borrowernumber'}, $patron_attributes);
                    }
                    $overwritten++;
                } else {
                    $alreadyindb++;
                }
            }
            else {
                if ($borrowernumber = AddMember(%borrower)) {
                    if (C4::Context->preference('ExtendedPatronAttributes')) {
                        C4::Members::Attributes::SetBorrowerAttributes($borrowernumber, $patron_attributes);
                    }
                    $imported++;
                } else {
                    $invalid++;		# was just "$invalid", I assume incrementing was the point --atz
                }
            }
        } else {
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

} else {
    if (C4::Context->preference('ExtendedPatronAttributes')) {
        my @matchpoints = ();
        my @attr_types = C4::Members::AttributeTypes::GetAttributeTypes();
        foreach my $type (@attr_types) {
            my $attr_type = C4::Members::AttributeTypes->fetch($type->{code});
            if ($attr_type->unique_id()) {
            push @matchpoints, { code =>  "patron_attribute_" . $attr_type->code(), description => $attr_type->description() };
            }
        }
        $template->param(matchpoints => \@matchpoints);
    }
}

output_html_with_http_headers $input, $cookie, $template->output;

