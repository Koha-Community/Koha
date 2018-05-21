#!/usr/bin/perl

# Copyright 2013 PTFS-Europe Ltd and Mark Gavillet
# Copyright 2014 PTFS-Europe Ltd
#
# This file is part of Koha.
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use CGI;

use C4::Auth;
use C4::Output;
use Koha::AuthorisedValues;
use Koha::Illrequests;
use Koha::Libraries;

use Try::Tiny;

our $cgi = CGI->new;
my $illRequests = Koha::Illrequests->new;

# Grab all passed data
# 'our' since Plack changes the scoping
# of 'my'
our $params = $cgi->Vars();

# Leave immediately if ILLModule is disabled
unless ( C4::Context->preference('ILLModule') ) {
    print $cgi->redirect("/cgi-bin/koha/errors/404.pl");
    exit;
}

my $op = $params->{method} || 'illlist';

my ( $template, $patronnumber, $cookie ) = get_template_and_user( {
    template_name => 'ill/ill-requests.tt',
    query         => $cgi,
    type          => 'intranet',
    flagsrequired => { ill => '*' },
} );

# Are we able to actually work?
my $backends = Koha::Illrequest::Config->new->available_backends;
my $backends_available = ( scalar @{$backends} > 0 );
$template->param( backends_available => $backends_available );

if ( $backends_available ) {
    if ( $op eq 'illview' ) {
        # View the details of an ILL
        my $request = Koha::Illrequests->find($params->{illrequest_id});

        $template->param(
            request => $request
        );

    } elsif ( $op eq 'create' ) {
        # We're in the process of creating a request
        my $request = Koha::Illrequest->new->load_backend( $params->{backend} );
        my $backend_result = $request->backend_create($params);
        $template->param(
            whole   => $backend_result,
            request => $request
        );
        handle_commit_maybe($backend_result, $request);

    } elsif ( $op eq 'confirm' ) {
        # Backend 'confirm' method
        # confirm requires a specific request, so first, find it.
        my $request = Koha::Illrequests->find($params->{illrequest_id});
        my $backend_result = $request->backend_confirm($params);
        $template->param(
            whole   => $backend_result,
            request => $request,
        );

        # handle special commit rules & update type
        handle_commit_maybe($backend_result, $request);

    } elsif ( $op eq 'cancel' ) {
        # Backend 'cancel' method
        # cancel requires a specific request, so first, find it.
        my $request = Koha::Illrequests->find($params->{illrequest_id});
        my $backend_result = $request->backend_cancel($params);
        $template->param(
            whole   => $backend_result,
            request => $request,
        );

        # handle special commit rules & update type
        handle_commit_maybe($backend_result, $request);

    } elsif ( $op eq 'edit_action' ) {
        # Handle edits to the Illrequest object.
        # (not the Illrequestattributes)
        # We simulate the API for backend requests for uniformity.
        # So, init:
        my $request = Koha::Illrequests->find($params->{illrequest_id});
        if ( !$params->{stage} ) {
            my $backend_result = {
                error   => 0,
                status  => '',
                message => '',
                method  => 'edit_action',
                stage   => 'init',
                next    => '',
                value   => {}
            };
            $template->param(
                whole   => $backend_result,
                request => $request
            );
        } else {
            # Commit:
            # Save the changes
            $request->borrowernumber($params->{borrowernumber});
            $request->biblio_id($params->{biblio_id});
            $request->branchcode($params->{branchcode});
            $request->price_paid($params->{price_paid});
            $request->notesopac($params->{notesopac});
            $request->notesstaff($params->{notesstaff});
            $request->store;
            my $backend_result = {
                error   => 0,
                status  => '',
                message => '',
                method  => 'edit_action',
                stage   => 'commit',
                next    => 'illlist',
                value   => {}
            };
            handle_commit_maybe($backend_result, $request);
        }

    } elsif ( $op eq 'moderate_action' ) {
        # Moderate action is required for an ILL submodule / syspref.
        # Currently still needs to be implemented.
        redirect_to_list();

    } elsif ( $op eq 'delete_confirm') {
        my $request = Koha::Illrequests->find($params->{illrequest_id});

        $template->param(
            request => $request
        );

    } elsif ( $op eq 'delete' ) {

        # Check if the request is confirmed, if not, redirect
        # to the confirmation view
        if ($params->{confirmed}) {
            # We simply delete the request...
            Koha::Illrequests->find( $params->{illrequest_id} )->delete;
            # ... then return to list view.
            redirect_to_list();
        } else {
            print $cgi->redirect(
                "/cgi-bin/koha/ill/ill-requests.pl?" .
                "method=delete_confirm&illrequest_id=" .
                $params->{illrequest_id});
            exit;
        }

    } elsif ( $op eq 'mark_completed' ) {
        my $request = Koha::Illrequests->find($params->{illrequest_id});
        my $backend_result = $request->mark_completed($params);
        $template->param(
            whole => $backend_result,
            request => $request,
        );

        # handle special commit rules & update type
        handle_commit_maybe($backend_result, $request);

    } elsif ( $op eq 'generic_confirm' ) {
        my $backend_result;
        my $request;
        try {
            $request = Koha::Illrequests->find($params->{illrequest_id});
            $params->{current_branchcode} = C4::Context->mybranch;
            $backend_result = $request->generic_confirm($params);
            $template->param(
                whole => $backend_result,
                request => $request,
            );
            $template->param( error => $params->{error} )
                if $params->{error};
        }
        catch {
            my $error;
            if ( $_->isa( 'Koha::Exceptions::Ill::NoTargetEmail' ) ) {
                $error = 'no_target_email';
            }
            elsif ( $_->isa( 'Koha::Exceptions::Ill::NoLibraryEmail' ) ) {
                $error = 'no_library_email';
            }
            else {
                $error = 'unknown_error';
            }
            print $cgi->redirect(
                "/cgi-bin/koha/ill/ill-requests.pl?" .
                "method=generic_confirm&illrequest_id=" .
                $params->{illrequest_id} .
                "&error=$error" );
            exit;
        };

        # handle special commit rules & update type
        handle_commit_maybe($backend_result, $request);
    } elsif ( $op eq 'illlist') {

        # If we receive a pre-filter, make it available to the template
        my $possible_filters = ['borrowernumber'];
        my $active_filters = [];
        foreach my $filter(@{$possible_filters}) {
            if ($params->{$filter}) {
                push @{$active_filters},
                    { name => $filter, value => $params->{$filter}};
            }
        }
        if (scalar @{$active_filters} > 0) {
            $template->param(
                prefilters => $active_filters
            );
        }
    } else {
        my $request = Koha::Illrequests->find($params->{illrequest_id});
        my $backend_result = $request->custom_capability($op, $params);
        $template->param(
            whole => $backend_result,
            request => $request,
        );

        # handle special commit rules & update type
        handle_commit_maybe($backend_result, $request);
    }
}

$template->param(
    backends   => $backends,
    media      => [ "Book", "Article", "Journal" ],
    query_type => $op,
    branches   => scalar Koha::Libraries->search,
);

output_html_with_http_headers( $cgi, $cookie, $template->output );

sub handle_commit_maybe {
    my ( $backend_result, $request ) = @_;
    # We need to special case 'commit'
    if ( $backend_result->{stage} eq 'commit' ) {
        if ( $backend_result->{next} eq 'illview' ) {
            # Redirect to a view of the newly created request
            print $cgi->redirect(
                '/cgi-bin/koha/ill/ill-requests.pl?method=illview&illrequest_id='.
                $request->id
            );
            exit;
        } else {
            # Redirect to a requests list view
            redirect_to_list();
        }
    }
}

sub redirect_to_list {
    print $cgi->redirect('/cgi-bin/koha/ill/ill-requests.pl');
    exit;
}
