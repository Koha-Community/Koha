#!/usr/bin/perl

# Copyright 2009 SARL Biblibre
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

use List::MoreUtils qw(any);

use C4::ILSDI::Services;
use C4::Auth;
use C4::Output;
use C4::Context;
use XML::Simple;
use CGI;

=head1 DLF ILS-DI for Koha

This script is a basic implementation of ILS-DI protocol for Koha.
It acts like a dispatcher, that get the CGI request, check required and 
optionals arguments, call a function from C4::ILS-DI, and finaly
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

# If no service is requested, display the online documentation
unless ( $cgi->param('service') ) {
    my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {   template_name   => "ilsdi.tt",
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
if ( $cgi->param('service') eq "Describe" and any { $cgi->param('verb') eq $_ } @services ) {
    my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {   template_name   => "ilsdi.tt",
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

# any output after this point will be UTF-8 XML
binmode STDOUT, ':encoding(UTF-8)';
print CGI::header('-type'=>'text/xml', '-charset'=>'utf-8');

my $out;

# If ILS-DI module is disabled in System->Preferences, redirect to 404
unless ( C4::Context->preference('ILS-DI') ) {
    $out->{'code'} = "NotAllowed";
    $out->{'message'} = "ILS-DI is disabled.";
}

# If the remote address is not allowed, redirect to 403
my @AuthorizedIPs = split(/,/, C4::Context->preference('ILS-DI:AuthorizedIPs'));
if ( @AuthorizedIPs # If no filter set, allow access to everybody
    and not any { $ENV{'REMOTE_ADDR'} eq $_ } @AuthorizedIPs # IP Check
    ) {
    $out->{'code'} = "NotAllowed";
    $out->{'message'} = "Unauthorized IP address: ".$ENV{'REMOTE_ADDR'}.".";
}

my $service = $cgi->param('service') || "ilsdi";

# Check if the requested service is in the list
if ( $service and any { $service eq $_ } @services ) {

    my @parmsrequired = @{ $required{$service} };
    my @parmsoptional = @{ $optional{$service} };
    my @parmsall      = ( @parmsrequired, @parmsoptional );
    my @names         = $cgi->param;
    my %paramhash;
    $paramhash{$_} = 1 for @names;

    # check for missing parameters
    for ( @parmsrequired ) {
        unless ( exists $paramhash{$_} ) {
            $out->{'code'} = "MissingParameter";
            $out->{'message'} = "The required parameter ".$_." is missing.";
        }
    }

    # check for illegal parameters
    for my $name ( @names ) {
        my $found = 0;
        for my $name2 (@parmsall) {
            if ( $name eq $name2 ) {
                $found = 1;
            }
        }
        if ( $found == 0 && $name ne 'service' ) {
            $out->{'code'} = "IllegalParameter";
            $out->{'message'} = "The parameter ".$name." is illegal.";
        }
    }

    # check for multiple parameters
    for ( @names ) {
        my @values = $cgi->param($_);
        if ( $#values != 0 ) {
            $out->{'code'} = "MultipleValuesNotAllowed";
            $out->{'message'} = "Multiple values not allowed for the parameter ".$_.".";
        }
    }

    if ( !$out->{'message'} ) {

        # GetAvailability is a special case, as it cannot use XML::Simple
        if ( $service eq "GetAvailability" ) {
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
print XMLout(
    $out,
    noattr        => 1,
    nosort        => 1,
    xmldecl       => '<?xml version="1.0" encoding="UTF-8" ?>',
    RootName      => $service,
    SuppressEmpty => 1
);
exit 0;

