#!/usr/bin/perl

# Copyright 2013 PTFS-Europe Ltd and Mark Gavillet
# Copyright 2014 PTFS-Europe Ltd
#
# This file is part of Koha.
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

use CGI;

use C4::Auth qw( get_template_and_user );
use C4::Output qw( output_and_exit output_html_with_http_headers );
use Koha::Notice::Templates;
use Koha::AuthorisedValues;
use Koha::Illcomment;
use Koha::Illrequests;
use Koha::Illrequest::Availability;
use Koha::Libraries;
use Koha::Token;

use Try::Tiny qw( catch try );
use URI::Escape qw( uri_escape_utf8 );
use JSON qw( encode_json );

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
my $cfg = Koha::Illrequest::Config->new;
my $backends = $cfg->available_backends;
my $has_branch = $cfg->has_branch;
my $backends_available = ( scalar @{$backends} > 0 );
$template->param(
    backends_available => $backends_available,
    has_branch         => $has_branch
);

if ( $backends_available ) {
    if ( $op eq 'illview' ) {
        # View the details of an ILL
        my $request = Koha::Illrequests->find($params->{illrequest_id});

        # Get the details for notices that can be sent from here
        my $notices = Koha::Notice::Templates->search(
            {
                module => 'ill',
                code => { -in => [ 'ILL_PICKUP_READY' ,'ILL_REQUEST_UNAVAIL' ] },
            },
            {
                columns => [ qw/code name/ ],
                distinct => 1
            }
        )->unblessed;

        $template->param(
            notices    => $notices,
            request    => $request,
            csrf_token => Koha::Token->new->generate_csrf({
                session_id => scalar $cgi->cookie('CGISESSID'),
            }),
            ( $params->{tran_error} ?
                ( tran_error => $params->{tran_error} ) : () ),
            ( $params->{tran_success} ?
                ( tran_success => $params->{tran_success} ) : () ),
        );

        output_and_exit( $cgi, $cookie, $template, 'unknown_ill_request' ) if !$request;

        my $backend_result = $request->backend_illview($params);
        $template->param(
            whole      => $backend_result,
        ) if $backend_result;


    } elsif ( $op eq 'create' ) {
        # We're in the process of creating a request
        my $request = Koha::Illrequest->new->load_backend( $params->{backend} );
        # Does this backend enable us to insert an availability stage and should
        # we? If not, proceed as normal.
        if (
            # If the user has elected to continue with the request despite
            # having viewed availability info, this flag will be set
            C4::Context->preference("ILLCheckAvailability")
              && !$params->{checked_availability}
              && $request->_backend_capability( 'should_display_availability', $params )
        ) {
            # Establish which of the installed availability providers
            # can service our metadata
            my $availability = Koha::Illrequest::Availability->new($params);
            my $services = $availability->get_services({
                ui_context => 'staff'
            });
            if (scalar @{$services} > 0) {
                # Modify our method so we use the correct part of the
                # template
                $op = 'availability';
                $params->{method} = 'availability';
                delete $params->{stage};
                # Prepare the metadata we're sending them
                my $metadata = $availability->prep_metadata($params);
                $template->param(
                    whole         => $params,
                    metadata      => $metadata,
                    services_json => scalar encode_json($services),
                    services      => $services
                );
            } else {
                # No services can process this metadata, so continue as normal
                my $backend_result = $request->backend_create($params);
                $template->param(
                    whole   => $backend_result,
                    request => $request
                );
                handle_commit_maybe($backend_result, $request);
            }
        } else {
            my $backend_result = $request->backend_create($params);
            $template->param(
                whole   => $backend_result,
                request => $request
            );
            handle_commit_maybe($backend_result, $request);
        }

    } elsif ( $op eq 'migrate' ) {
        # We're in the process of migrating a request
        my $request = Koha::Illrequests->find($params->{illrequest_id});
        my $backend_result;
        if ( $params->{backend} ) {
            $backend_result = $request->backend_migrate($params);
            if ($backend_result) {
                $template->param(
                    whole   => $backend_result,
                    request => $request
                );
            } else {
                # Backend failure, redirect back to illview
                print $cgi->redirect( '/cgi-bin/koha/ill/ill-requests.pl'
                      . '?method=illview'
                      . '&illrequest_id='
                      . $request->id
                      . '&error=migrate_target' );
                exit;
            }
        }
        else {
            $backend_result = $request->backend_migrate($params);
            $template->param(
                whole   => $backend_result,
                request => $request
            );
        }
        handle_commit_maybe( $backend_result, $request );

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
                whole          => $backend_result,
                request        => $request
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
            my $alias = (length $params->{status_alias} > 0) ?
                $params->{status_alias} :
                "-1";
            $request->status_alias($alias);
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

            # Prepare availability searching, if required
            # Get the definition for the z39.50 plugin
            if ( C4::Context->preference('ILLCheckAvailability') ) {
                my $availability = Koha::Illrequest::Availability->new($request->metadata);
                my $services = $availability->get_services({
                    ui_context => 'partners',
                    metadata => {
                        name => 'ILL availability - z39.50'
                    }
                });
                # Only pass availability searching stuff to the template if
                # appropriate
                if ( scalar @{$services} > 0 ) {
                    my $metadata = $availability->prep_metadata($request->metadata);
                    $template->param( metadata => $metadata );
                    $template->param(
                        services_json => scalar encode_json($services)
                    );
                    $template->param( services => $services );
                }
            }

            $template->param( error => $params->{error} )
                if $params->{error};
        }
        catch {
            my $error;
            if ( ref($_) eq 'Koha::Exceptions::Ill::NoTargetEmail' ) {
                $error = 'no_target_email';
            }
            elsif ( ref($_) eq 'Koha::Exceptions::Ill::NoLibraryEmail' ) {
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
    } elsif ( $op eq 'check_out') {
        my $request = Koha::Illrequests->find($params->{illrequest_id});
        my $backend_result = $request->check_out($params);
        $template->param(
            params  => $params,
            whole   => $backend_result,
            request => $request
        );
    } elsif ( $op eq 'illlist') {

        # If we receive a pre-filter, make it available to the template
        my $possible_filters = ['borrowernumber'];
        my $active_filters = {};
        foreach my $filter(@{$possible_filters}) {
            if ($params->{$filter}) {
                # We shouldn't need to escape $filter here since we're using
                # a whitelist, but just to be sure...
                $active_filters->{uri_escape_utf8($filter)} =
                    uri_escape_utf8(scalar $params->{$filter});
            }
        }
        my @tpl_arr = ();
        if (keys %{$active_filters}) {
            foreach my $key (keys %{$active_filters}) {
                push @tpl_arr, $key . "=" . $active_filters->{$key};
            }
        }
        $template->param(
            prefilters => join("&", @tpl_arr)
        );
    } elsif ( $op eq "save_comment" ) {
        die "Wrong CSRF token" unless Koha::Token->new->check_csrf({
           session_id => scalar $cgi->cookie('CGISESSID'),
           token      => scalar $cgi->param('csrf_token'),
        });
        my $comment = Koha::Illcomment->new({
            illrequest_id  => scalar $params->{illrequest_id},
            borrowernumber => $patronnumber,
            comment        => scalar $params->{comment},
        });
        $comment->store();
        # Redirect to view the whole request
        print $cgi->redirect("/cgi-bin/koha/ill/ill-requests.pl?method=illview&illrequest_id=".
            scalar $params->{illrequest_id}
        );
        exit;

    } elsif ( $op eq "send_notice" ) {
        my $illrequest_id = $params->{illrequest_id};
        my $request = Koha::Illrequests->find($illrequest_id);
        my $ret = $request->send_patron_notice($params->{notice_code});
        my $append = '';
        if ($ret->{result} && scalar @{$ret->{result}->{success}} > 0) {
            $append .= '&tran_success=' . join(',', @{$ret->{result}->{success}});
        }
        if ($ret->{result} && scalar @{$ret->{result}->{fail}} > 0) {
            $append .= '&tran_fail=' . join(',', @{$ret->{result}->{fail}}.join(','));
        }
        # Redirect to view the whole request
        print $cgi->redirect(
            "/cgi-bin/koha/ill/ill-requests.pl?method=illview&illrequest_id=".
            scalar $params->{illrequest_id} . $append
        );
        exit;
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
    types      => [ "Book", "Article", "Journal" ],
    query_type => $op,
    branches   => Koha::Libraries->search,
);

output_html_with_http_headers( $cgi, $cookie, $template->output );

sub handle_commit_maybe {
    my ( $backend_result, $request ) = @_;

    # We need to special case 'commit'
    if ( $backend_result->{stage} eq 'commit' ) {
        if ( $backend_result->{next} eq 'illview' ) {

            # Redirect to a view of the newly created request
            print $cgi->redirect( '/cgi-bin/koha/ill/ill-requests.pl'
                  . '?method=illview'
                  . '&illrequest_id='
                  . $request->id );
            exit;
        }
        elsif ( $backend_result->{next} eq 'emigrate' ) {

            # Redirect to a view of the newly created request
            print $cgi->redirect( '/cgi-bin/koha/ill/ill-requests.pl'
                  . '?method=migrate'
                  . '&stage=emigrate'
                  . '&illrequest_id='
                  . $request->id );
            exit;
        }
        else {
            # Redirect to a requests list view
            redirect_to_list();
        }
    }
}

sub redirect_to_list {
    print $cgi->redirect('/cgi-bin/koha/ill/ill-requests.pl');
    exit;
}
