#!/usr/bin/perl

# Copyright 2009 SARL Biblibre
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
use warnings;

use C4::ILSDI::Services;
use C4::Auth;
use C4::Output;
use C4::Context;
use XML::Simple;
use CGI;

=head1 DLF ILS-DI for Koha

This script is a basic implementation of ILS-DI protocol for Koha.
It acts like a dispatcher, that get the CGI request, check required and 
optionals arguments, call a function from C4::ILS-DI::Services, and finaly 
outputs the returned hashref as XML.

=cut

# Instanciate the CGI request
my $cgi = new CGI;

# List of available services, sorted by level
my @services = (
    'Describe',    # Not part of ILS-DI, online API doc

    #	Level 1: Basic Discovery Interfaces
    #	'HarvestBibliographicRecords',       # OAI-PMH
    #	'HarvestExpandedRecords',            # OAI-PMH
    'GetAvailability',    # FIXME Add bibbliographic level

    #	'GoToBibliographicRequestPage'       # I don't understant this one
    #	Level 2: Elementary OPAC supplement
    #	'HarvestAuthorityRecords',           # OAI-PMH
    #	'HarvestHoldingsRecords',            # OAI-PMH
    'GetRecords',         # Note that we can use OAI-PMH for this too

    #	'Search',                            # TODO
    #	'Scan',	                             # TODO
    'GetAuthorityRecords',

    #	'OutputRewritablePage',              # I don't understant this one
    #	'OutputIntermediateFormat',          # I don't understant this one
    #	Level 3: Elementary OPAC alternative
    'LookupPatron',
    'AuthenticatePatron',
    'GetPatronInfo',
    'GetPatronStatus',
    'GetServices',    # FIXME Loans
    'RenewLoan',
    'HoldTitle',      # FIXME Add dates support
    'HoldItem',       # FIXME Add dates support
    'CancelHold',

    #	'RecallItem',                        # Not supported by Koha
    #	'CancelRecall',                      # Not supported by Koha
    #	Level 4: Robust/domain specific discovery platforms
    #	'SearchCourseReserves',              # TODO
    #	'Explain'                            # TODO
);

# List of required arguments
my %required = (
    'Describe'            => ['verb'],
    'GetAvailability'     => [ 'id', 'id_type' ],
    'GetRecords'          => ['id'],
    'GetAuthorityRecords' => ['id'],
    'LookupPatron'        => ['id'],
    'AuthenticatePatron'  => [ 'username', 'password' ],
    'GetPatronInfo'       => ['patron_id'],
    'GetPatronStatus'     => ['patron_id'],
    'GetServices'         => [ 'patron_id', 'item_id' ],
    'RenewLoan'           => [ 'patron_id', 'item_id' ],
    'HoldTitle'           => [ 'patron_id', 'bib_id', 'request_location' ],
    'HoldItem'            => [ 'patron_id', 'bib_id', 'item_id' ],
    'CancelHold' => [ 'patron_id', 'item_id' ],
);

# List of optional arguments
my %optional = (
    'Describe'            => [],
    'GetAvailability'     => [ 'return_type', 'return_fmt' ],
    'GetRecords'          => ['schema'],
    'GetAuthorityRecords' => ['schema'],
    'LookupPatron'        => ['id_type'],
    'AuthenticatePatron'  => [],
    'GetPatronInfo'       => [ 'show_contact', 'show_fines', 'show_holds', 'show_loans' ],
    'GetPatronStatus'     => [],
    'GetServices'         => [],
    'RenewLoan'           => ['desired_due_date'],
    'HoldTitle'  => [ 'pickup_location', 'needed_before_date', 'pickup_expiry_date' ],
    'HoldItem'   => [ 'pickup_location', 'needed_before_date', 'pickup_expiry_date' ],
    'CancelHold' => [],
);

# If ILS-DI module is disabled in System->Preferences, redirect to 404
if ( not C4::Context->preference('ILS-DI') ) {
    print $cgi->redirect("/cgi-bin/koha/errors/404.pl");
}

# If no service is requested, display the online documentation
if ( not $cgi->param('service') ) {
    my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {   template_name   => "ilsdi.tmpl",
            query           => $cgi,
            type            => "opac",
            authnotrequired => 1,
            debug           => 1,
        }
    );
    output_html_with_http_headers $cgi, $cookie, $template->output;
    exit 0;
}

# If user requested a service description, then display it
if ( $cgi->param('service') eq "Describe" and grep { $cgi->param('verb') eq $_ } @services ) {
    my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {   template_name   => "ilsdi.tmpl",
            query           => $cgi,
            type            => "opac",
            authnotrequired => 1,
            debug           => 1,
        }
    );
    $template->param( $cgi->param('verb') => 1 );
    output_html_with_http_headers $cgi, $cookie, $template->output;
    exit 0;
}

my $service = $cgi->param('service') || "ilsdi";

my $out;

# Check if the requested service is in the list
if ( $service and grep { $service eq $_ } @services ) {

    my @parmsrequired = @{ $required{$service} };
    my @parmsoptional = @{ $optional{$service} };
    my @parmsall      = ( @parmsrequired, @parmsoptional );
    my @names         = $cgi->param;
    my %paramhash     = ();
    foreach my $name (@names) {
        $paramhash{$name} = 1;
    }

    # check for missing parameters
    foreach my $name (@parmsrequired) {
        if ( ( !exists $paramhash{$name} ) ) {
            $out->{'message'} = "missing $name parameter";
        }
    }

    # check for illegal parameters
    foreach my $name (@names) {
        my $found = 0;
        foreach my $name2 (@parmsall) {
            if ( $name eq $name2 ) {
                $found = 1;
            }
        }
        if ( ( $found == 0 ) && ( $name ne 'service' ) ) {
            $out->{'message'} = "$name is an illegal parameter";
        }
    }

    # check for multiple parameters
    foreach my $name (@names) {
        my @values = $cgi->param($name);
        if ( $#values != 0 ) {
            $out->{'message'} = "multiple values are not allowed for the $name parameter";
        }
    }

    if ( !$out->{'message'} ) {

        # GetAvailability is a special case, as it cannot use XML::Simple
        if ( $service eq "GetAvailability" ) {
            print CGI::header('text/xml');
            print C4::ILSDI::Services::GetAvailability($cgi);
            exit 0;
        } else {

            # Variable functions
            my $sub = do {
                no strict 'refs';
                my $symbol = 'C4::ILSDI::Services::' . $service;
                \&{"$symbol"};
            };

            # Call the requested service, and get its return value
            $out = &$sub($cgi);
        }
    }
} else {
    $out->{'message'} = "NotSupported";
}

# Output XML by passing the hashref to XMLOut
print CGI::header('text/xml');
print XMLout(
    $out,
    noattr        => 1,
    noescape      => 1,
    nosort        => 1,
    xmldecl       => '<?xml version="1.0" encoding="ISO-8859-1" ?>',
    RootName      => $service,
    SuppressEmpty => 1
);

