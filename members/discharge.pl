#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright 2013 BibLibre
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

=head1 NAME

discharges.pl

=head1 DESCRIPTION

Allows librarian to edit and/or manage borrowers' discharges

=cut

use Modern::Perl;
use Carp;

use CGI qw( -utf8 );
use C4::Auth;
use C4::Output;
use C4::Members;
use C4::Reserves;
use C4::Letters;
use Koha::Patron::Discharge;
use Koha::Patrons;

use Koha::DateUtils;

my $input = new CGI;

my ( $template, $loggedinuser, $cookie, $flags ) = get_template_and_user({
    template_name   => 'members/discharge.tt',
    query           => $input,
    type            => 'intranet',
    authnotrequired => 0,
    flagsrequired   => { 'borrowers' => 'edit_borrowers' },
});

my $borrowernumber = $input->param('borrowernumber');

unless ( C4::Context->preference('useDischarge') ) {
   print $input->redirect("/cgi-bin/koha/circ/circulation.pl?borrowernumber=$borrowernumber&nopermission=1");
   exit;
}

$borrowernumber = $input->param('borrowernumber');

my $patron = Koha::Patrons->find( $borrowernumber );
unless ( $patron ) {
    print $input->redirect("/cgi-bin/koha/circ/circulation.pl?borrowernumber=$borrowernumber");
    exit;
}

my $can_be_discharged = Koha::Patron::Discharge::can_be_discharged({
    borrowernumber => $borrowernumber
});

my $holds = $patron->holds;
my $has_reserves = $holds->count;

# Generating discharge if needed
if ( $input->param('discharge') and $can_be_discharged ) {
    my $is_discharged = Koha::Patron::Discharge::is_discharged({
        borrowernumber => $borrowernumber,
    });
    unless ($is_discharged) {
        Koha::Patron::Discharge::discharge({
            borrowernumber => $borrowernumber
        });
    }
    eval {
        my $pdf_path = Koha::Patron::Discharge::generate_as_pdf(
            { borrowernumber => $borrowernumber, branchcode => $patron->branchcode } );

        binmode(STDOUT);
        print $input->header(
            -type       => 'application/pdf',
            -charset    => 'utf-8',
            -attachment => "discharge_$borrowernumber.pdf",
        );
        open my $fh, '<', $pdf_path;
        my @lines = <$fh>;
        close $fh;
        print @lines;
        exit;
    };
    if ( $@ ) {
        carp $@;
        $template->param( messages => [ {type => 'error', code => 'unable_to_generate_pdf'} ] );
    }
}

# Already generated discharges
my $validated_discharges = Koha::Patron::Discharge::get_validated({
    borrowernumber => $borrowernumber,
});

$template->param( picture => 1 ) if $patron->image;

$template->param(
    # FIXME The patron object should be passed to the template
    borrowernumber    => $borrowernumber,
    title             => $patron->title,
    initials          => $patron->initials,
    surname           => $patron->surname,
    borrowernumber    => $borrowernumber,
    firstname         => $patron->firstname,
    cardnumber        => $patron->cardnumber,
    categorycode      => $patron->categorycode,
    category_type     => $patron->category->category_type,
    categoryname      => $patron->category->description,
    address           => $patron->address,
    streetnumber      => $patron->streetnumber,
    streettype        => $patron->streettype,
    address2          => $patron->address2,
    city              => $patron->city,
    zipcode           => $patron->zipcode,
    country           => $patron->country,
    phone             => $patron->phone,
    email             => $patron->email,
    branchcode        => $patron->branchcode,
    has_reserves      => $has_reserves,
    can_be_discharged => $can_be_discharged,
    validated_discharges => $validated_discharges,
);

$template->param( dischargeview => 1, );

output_html_with_http_headers $input, $cookie, $template->output;
