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

use Modern::Perl;
use Carp;

use C4::Auth qw(:DEFAULT get_session);
use CGI qw( -utf8 );
use C4::Context;
use C4::Output;
use C4::Log;
use C4::Debug;
use Koha::Patrons;
use Koha::Patron::Discharge;
use Koha::DateUtils;

my $input = new CGI;

unless ( C4::Context->preference('useDischarge') ) {
    print $input->redirect("/cgi-bin/koha/errors/404.pl");
    exit;
}

my $op = $input->param("op") // '';

# Getting the template and auth
my ( $template, $loggedinuser, $cookie ) = get_template_and_user({
    template_name => "opac-discharge.tt",
    query         => $input,
    type          => "opac",
    debug         => 1,
});

my $can_be_discharged = Koha::Patron::Discharge::can_be_discharged({ borrowernumber => $loggedinuser });
if ($can_be_discharged == 0) {
    $template->param( has_checkouts => 1 );
}

my $pending = Koha::Patron::Discharge::count({
    borrowernumber => $loggedinuser,
    pending        => 1,
});
my $available = Koha::Patron::Discharge::is_discharged({borrowernumber => $loggedinuser});

if ( $op eq 'request' ) {
    if ($pending || $available) {
        # Request already done
        print $input->redirect("/cgi-bin/koha/opac-discharge.pl");
        exit;
    }
    my $success = Koha::Patron::Discharge::request({
        borrowernumber => $loggedinuser,
    });
    if ($success) {
        $template->param( success => 1 );
    }
    else {
        $template->param( has_issues => 1 );
    }
}
elsif ( $op eq 'get' ) {
    unless ($available) {
        # No valid discharge to get
        print $input->redirect("/cgi-bin/koha/opac-discharge.pl");
        exit;
    }
    eval {

        # Getting member data
        my $patron = Koha::Patrons->find( $loggedinuser );
        my $pdf_path = Koha::Patron::Discharge::generate_as_pdf({
            borrowernumber => $loggedinuser,
            branchcode => $patron->branchcode,
        });

        binmode(STDOUT);
        print $input->header(
            -type       => 'application/pdf',
            -charset    => 'utf-8',
            -attachment => "discharge_$loggedinuser.pdf",
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
else {
    $template->param(
        available => $available,
        pending   => $pending,
    );
}

$template->param( dischargeview => 1 );

output_html_with_http_headers $input, $cookie, $template->output, undef, { force_no_caching => 1 };
