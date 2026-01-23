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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use CGI;

use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_and_exit output_html_with_http_headers );
use Koha::Notice::Templates;
use Koha::AuthorisedValues;
use Koha::ILL::Comment;
use Koha::ILL::Requests;
use Koha::ILL::Request;
use Koha::ILL::Batches;
use Koha::ILL::Request::Workflow::Availability;
use Koha::ILL::Request::Workflow::HistoryCheck;
use Koha::ILL::Request::Workflow::TypeDisclaimer;
use Koha::ILL::Request::Workflow::ConfirmAuto;
use Koha::Libraries;
use Koha::Plugins;

use Try::Tiny   qw( catch try );
use URI::Escape qw( uri_escape_utf8 );
use JSON        qw( encode_json );

our $cgi = CGI->new;
my $illRequests = Koha::ILL::Requests->new;

# Grab all passed data
# 'our' since Plack changes the scoping
# of 'my'
our $params = $cgi->Vars();

# Leave immediately if ILLModule is disabled
unless ( C4::Context->preference('ILLModule') ) {
    print $cgi->redirect("/cgi-bin/koha/errors/404.pl");
    exit;
}

my $op = Koha::ILL::Request->get_op_param_deprecation( 'intranet', $params );

my ( $template, $patronnumber, $cookie ) = get_template_and_user(
    {
        template_name => 'ill/ill-requests.tt',
        query         => $cgi,
        type          => 'intranet',
        flagsrequired => { ill => '*' },
    }
);

# Are we able to actually work?
my $cfg                = Koha::ILL::Request::Config->new;
my $backends           = $cfg->available_backends;
my $has_branch         = $cfg->has_branch;
my $backends_available = ( scalar @{$backends} > 0 );
$template->param(
    backends_available => $backends_available,
    has_branch         => $has_branch,
    have_batch         => have_batch_backends($backends)
);

if ( grep( /FreeForm/, @{$backends} ) ) {
    $template->param(
        ill_deprecated_backend_freeform_is_installed => 1,
    );
}

if ($backends_available) {

    # Establish what metadata enrichment plugins we have available
    my $enrichment_services = get_metadata_enrichment();
    if ( scalar @{$enrichment_services} > 0 ) {
        $template->param( metadata_enrichment_services => encode_json($enrichment_services) );
    }

    # Establish whether we have any availability services that can provide availability
    # for the batch identifier types we support
    my $batch_availability_services = get_ill_availability($enrichment_services);
    if ( scalar @{$batch_availability_services} > 0 ) {
        $template->param( batch_availability_services => encode_json($batch_availability_services) );
    }

    if ( $op eq 'illview' ) {

        # View the details of an ILL
        my $request = Koha::ILL::Requests->find( $params->{illrequest_id} );

        # Get the details for notices that can be sent from here
        my $notices = Koha::Notice::Templates->search(
            {
                module => 'ill',
                code   => { -in => [ 'ILL_PICKUP_READY', 'ILL_REQUEST_UNAVAIL' ] },
            },
            {
                columns  => [qw/code name/],
                distinct => 1
            }
        )->unblessed;

        $template->param(
            notices => $notices,
            request => $request,
            ( $params->{tran_fail}    ? ( tran_fail    => $params->{tran_fail} )    : () ),
            ( $params->{tran_success} ? ( tran_success => $params->{tran_success} ) : () ),
        );

        output_and_exit( $cgi, $cookie, $template, 'unknown_ill_request' ) if !$request;

        my $backend_result = $request->backend_illview($params);
        $template->param(
            whole => $backend_result,
        ) if $backend_result;

    } elsif ( $op eq 'cud-create' ) {

        # Load the ILL backend
        my $request = Koha::ILL::Request->new->load_backend( $params->{backend} );

        # Before request creation operations - Preparation
        my $history_check   = Koha::ILL::Request::Workflow::HistoryCheck->new( $params, 'staff' );
        my $availability    = Koha::ILL::Request::Workflow::Availability->new( $params, 'staff' );
        my $type_disclaimer = Koha::ILL::Request::Workflow::TypeDisclaimer->new( $params, 'staff' );
        my $confirm_auto    = Koha::ILL::Request::Workflow::ConfirmAuto->new( $params, 'staff' );

        # ILLHistoryCheck operation
        if ( $history_check->show_history_check($request) ) {
            $op = 'historycheck';
            $template->param( $history_check->history_check_template_params($params) )

            # ILLCheckAvailability operation
        } elsif ( $availability->show_availability($request) ) {
            $op = 'availability';
            $template->param( $availability->availability_template_params($params) )

            # ILLModuleDisclaimerByType operation
        } elsif ( $type_disclaimer->show_type_disclaimer($request) ) {
            $op = 'typedisclaimer';
            $template->param( $type_disclaimer->type_disclaimer_template_params($params) );

            # ConfirmAuto operation
        } elsif ( $confirm_auto->show_confirm_auto($request) ) {
            $op = 'confirmautoill';
            $template->param( $confirm_auto->confirm_auto_template_params($params) );

            # Ready to create ILL request
        } else {
            my $backend_result = $request->backend_create($params);

            # After creation actions
            if ( $params->{type_disclaimer_submitted} && $request->illrequest_id ) {
                $type_disclaimer->after_request_created( $params, $request );
            }

            $template->param(
                whole   => $backend_result,
                request => $request
            );
            redirect_user( $backend_result, $request );
        }
    } elsif ( $op eq 'migrate' ) {

        # We're in the process of migrating a request
        if ( $params->{auto_migrate} ) {

            my $confirm_auto = Koha::ILL::Request::Workflow::ConfirmAuto->new( $params, 'staff' );
            my $illrequest   = Koha::ILL::Requests->find( $params->{illrequest_id} );
            my $extended_attributes_hash =
                { map { $_->type => $_->value } $illrequest->extended_attributes->search->as_list };
            my $new_params = { %{ $illrequest->unblessed }, %$extended_attributes_hash };

            $template->param( $confirm_auto->confirm_auto_template_params($new_params) );
            $template->param(
                op           => 'confirmautoill',
                auto_migrate => 1,
                request      => $illrequest,
            );

            output_html_with_http_headers( $cgi, $cookie, $template->output );
            exit;
        }

        my $request = Koha::ILL::Requests->find( $params->{illrequest_id} );
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
                        . '?op=illview'
                        . '&illrequest_id='
                        . $request->id
                        . '&error=migrate_target' );
                exit;
            }
        } else {
            $backend_result = $request->backend_migrate($params);
            $template->param(
                whole   => $backend_result,
                request => $request
            );
        }
        redirect_user( $backend_result, $request );

    } elsif ( $op eq 'confirm' ) {

        # Backend 'confirm' method
        # confirm requires a specific request, so first, find it.
        my $request        = Koha::ILL::Requests->find( $params->{illrequest_id} );
        my $backend_result = $request->backend_confirm($params);
        $template->param(
            whole   => $backend_result,
            request => $request,
        );

        # handle special commit rules & update type
        redirect_user( $backend_result, $request );

    } elsif ( $op eq 'cud-cancel' ) {

        # Backend 'cancel' method
        # cancel requires a specific request, so first, find it.
        my $request        = Koha::ILL::Requests->find( $params->{illrequest_id} );
        my $backend_result = $request->backend_cancel($params);
        $template->param(
            whole   => $backend_result,
            request => $request,
        );

        # handle special commit rules & update type
        redirect_user( $backend_result, $request );

    } elsif ( $op eq 'cud-edit_action' ) {
        $op =~ s/^cud-//;

        # Handle edits to the Illrequest object.
        # (not the Illrequestattributes)
        # We simulate the API for backend requests for uniformity.
        # So, init:
        my $request = Koha::ILL::Requests->find( $params->{illrequest_id} );
        my $batches = Koha::ILL::Batches->search( undef, { order_by => { -asc => 'name' } } );
        if ( !$params->{stage} ) {
            my $backend_result = {
                error   => 0,
                status  => '',
                message => '',
                op      => 'edit_action',
                stage   => 'init',
                next    => '',
                value   => {}
            };
            $template->param(
                whole   => $backend_result,
                request => $request,
                batches => $batches
            );
        } else {
            my $valid_patron = Koha::Patrons->find( $params->{borrowernumber} );
            my $valid_biblio = Koha::Biblios->find( $params->{biblio_id} );

            if ( $params->{borrowernumber} && !$valid_patron || $params->{biblio_id} && !$valid_biblio ) {
                my $error_result = {
                    error  => 1,
                    status => $params->{borrowernumber} && !$valid_patron ? 'invalid_patron' : 'invalid_biblio',
                    op     => 'edit_action',
                    stage  => 'init',
                    next   => 'illview',
                };
                $template->param(
                    whole   => $error_result,
                    request => $request,
                );
            } else {
                $request->borrowernumber( $params->{borrowernumber} );
                $request->biblio_id( $params->{biblio_id} );
                $request->batch_id( $params->{batch_id} );
                $request->branchcode( $params->{branchcode} );
                $request->price_paid( $params->{price_paid} );
                $request->notesopac( $params->{notesopac} );
                $request->notesstaff( $params->{notesstaff} );
                my $alias =
                    ( length $params->{status_alias} > 0 )
                    ? $params->{status_alias}
                    : "-1";
                $request->status_alias($alias);
                $request->store;
                my $backend_result = {
                    error   => 0,
                    status  => '',
                    message => '',
                    op      => 'edit_action',
                    stage   => 'commit',
                    next    => 'illview',
                    value   => {}
                };
                redirect_user( $backend_result, $request );
            }
        }

    } elsif ( $op eq 'moderate_action' ) {

        # Moderate action is required for an ILL submodule / syspref.
        # Currently still needs to be implemented.
        redirect_to_list();

    } elsif ( $op eq 'delete_confirm' ) {
        my $request = Koha::ILL::Requests->find( $params->{illrequest_id} );

        $template->param( request => $request );

    } elsif ( $op eq 'cud-delete' ) {

        # Check if the request is confirmed, if not, redirect
        # to the confirmation view
        if ( $params->{confirmed} ) {

            # We simply delete the request...
            Koha::ILL::Requests->find( $params->{illrequest_id} )->delete;

            # ... then return to list view.
            redirect_to_list();
        } else {
            print $cgi->redirect(
                "/cgi-bin/koha/ill/ill-requests.pl?" . "op=delete_confirm&illrequest_id=" . $params->{illrequest_id} );
            exit;
        }

    } elsif ( $op eq 'mark_completed' ) {
        my $request        = Koha::ILL::Requests->find( $params->{illrequest_id} );
        my $backend_result = $request->mark_completed($params);
        $template->param(
            whole   => $backend_result,
            request => $request,
        );

        # handle special commit rules & update type
        redirect_user( $backend_result, $request );

    } elsif ( $op eq 'cud-generic_confirm' ) {
        $op =~ s/^cud-//;
        my $backend_result;
        my $request;
        try {
            $request                      = Koha::ILL::Requests->find( $params->{illrequest_id} );
            $params->{current_branchcode} = C4::Context->mybranch;
            $backend_result               = $request->generic_confirm($params);

            $template->param(
                whole   => $backend_result,
                request => $request,
            );

            # Prepare availability searching, if required
            # Get the definition for the z39.50 plugin
            if ( C4::Context->preference('ILLCheckAvailability') ) {
                my $availability = Koha::ILL::Request::Workflow::Availability->new(
                    {
                        name => 'ILL availability - z39.50',
                        %{ $request->metadata }
                    },
                    'partners'
                );
                my $services = $availability->get_services();

                # Only pass availability searching stuff to the template if
                # appropriate
                if ( scalar @{$services} > 0 ) {
                    my $metadata = $availability->prep_metadata( $request->metadata );
                    $template->param( metadata      => $metadata );
                    $template->param( services_json => scalar encode_json($services) );
                    $template->param( services      => $services );
                }
            }

            $template->param( error => $params->{error} )
                if $params->{error};
        } catch {
            my $error;
            if ( ref($_) eq 'Koha::Exceptions::Ill::NoTargetEmail' ) {
                $error = 'no_target_email';
            } elsif ( ref($_) eq 'Koha::Exceptions::Ill::NoLibraryEmail' ) {
                $error = 'no_library_email';
            } else {
                $error = 'unknown_error';
            }
            print $cgi->redirect( "/cgi-bin/koha/ill/ill-requests.pl?"
                    . "op=generic_confirm&illrequest_id="
                    . $params->{illrequest_id}
                    . "&error=$error" );
            exit;
        };

        # handle special commit rules & update type
        redirect_user( $backend_result, $request );
    } elsif ( $op eq 'cud-check_out' ) {
        $op =~ s/^cud-//;
        my $request        = Koha::ILL::Requests->find( $params->{illrequest_id} );
        my $backend_result = $request->check_out($params);
        $template->param(
            params  => $params,
            whole   => $backend_result,
            request => $request
        );
    } elsif ( $op eq 'illlist' ) {

        # If we receive a pre-filter, make it available to the template
        my $possible_filters = [ 'borrowernumber', 'batch_id' ];
        my $active_filters   = {};
        foreach my $filter ( @{$possible_filters} ) {
            if ( $params->{$filter} ) {

                # We shouldn't need to escape $filter here since we're using
                # a whitelist, but just to be sure...
                $active_filters->{ uri_escape_utf8($filter) } =
                    uri_escape_utf8( scalar $params->{$filter} );
            }
        }
        my @tpl_arr = ();
        if ( keys %{$active_filters} ) {
            foreach my $key ( keys %{$active_filters} ) {
                push @tpl_arr, $key . "=" . $active_filters->{$key};
            }
        }
        $template->param( prefilters => join( "&", @tpl_arr ) );

        if ( $active_filters->{batch_id} ) {
            my $batch_id = $active_filters->{batch_id};
            if ($batch_id) {
                my $batch = Koha::ILL::Batches->find($batch_id);
                $template->param( batch => $batch );
            }
        }

        $template->param( table_actions => encode_json( Koha::ILL::Request->get_staff_table_actions ) );
    } elsif ( $op eq "cud-save_comment" ) {
        my $comment = Koha::ILL::Comment->new(
            {
                illrequest_id  => scalar $params->{illrequest_id},
                borrowernumber => $patronnumber,
                comment        => scalar $params->{comment},
            }
        );
        $comment->store();

        # Redirect to view the whole request
        print $cgi->redirect(
            "/cgi-bin/koha/ill/ill-requests.pl?op=illview&illrequest_id=" . scalar $params->{illrequest_id} );
        exit;

    } elsif ( $op eq "send_notice" ) {
        my $illrequest_id = $params->{illrequest_id};
        my $request       = Koha::ILL::Requests->find($illrequest_id);
        my $ret           = $request->send_patron_notice( $params->{notice_code} );
        my $append        = '';
        if ( $ret->{result} && scalar @{ $ret->{result}->{success} } > 0 ) {
            $append .= '&tran_success=' . join( ',', @{ $ret->{result}->{success} } );
        }
        if ( $ret->{result} && scalar @{ $ret->{result}->{fail} } > 0 ) {
            $append .= '&tran_fail=' . join( ',', @{ $ret->{result}->{fail} } );
        }

        # Redirect to view the whole request
        print $cgi->redirect(
            "/cgi-bin/koha/ill/ill-requests.pl?op=illview&illrequest_id=" . scalar $params->{illrequest_id} . $append );
        exit;
    } elsif ( $op eq "batch_list" ) {

        # Do not remove, it prevents us falling through to the 'else'
    } else {
        $op =~ s/^cud-//;
        my $request        = Koha::ILL::Requests->find( $params->{illrequest_id} );
        my $backend_result = $request->custom_capability( $op, $params );
        $template->param(
            whole   => $backend_result,
            request => $request,
        );

        # handle special commit rules & update type
        redirect_user( $backend_result, $request );
    }
}

$template->param(
    backends => $backends,
    types    => [ "Book", "Article", "Journal" ],
    op       => $op,
    branches => Koha::Libraries->search(
        { pickup_location => 1 },
        { order_by        => ['branchname'] }
    ),
    illreq_tabs => C4::Context->yaml_preference('ILLRequestsTabs'),
);

output_html_with_http_headers( $cgi, $cookie, $template->output );

sub redirect_user {
    my ( $backend_result, $request ) = @_;

    # We need to special case 'commit'
    if ( $backend_result->{stage} eq 'commit' ) {
        if ( $backend_result->{next} eq 'illview' ) {

            # Redirect to a view of the newly created request
            print $cgi->redirect(
                '/cgi-bin/koha/ill/ill-requests.pl' . '?op=illview' . '&illrequest_id=' . $request->id );
            exit;
        } elsif ( $backend_result->{next} eq 'emigrate' ) {

            # Redirect to a view of the newly created request
            print $cgi->redirect( '/cgi-bin/koha/ill/ill-requests.pl'
                    . '?op=migrate'
                    . '&stage=emigrate'
                    . '&illrequest_id='
                    . $request->id );
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

# Do any of the available backends provide batch requesting
sub have_batch_backends {
    my ($backends) = @_;

    my @have_batch = ();

    foreach my $backend ( @{$backends} ) {
        my $can_batch = can_batch($backend);
        if ($can_batch) {
            push @have_batch, $backend;
        }
    }
    return \@have_batch;
}

# Does a given backend provide batch requests
# FIXME: This should be moved to Koha::Illbackend
sub can_batch {
    my ($backend) = @_;
    my $request = Koha::ILL::Request->new->load_backend($backend);
    return $request->_backend_capability('provides_batch_requests');
}

# Get available metadata enrichment plugins
sub get_metadata_enrichment {
    return [] unless C4::Context->config("enable_plugins");
    my @candidates = Koha::Plugins->new()->GetPlugins( { method => 'provides_api' } );
    my @services   = ();
    foreach my $plugin (@candidates) {
        my $supported = $plugin->provides_api();
        if ( $supported->{type} eq 'search' ) {
            push @services, $supported;
        }
    }
    return \@services;
}

# Get ILL availability plugins that can help us with the batch identifier types
# we support
sub get_ill_availability {
    my ($services) = @_;

    my $id_types = {};
    foreach my $service ( @{$services} ) {
        foreach my $id_supported ( keys %{ $service->{identifiers_supported} } ) {
            $id_types->{$id_supported} = 1;
        }
    }

    my $availability = Koha::ILL::Request::Workflow::Availability->new( $id_types, 'staff' );
    return $availability->get_services();
}
