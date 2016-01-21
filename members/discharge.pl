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
use Koha::Patron::Images;

use Koha::DateUtils;

my $input = new CGI;
my ( $template, $loggedinuser, $cookie, $flags ) = get_template_and_user({
    template_name   => 'members/discharge.tt',
    query           => $input,
    type            => 'intranet',
    authnotrequired => 0,
    flagsrequired   => { 'borrowers' => '*' },
});

my $borrowernumber;
my $data;
if ( $input->param('borrowernumber') ) {
    $borrowernumber = $input->param('borrowernumber');

    # Getting member data
    $data = GetMember( borrowernumber => $borrowernumber );

    my $can_be_discharged = Koha::Patron::Discharge::can_be_discharged({
        borrowernumber => $borrowernumber
    });

    # Getting reserves
    my @reserves    = GetReservesFromBorrowernumber($borrowernumber);
    my $has_reserves = scalar(@reserves);

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
                { borrowernumber => $borrowernumber, branchcode => $data->{'branchcode'} } );

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

    my $patron_image = Koha::Patron::Images->find($borrowernumber);
    $template->param( picture => 1 ) if $patron_image;

    $template->param(
        borrowernumber    => $borrowernumber,
        biblionumber      => $data->{'biblionumber'},
        title             => $data->{'title'},
        initials          => $data->{'initials'},
        surname           => $data->{'surname'},
        borrowernumber    => $borrowernumber,
        firstname         => $data->{'firstname'},
        cardnumber        => $data->{'cardnumber'},
        categorycode      => $data->{'categorycode'},
        category_type     => $data->{'category_type'},
        categoryname      => $data->{'description'},
        address           => $data->{'address'},
        streetnumber      => $data->{streetnumber},
        streettype        => $data->{streettype},
        address2          => $data->{'address2'},
        city              => $data->{'city'},
        zipcode           => $data->{'zipcode'},
        country           => $data->{'country'},
        phone             => $data->{'phone'},
        email             => $data->{'email'},
        branchcode        => $data->{'branchcode'},
        has_reserves      => $has_reserves,
        can_be_discharged => $can_be_discharged,
        validated_discharges => $validated_discharges,
    );
}

$template->param( dischargeview => 1, );

output_html_with_http_headers $input, $cookie, $template->output;
