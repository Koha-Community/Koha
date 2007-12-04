#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
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

use strict;
require Exporter;
use CGI;
use Mail::Sendmail;

use C4::Auth;    # checkauth, getborrowernumber.
use C4::Context;
use C4::Koha;
use C4::Circulation;
use C4::Output;
use C4::Dates;
use C4::Members;

my $query = new CGI;

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-userupdate.tmpl",
        query           => $query,
        type            => "opac",
        authnotrequired => 0,
        flagsrequired   => { borrow => 1 },
        debug           => 1,
    }
);

# get borrower information ....
my ( $borr, $flags ) = GetMemberDetails( $borrowernumber );

# handle the new information....
# collect the form values and send an email.
my @fields = (
    'title',     'surname',       'firstname',    'phone',
    'fax', 'streetaddress', 'emailaddress', 'city','phonepro',
);
my $update;
my $updateemailaddress = C4::Context->preference('KohaAdminEmailAddress');
if ( $updateemailaddress eq '' ) {
    warn
"KohaAdminEmailAddress system preference not set.  Couldn't send patron update information for $borr->{'firstname'} $borr->{'surname'} (#$borrowernumber)\n";
    my ($template) = get_template_and_user(
        {
            template_name   => "kohaerror.tmpl",
            query           => $query,
            type            => "opac",
            authnotrequired => 1,
            flagsrequired   => { borrow => 1 },
            debug           => 1,
        }
    );

    $template->param(
        errormessage => 'KohaAdminEmailAddress system preference
    is not set.  Please visit the library to update your user record'
    );

    output_html_with_http_headers $query, $cookie, $template->output;
    exit;
}

if ( $query->{'title'} ) {

    # get all the fields:
    my $message = <<"EOF";
Borrower $borr->{'cardnumber'}

has requested to change her/his personal details.
Please check these new details and make the changes:
EOF
    foreach my $field (@fields) {
        my $newfield = $query->param($field);
        $message .= "$field : $borr->{$field}  -->  $newfield\n";
    }
    $message .= "\n\nThanks,\nKoha\n\n";
    my %mail = (
        To      => $updateemailaddress,
        From    => $updateemailaddress,
        Subject => "User Request for update of Record.",
        Message => $message
    );

    if ( sendmail %mail ) {

        # do something if it works....
        warn "Mail sent ok\n";
        print $query->redirect('/cgi-bin/koha/opac-user.pl');
        exit;
    }
    else {

        # do something if it doesnt work....
        warn "Error sending mail: $Mail::Sendmail::error \n";
    }
}

$borr->{'dateenrolled'} = format_date( $borr->{'dateenrolled'} );
$borr->{'expiry'}       = format_date( $borr->{'expiry'} );
$borr->{'dateofbirth'}  = format_date( $borr->{'dateofbirth'} );
$borr->{'ethnicity'}    = fixEthnicity( $borr->{'ethnicity'} );

my @bordat;
$bordat[0] = $borr;

$template->param( 
    BORROWER_INFO => \@bordat
);

output_html_with_http_headers $query, $cookie, $template->output;
