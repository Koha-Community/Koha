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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use strict;
use warnings;

use CGI;
use Mail::Sendmail;
use Encode;

use C4::Auth;    # checkauth, getborrowernumber.
use C4::Context;
use C4::Koha;
use C4::Circulation;
use C4::Output;
use C4::Dates qw/format_date/;
use C4::Members;
use C4::Members::Attributes;
use C4::Branch;

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
my ( $borr ) = GetMemberDetails( $borrowernumber );
my ( $patronemail ) = GetFirstValidEmailAddress($borrowernumber);
my $lib = GetBranchDetail($borr->{'branchcode'});

# handle the new information....
# collect the form values and send an email.
my @fields = (
    'surname','firstname','othernames','streetnumber','address','address2','city','state','zipcode','country','phone','mobile','fax','phonepro', 'emailaddress','emailpro','B_streetnumber','B_address','B_address2','B_city','B_state','B_zipcode','B_country','B_phone','B_email','dateofbirth','sex'
);
my $update;
my $updateemailaddress = $lib->{'branchemail'};
$updateemailaddress = C4::Context->preference('KohaAdminEmailAddress') unless( $updateemailaddress =~ /\w+@\w+/);
if ( !$updateemailaddress || $updateemailaddress eq '' ) {
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
        noadminemail => 1,
    );

    output_html_with_http_headers $query, $cookie, $template->output;
    exit;
}

if ( !$patronemail || $patronemail eq '' ) {
	$patronemail = $updateemailaddress;
};

if ( $query->param('modify') ) {

    # get all the fields:
    my $message = <<"EOF";
Patron $borr->{'cardnumber'} has requested to change her/his personal details.
Please check these new details and make the changes to these fields:

EOF

    my $streetnumber = $borr->{'streetnumber'} || '';
    my $address = $borr->{'address'} || '';
    my $address2 = $borr->{'address2'} || '';
    my $B_streetnumber = $borr->{'B_streetnumber'} || '';
    my $B_address = $borr->{'B_address'} || '';
    my $B_address2 = $borr->{'B_address2'} || '';

    foreach my $field (@fields) {
        my $newfield = decode('utf-8',$query->param($field)) || '';
        my $borrowerfield = '';
        if($borr->{$field}) {
            $borrowerfield = $borr->{$field};
        }
        
        if($field eq "dateofbirth") {
           $borrowerfield  = format_date( $borr->{'dateofbirth'} ) || '';
        }

        if($borrowerfield ne $newfield) {
            $message .= $field . " : $borrowerfield  -->  $newfield\n";
        }
    }

    $message .= "\nEdit this patron's record: http://".C4::Context->preference('staffClientBaseURL ')."/cgi-bin/koha/members/memberentry.pl?op=modify&borrowernumber=".$borr->{'borrowernumber'}."&categorycode=".$borr->{'categorycode'} if C4::Context->preference('staffClientBaseURL ');

    $message .= "\n\nThanks,\nKoha\n\n";
    my %mail = (
        To      => $updateemailaddress,
        From    => $patronemail,
        Subject => "User Request for update of Record.",
        Message => encode('utf-8', $message), # Mail::Sendmail doesn't like wide characters
        'Content-Type' => 'text/plain; charset="utf-8"',
    );

    if ( sendmail %mail ) {

        # do something if it works....
        print $query->redirect('/cgi-bin/koha/opac-user.pl?patronupdate=sent');
        exit;
    }
    else {

        # do something if it doesnt work....
        warn "Error sending mail: $Mail::Sendmail::error \n";
    }
}

$borr->{'ethnicity'}    = fixEthnicity( $borr->{'ethnicity'} );
$borr->{'branchname'}   = GetBranchName($borr->{'branchcode'});

if (C4::Context->preference('ExtendedPatronAttributes')) {
    my $attributes = C4::Members::Attributes::GetBorrowerAttributes($borrowernumber, 'opac');
    if (scalar(@$attributes) > 0) {
        $borr->{ExtendedPatronAttributes} = 1;
        $borr->{patron_attributes} = $attributes;
    }
}

my $checkin_prefs  = C4::Members::Messaging::GetMessagingPreferences({
    borrowernumber => $borrowernumber,
    message_name   => 'Item Checkout'
});
for ( keys %{ $checkin_prefs->{transports} }) {
    $borr->{"items_returned_$_"} = 1;
}
my $checkout_prefs = C4::Members::Messaging::GetMessagingPreferences({
    borrowernumber => $borrowernumber,
    message_name   => 'Item Check-in'
});
for ( keys %{ $checkout_prefs->{transports} }) {
    $borr->{"items_borrowed_$_"} = 1;
}

if (C4::Context->preference('OPACpatronimages')) {
    my ($image, $dberror) = GetPatronImage($borr->{'cardnumber'});
    if ($image) {
        $template->param(
            display_patron_image => 1
        );
    }
}

my @bordat;
$bordat[0] = $borr;

$template->param( 
    BORROWER_INFO => \@bordat,
    userupdateview => 1,
);

output_html_with_http_headers $query, $cookie, $template->output;
