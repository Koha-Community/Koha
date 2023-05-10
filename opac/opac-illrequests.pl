#!/usr/bin/perl

# Copyright 2017 PTFS-Europe Ltd
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

use JSON qw( encode_json );

use CGI qw ( -utf8 );
use C4::Auth qw( get_template_and_user );
use C4::Koha;
use C4::Output qw( output_html_with_http_headers );

use Koha::Illrequest::Config;
use Koha::Illrequests;
use Koha::Libraries;
use Koha::Patrons;
use Koha::Illrequest::Availability;

my $query = CGI->new;

# Grab all passed data
# 'our' since Plack changes the scoping
# of 'my'
our $params = $query->Vars();

# if illrequests is disabled, leave immediately
if ( ! C4::Context->preference('ILLModule') ) {
    print $query->redirect("/cgi-bin/koha/errors/404.pl");
    exit;
}

my ( $template, $loggedinuser, $cookie ) = get_template_and_user({
    template_name   => "opac-illrequests.tt",
    query           => $query,
    type            => "opac",
});

# Are we able to actually work?
my $reduced  = C4::Context->preference('ILLOpacbackends');
my $backends = Koha::Illrequest::Config->new->available_backends($reduced);
my $backends_available = ( scalar @{$backends} > 0 );
$template->param( backends_available => $backends_available );

my $op = $params->{'method'} || 'list';

my ( $illrequest_id, $request );
if ( $illrequest_id = $params->{illrequest_id} ) {
    $request = Koha::Illrequests->find($illrequest_id);
    # Make sure the request belongs to the logged in user
    unless ( $request->borrowernumber == $loggedinuser ) {
        print $query->redirect("/cgi-bin/koha/errors/404.pl");
        exit;
    }
}

if ( $op eq 'list' ) {

    my $requests = Koha::Illrequests->search(
        { borrowernumber => $loggedinuser }
    );
    $template->param(
        requests => $requests,
        backends => $backends
    );

} elsif ( $op eq 'view') {
    $template->param(
        request => $request
    );

} elsif ( $op eq 'update') {
    $request->notesopac($params->{notesopac})->store;
    # Send a notice to staff alerting them of the update
    $request->send_staff_notice('ILL_REQUEST_MODIFIED');
    print $query->redirect(
            '/cgi-bin/koha/opac-illrequests.pl?method=view&illrequest_id='
          . $illrequest_id
          . '&message=1' );
    exit;
} elsif ( $op eq 'cancreq') {
    $request->status('CANCREQ')->store;
    print $query->redirect(
            '/cgi-bin/koha/opac-illrequests.pl?method=view&illrequest_id='
          . $illrequest_id
          . '&message=1' );
    exit;
} elsif ( $op eq 'create' ) {
    if (!$params->{backend}) {
        my $req = Koha::Illrequest->new;
        $template->param(
            backends    => $req->available_backends
        );
    } else {
        my $request = Koha::Illrequest->new
            ->load_backend($params->{backend});

        # Does this backend enable us to insert an availability stage and should
        # we? If not, proceed as normal.
        if (
            C4::Context->preference("ILLCheckAvailability") &&
            $request->_backend_capability(
                'should_display_availability',
                $params
            ) &&
            # If the user has elected to continue with the request despite
            # having viewed availability info, this flag will be set
            !$params->{checked_availability}
        ) {
            # Establish which of the installed availability providers
            # can service our metadata, if so, jump in
            my $availability = Koha::Illrequest::Availability->new($params);
            my $services = $availability->get_services({
                ui_context => 'opac'
            });
            if (scalar @{$services} > 0) {
                # Modify our method so we use the correct part of the
                # template
                $op = 'availability';
                # Prepare the metadata we're sending them
                my $metadata = $availability->prep_metadata($params);
                $template->param(
                    metadata        => $metadata,
                    services_json   => encode_json($services),
                    services        => $services,
                    illrequestsview => 1,
                    message         => $params->{message},
                    method          => $op,
                    whole           => $params
                );
                output_html_with_http_headers $query, $cookie,
                    $template->output, undef, { force_no_caching => 1 };
                exit;
            }
        }

        $params->{cardnumber} = Koha::Patrons->find({
            borrowernumber => $loggedinuser
        })->cardnumber;
        $params->{opac} = 1;
        my $backend_result = $request->backend_create($params);
        if ($backend_result->{stage} eq 'copyrightclearance') {
            $template->param(
                stage       => $backend_result->{stage},
                whole       => $backend_result
            );
        } else {
            $template->param(
                types       => [ "Book", "Article", "Journal" ],
                branches    => Koha::Libraries->search->unblessed,
                whole       => $backend_result,
                request     => $request
            );
            if ($backend_result->{stage} eq 'commit') {
                print $query->redirect('/cgi-bin/koha/opac-illrequests.pl?message=2');
                exit;
            }
        }

    }
}

$template->param(
    message         => $params->{message},
    illrequestsview => 1,
    method          => $op
);

output_html_with_http_headers $query, $cookie, $template->output, undef, { force_no_caching => 1 };
