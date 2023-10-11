package Koha::Illrequest;

# Copyright PTFS Europe 2016,2018
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

use Clone qw( clone );
use Try::Tiny qw( catch try );
use DateTime;

use C4::Letters;
use Mojo::Util qw(deprecated);

use Koha::Cache::Memory::Lite;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );
use Koha::Exceptions::Ill;
use Koha::Illcomments;
use Koha::Illrequestattributes;
use Koha::AuthorisedValue;
use Koha::Illrequest::Logger;
use Koha::Patron;
use Koha::Illbatches;
use Koha::AuthorisedValues;
use Koha::Biblios;
use Koha::Items;
use Koha::ItemTypes;
use Koha::Libraries;

use C4::Circulation qw( CanBookBeIssued AddIssue );

use base qw(Koha::Object);

=head1 NAME

Koha::Illrequest - Koha Illrequest Object class

=head1 (Re)Design

An ILLRequest consists of two parts; the Illrequest Koha::Object, and a series
of related Illrequestattributes.

The former encapsulates the basic necessary information that any ILL requires
to be usable in Koha.  The latter is a set of additional properties used by
one of the backends.

The former subsumes the legacy "Status" object.  The latter remains
encapsulated in the "Record" object.

TODO:

- Anything invoking the ->status method; annotated with:
  + # Old use of ->status !

=head1 API

=head2 Backend API Response Principles

All methods should return a hashref in the following format:

=over

=item * error

This should be set to 1 if an error was encountered.

=item * status

The status should be a string from the list of statuses detailed below.

=item * message

The message is a free text field that can be passed on to the end user.

=item * value

The value returned by the method.

=back

=head2 Interface Status Messages

=over

=item * branch_address_incomplete

An interface request has determined branch address details are incomplete.

=item * cancel_success

The interface's cancel_request method was successful in cancelling the
Illrequest using the API.

=item * cancel_fail

The interface's cancel_request method failed to cancel the Illrequest using
the API.

=item * unavailable

The interface's request method returned saying that the desired item is not
available for request.

=back

=head2 Class methods

=head3 init_processors

    $request->init_processors()

Initialises an empty processors arrayref

=cut

sub init_processors {
    my ( $self ) = @_;

    $self->{processors} = [];
}

=head3 push_processor

    $request->push_processors(sub { ...something... });

Pushes a passed processor function into our processors arrayref

=cut

sub push_processor {
    my ( $self, $processor ) = @_;
    push @{$self->{processors}}, $processor;
}

=head3 batch

    my $batch = $request->batch;

Returns the batch associated with a request

=cut

sub batch {
    my ( $self ) = @_;

    return Koha::Illbatches->find($self->_result->batch_id);
}

=head3 statusalias

    my $statusalias = $request->statusalias;

Returns a request's status alias, as a Koha::AuthorisedValue instance
or implicit undef. This is distinct from status_alias, which only returns
the value in the status_alias column, this method returns the entire
AuthorisedValue object

=cut

sub statusalias {
    my ( $self ) = @_;
    return unless $self->status_alias;
    # We can't know which result is the right one if there are multiple
    # ILL_STATUS_ALIAS authorised values with the same authorised_value column value
    # so we just use the first
    return Koha::AuthorisedValues->search(
        {
            category         => 'ILL_STATUS_ALIAS',
            authorised_value => $self->SUPER::status_alias
        },
        {},
        $self->branchcode
    )->next;
}

=head3 illrequestattributes

=cut

sub illrequestattributes {
    deprecated 'illrequestattributes is DEPRECATED in favor of extended_attributes';
    my ( $self ) = @_;
    return Koha::Illrequestattributes->_new_from_dbic(
        scalar $self->_result->illrequestattributes
    );
}

=head3 illcomments

=cut

sub illcomments {
    my ( $self ) = @_;
    return Koha::Illcomments->_new_from_dbic(
        scalar $self->_result->illcomments
    );
}

=head3 comments

    my $ill_comments = $req->comments;

Returns a I<Koha::Illcomments> resultset for the linked comments.

=cut

sub comments {
    my ( $self ) = @_;
    return Koha::Illcomments->_new_from_dbic(
        scalar $self->_result->comments
    );
}

=head3 logs

=cut

sub logs {
    my ( $self ) = @_;
    my $logger = Koha::Illrequest::Logger->new;
    return $logger->get_request_logs($self);
}

=head3 patron

    my $patron = $request->patron;

Returns the linked I<Koha::Patron> object.

=cut

sub patron {
    my ( $self ) = @_;

    return Koha::Patron->_new_from_dbic( scalar $self->_result->patron );
}

=head3 library

    my $library = $request->library;

Returns the linked I<Koha::Library> object.

=cut

sub library {
    my ($self) = @_;

    return Koha::Library->_new_from_dbic( scalar $self->_result->library );
}

=head3 extended_attributes

    my $extended_attributes = $request->extended_attributes;

Returns the linked I<Koha::Illrequestattributes> resultset object.

=cut

sub extended_attributes {
    my ( $self ) = @_;

    my $rs = $self->_result->extended_attributes;
    # We call search to use the filters in Koha::Illrequestattributes->search
    return Koha::Illrequestattributes->_new_from_dbic($rs)->search;
}

=head3 status_alias

    $Illrequest->status_alias(143);

Overloaded getter/setter for status_alias,
that only returns authorised values from the
correct category and records the fact that the status has changed

=cut

sub status_alias {
    my ($self, $new_status_alias) = @_;

    my $current_status_alias = $self->SUPER::status_alias;

    if ($new_status_alias) {
        # Keep a record of the previous status before we change it,
        # we might need it
        $self->{previous_status} = $current_status_alias ?
            $current_status_alias :
            scalar $self->status;
        # This is hackery to enable us to undefine
        # status_alias, since we need to have an overloaded
        # status_alias method to get us around the problem described
        # here:
        # https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20581#c156
        # We need a way of accepting implied undef, so we can nullify
        # the status_alias column, when called from $self->status
        my $val = $new_status_alias eq "-1" ? undef : $new_status_alias;
        my $ret = $self->SUPER::status_alias($val);
        my $val_to_log = $val ? $new_status_alias : scalar $self->status;
        if ($ret) {
            my $logger = Koha::Illrequest::Logger->new;
            $logger->log_status_change({
                request => $self,
                value   => $val_to_log
            });
        } else {
            delete $self->{previous_status};
        }
        return $ret;
    }
    # We can't know which result is the right one if there are multiple
    # ILL_STATUS_ALIAS authorised values with the same authorised_value column value
    # so we just use the first
    my $alias = Koha::AuthorisedValues->search(
        {
            category         => 'ILL_STATUS_ALIAS',
            authorised_value => $self->SUPER::status_alias
        },
        {},
        $self->branchcode
    )->next;

    if ($alias) {
        return $alias->authorised_value;
    } else {
        return;
    }
}

=head3 status

    $Illrequest->status('CANREQ');

Overloaded getter/setter for request status,
also nullifies status_alias and records the fact that the status has changed
and sends a notice if appropriate

=cut

sub status {
    my ( $self, $new_status) = @_;

    my $current_status = $self->SUPER::status;
    my $current_status_alias = $self->SUPER::status_alias;

    if ($new_status) {
        # Keep a record of the previous status before we change it,
        # we might need it
        $self->{previous_status} = $current_status_alias ?
            $current_status_alias :
            $current_status;
        my $ret = $self->SUPER::status($new_status)->store;
        if ($current_status_alias) {
            # This is hackery to enable us to undefine
            # status_alias, since we need to have an overloaded
            # status_alias method to get us around the problem described
            # here:
            # https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20581#c156
            # We need a way of passing implied undef to nullify status_alias
            # so we pass -1, which is special cased in the overloaded setter
            $self->status_alias("-1");
        } else {
            my $logger = Koha::Illrequest::Logger->new;
            $logger->log_status_change({
                request => $self,
                value   => $new_status
            });
        }
        delete $self->{previous_status};
        # If status has changed to cancellation requested, send a notice
        if ($new_status eq 'CANCREQ') {
            $self->send_staff_notice('ILL_REQUEST_CANCEL');
        }
        return $ret;
    } else {
        return $current_status;
    }
}

=head3 load_backend

Require "Base.pm" from the relevant ILL backend.

=cut

sub load_backend {
    my ( $self, $backend_id ) = @_;

    my @raw = qw/Koha Illbackends/; # Base Path

    my $backend_name = $backend_id || $self->backend;

    unless ( defined $backend_name && $backend_name ne '' ) {
        Koha::Exceptions::Ill::InvalidBackendId->throw(
            "An invalid backend ID was requested ('')");
    }

    my $location = join "/", @raw, $backend_name, "Base.pm";    # File to load
    my $backend_class = join "::", @raw, $backend_name, "Base"; # Package name
    require $location;
    $self->{_my_backend} = $backend_class->new({
        config => $self->_config,
        logger => Koha::Illrequest::Logger->new
    });
    return $self;
}


=head3 _backend

    my $backend = $abstract->_backend($new_backend);
    my $backend = $abstract->_backend;

Getter/Setter for our API object.

=cut

sub _backend {
    my ( $self, $backend ) = @_;
    $self->{_my_backend} = $backend if ( $backend );
    # Dynamically load our backend object, as late as possible.
    $self->load_backend unless ( $self->{_my_backend} );
    return $self->{_my_backend};
}

=head3 _backend_capability

    my $backend_capability_result = $self->_backend_capability($name, $args);

This is a helper method to invoke optional capabilities in the backend.  If
the capability named by $name is not supported, return 0, else invoke it,
passing $args along with the invocation, and return its return value.

NOTE: this module suffers from a confusion in termninology:

in _backend_capability, the notion of capability refers to an optional feature
that is implemented in core, but might not be supported by a given backend.

in capabilities & custom_capability, capability refers to entries in the
status_graph (after union between backend and core).

The easiest way to fix this would be to fix the terminology in
capabilities & custom_capability and their callers.

=cut

sub _backend_capability {
    my ( $self, $name, $args ) = @_;
    my $capability = 0;
    # See if capability is defined in backend
    try {
        $capability = $self->_backend->capabilities($name);
    } catch {
        warn $_;
        return 0;
    };
    # Try to invoke it
    if ( $capability && ref($capability) eq 'CODE' ) {
        return &{$capability}($args);
    } else {
        return 0;
    }
}

=head3 _config

    my $config = $abstract->_config($config);
    my $config = $abstract->_config;

Getter/Setter for our config object.

=cut

sub _config {
    my ( $self, $config ) = @_;
    $self->{_my_config} = $config if ( $config );
    # Load our config object, as late as possible.
    unless ( $self->{_my_config} ) {
        $self->{_my_config} = Koha::Illrequest::Config->new;
    }
    return $self->{_my_config};
}

=head3 metadata

=cut

sub metadata {
    my ( $self ) = @_;
    return $self->_backend->metadata($self);
}

=head3 _core_status_graph

    my $core_status_graph = $illrequest->_core_status_graph;

Returns ILL module's default status graph.  A status graph defines the list of
available actions at any stage in the ILL workflow.  This is for instance used
by the perl script & template to generate the correct buttons to display to
the end user at any given point.

=cut

sub _core_status_graph {
    my ( $self ) = @_;
    return {
        NEW => {
            prev_actions => [ ],                           # Actions containing buttons
                                                           # leading to this status
            id             => 'NEW',                       # ID of this status
            name           => 'New request',               # UI name of this status
            ui_method_name => 'New request',               # UI name of method leading
                                                           # to this status
            method         => 'create',                    # method to this status
            next_actions   => [ 'REQ', 'GENREQ', 'KILL' ], # buttons to add to all
                                                           # requests with this status
            ui_method_icon => 'fa-plus',                   # UI Style class
        },
        REQ => {
            prev_actions   => [ 'NEW', 'REQREV', 'QUEUED', 'CANCREQ' ],
            id             => 'REQ',
            name           => 'Requested',
            ui_method_name => 'Confirm request',
            method         => 'confirm',
            next_actions   => [ 'REQREV', 'COMP', 'CHK' ],
            ui_method_icon => 'fa-check',
        },
        GENREQ => {
            prev_actions   => [ 'NEW', 'REQREV' ],
            id             => 'GENREQ',
            name           => 'Requested from partners',
            ui_method_name => 'Place request with partners',
            method         => 'generic_confirm',
            next_actions   => [ 'COMP', 'CHK', 'REQREV' ],
            ui_method_icon => 'fa-paper-plane',
        },
        REQREV => {
            prev_actions   => [ 'REQ', 'GENREQ' ],
            id             => 'REQREV',
            name           => 'Request reverted',
            ui_method_name => 'Revert request',
            method         => 'cancel',
            next_actions   => [ 'REQ', 'GENREQ', 'KILL' ],
            ui_method_icon => 'fa-times',
        },
        QUEUED => {
            prev_actions   => [ ],
            id             => 'QUEUED',
            name           => 'Queued request',
            ui_method_name => 0,
            method         => 0,
            next_actions   => [ 'REQ', 'KILL' ],
            ui_method_icon => 0,
        },
        CANCREQ => {
            prev_actions   => [ 'NEW' ],
            id             => 'CANCREQ',
            name           => 'Cancellation requested',
            ui_method_name => 0,
            method         => 0,
            next_actions   => [ 'KILL', 'REQ' ],
            ui_method_icon => 0,
        },
        COMP => {
            prev_actions   => [ 'REQ' ],
            id             => 'COMP',
            name           => 'Completed',
            ui_method_name => 'Mark completed',
            method         => 'mark_completed',
            next_actions   => [ 'CHK' ],
            ui_method_icon => 'fa-check',
        },
        KILL => {
            prev_actions   => [ 'QUEUED', 'REQREV', 'NEW', 'CANCREQ' ],
            id             => 'KILL',
            name           => 0,
            ui_method_name => 'Delete request',
            method         => 'delete',
            next_actions   => [ ],
            ui_method_icon => 'fa-trash',
        },
        CHK => {
            prev_actions   => [ 'REQ', 'GENREQ', 'COMP' ],
            id             => 'CHK',
            name           => 'Checked out',
            ui_method_name => 'Check out',
            needs_prefs    => [ 'CirculateILL' ],
            needs_perms    => [ 'user_circulate_circulate_remaining_permissions' ],
            # An array of functions that all must return true
            needs_all      => [ sub { my $r = shift;  return $r->biblio; } ],
            method         => 'check_out',
            next_actions   => [ ],
            ui_method_icon => 'fa-upload',
        },
        RET => {
            prev_actions   => [ 'CHK' ],
            id             => 'RET',
            name           => 'Returned to library',
            ui_method_name => 'Check in',
            method         => 'check_in',
            next_actions   => [ 'COMP' ],
            ui_method_icon => 'fa-download',
        }
    };
}

=head3 _status_graph_union

    my $status_graph = $illrequest->_status_graph_union($origin, $new_graph);

Return a new status_graph, the result of merging $origin & new_graph.  This is
operation is a union over the sets defied by the two graphs.

Each entry in $new_graph is added to $origin.  We do not provide a syntax for
'subtraction' of entries from $origin.

Whilst it is not intended that this works, you can override entries in $origin
with entries with the same key in $new_graph.  This can lead to problematic
behaviour when $new_graph adds an entry, which modifies a dependent entry in
$origin, only for the entry in $origin to be replaced later with a new entry
from $new_graph.

NOTE: this procedure does not "re-link" entries in $origin or $new_graph,
i.e. each of the graphs need to be correct at the outset of the operation.

=cut

sub _status_graph_union {
    my ( $self, $core_status_graph, $backend_status_graph ) = @_;
    # Create new status graph with:
    # - all core_status_graph
    # - for-each each backend_status_graph
    #   + add to new status graph
    #   + for each core prev_action:
    #     * locate core_status
    #     * update next_actions with additional next action.
    #   + for each core next_action:
    #     * locate core_status
    #     * update prev_actions with additional prev action

    my @core_status_ids = keys %{$core_status_graph};
    my $status_graph = clone($core_status_graph);

    foreach my $backend_status_key ( keys %{$backend_status_graph} ) {
        my $backend_status = $backend_status_graph->{$backend_status_key};
        # Add to new status graph
        $status_graph->{$backend_status_key} = $backend_status;
        # Update all core methods' next_actions.
        foreach my $prev_action ( @{$backend_status->{prev_actions}} ) {
            if ( grep { $prev_action eq $_ } @core_status_ids ) {
                my @next_actions =
                     @{$status_graph->{$prev_action}->{next_actions}};
                push @next_actions, $backend_status_key
                    if (!grep(/^$backend_status_key$/, @next_actions));
                $status_graph->{$prev_action}->{next_actions}
                    = \@next_actions;
            }
        }
        # Update all core methods' prev_actions
        foreach my $next_action ( @{$backend_status->{next_actions}} ) {
            if ( grep { $next_action eq $_ } @core_status_ids ) {
                my @prev_actions =
                     @{$status_graph->{$next_action}->{prev_actions}};
                push @prev_actions, $backend_status_key
                    if (!grep(/^$backend_status_key$/, @prev_actions));
                $status_graph->{$next_action}->{prev_actions}
                    = \@prev_actions;
            }
        }
    }

    return $status_graph;
}

### Core API methods

=head3 capabilities

    my $capabilities = $illrequest->capabilities;

Return a hashref mapping methods to operation names supported by the queried
backend.

Example return value:

    { create => "Create Request", confirm => "Progress Request" }

NOTE: this module suffers from a confusion in termninology:

in _backend_capability, the notion of capability refers to an optional feature
that is implemented in core, but might not be supported by a given backend.

in capabilities & custom_capability, capability refers to entries in the
status_graph (after union between backend and core).

The easiest way to fix this would be to fix the terminology in
capabilities & custom_capability and their callers.

=cut

sub capabilities {
    my ( $self, $status ) = @_;
    # Generate up to date status_graph
    my $status_graph = $self->_status_graph_union(
        $self->_core_status_graph,
        $self->_backend->status_graph({
            request => $self,
            other   => {}
        })
    );
    # Extract available actions from graph.
    return $status_graph->{$status} if $status;
    # Or return entire graph.
    return $status_graph;
}

=head3 custom_capability

Return the result of invoking $CANDIDATE on this request's backend with
$PARAMS, or 0 if $CANDIDATE is an unknown method on backend.

NOTE: this module suffers from a confusion in termninology:

in _backend_capability, the notion of capability refers to an optional feature
that is implemented in core, but might not be supported by a given backend.

in capabilities & custom_capability, capability refers to entries in the
status_graph (after union between backend and core).

The easiest way to fix this would be to fix the terminology in
capabilities & custom_capability and their callers.

=cut

sub custom_capability {
    my ( $self, $candidate, $params ) = @_;
    foreach my $capability ( values %{$self->capabilities} ) {
        if ( $candidate eq $capability->{method} ) {
            my $response =
                $self->_backend->$candidate({
                    request    => $self,
                    other      => $params,
                });
            return $self->expandTemplate($response);
        }
    }
    return 0;
}

=head3 available_backends

Return a list of available backends.

=cut

sub available_backends {
    my ( $self, $reduced ) = @_;
    my $backends = $self->_config->available_backends($reduced);
    return $backends;
}

=head3 available_actions

Return a list of available actions.

=cut

sub available_actions {
    my ( $self ) = @_;
    my $current_action = $self->capabilities($self->status);
    my @available_actions = map { $self->capabilities($_) }
        @{$current_action->{next_actions}};
    return \@available_actions;
}

=head3 mark_completed

Mark a request as completed (status = COMP).

=cut

sub mark_completed {
    my ( $self ) = @_;
    $self->status('COMP')->store;
    $self->completed(dt_from_string())->store;
    return {
        error   => 0,
        status  => '',
        message => '',
        method  => 'mark_completed',
        stage   => 'commit',
        next    => 'illview',
    };
}

=head2 backend_illview

View and manage an ILL request

=cut

sub backend_illview {
    my ( $self, $params ) = @_;

    my $response = $self->_backend_capability('illview',{
        request    => $self,
        other      => $params,
    });
    return $self->expandTemplate($response) if $response;
    return $response;
}

=head2 backend_migrate

Migrate a request from one backend to another.

=cut

sub backend_migrate {
    my ( $self, $params ) = @_;
    # Set the request's backend to be the destination backend
    $self->load_backend($params->{backend});
    my $response = $self->_backend_capability('migrate',{
            request    => $self,
            other      => $params,
        });
    return $self->expandTemplate($response) if $response;
    return $response;
}

=head2 backend_confirm

Confirm a request. The backend handles setting of mandatory fields in the commit stage:

=over

=item * orderid

=item * accessurl, cost (if available).

=back

=cut

sub backend_confirm {
    my ( $self, $params ) = @_;

    my $response = $self->_backend->confirm({
            request    => $self,
            other      => $params,
        });
    return $self->expandTemplate($response);
}

=head3 backend_update_status

=cut

sub backend_update_status {
    my ( $self, $params ) = @_;
    return $self->expandTemplate($self->_backend->update_status($params));
}

=head3 backend_cancel

    my $ILLResponse = $illRequest->backend_cancel;

The standard interface method allowing for request cancellation.

=cut

sub backend_cancel {
    my ( $self, $params ) = @_;

    my $result = $self->_backend->cancel({
        request => $self,
        other => $params
    });

    return $self->expandTemplate($result);
}

=head3 backend_renew

    my $renew_response = $illRequest->backend_renew;

The standard interface method allowing for request renewal queries.

=cut

sub backend_renew {
    my ( $self ) = @_;
    return $self->expandTemplate(
        $self->_backend->renew({
            request    => $self,
        })
    );
}

=head3 backend_create

    my $create_response = $abstractILL->backend_create($params);

Return an array of Record objects created by querying our backend with
a Search query.

In the context of the other ILL methods, this is a special method: we only
pass it $params, as it does not yet have any other data associated with it.

=cut

sub backend_create {
    my ( $self, $params ) = @_;

    # Establish whether we need to do a generic copyright clearance.
    if ($params->{opac}) {
        if ( ( !$params->{stage} || $params->{stage} eq 'init' )
                && C4::Context->preference("ILLModuleCopyrightClearance") ) {
            return {
                error   => 0,
                status  => '',
                message => '',
                method  => 'create',
                stage   => 'copyrightclearance',
                value   => {
                    other   => $params,
                    backend => $self->_backend->name
                }
            };
        } elsif (     defined $params->{stage}
                && $params->{stage} eq 'copyrightclearance' ) {
            $params->{stage} = 'init';
        }
    }
    # First perform API action, then...
    my $args = {
        request => $self,
        other   => $params,
    };
    my $result = $self->_backend->create($args);

    # ... simple case: we're not at 'commit' stage.
    my $stage = $result->{stage};
    return $self->expandTemplate($result)
        unless ( 'commit' eq $stage );

    # ... complex case: commit!

    # Do we still have space for an ILL or should we queue?
    my $permitted = $self->check_limits(
        { patron => $self->patron }, { librarycode => $self->branchcode }
    );

    # Now augment our committed request.

    $result->{permitted} = $permitted;             # Queue request?

    # This involves...

    # ...Updating status!
    $self->status('QUEUED')->store unless ( $permitted );

    ## Handle Unmediated ILLs

    # For the unmediated workflow we only need to delegate to our backend. If
    # that backend supports unmediateld_ill, it will do its thing and return a
    # proper response.  If it doesn't then _backend_capability returns 0, so
    # we keep the current result.
    if ( C4::Context->preference("ILLModuleUnmediated") && $permitted ) {
        my $unmediated_result = $self->_backend_capability(
            'unmediated_ill',
            $args
        );
        $result = $unmediated_result if $unmediated_result;
    }

    return $self->expandTemplate($result);
}

=head3 backend_get_update

    my $update = backend_get_update($request);

    Given a request, returns an update in a prescribed
    format that can then be passed to update parsers

=cut

sub backend_get_update {
    my ( $self, $options ) = @_;

    my $response = $self->_backend_capability(
        'get_supplier_update',
        {
            request => $self,
            %{$options}
        }
    );
    return $response;
}

=head3 expandTemplate

    my $params = $abstract->expandTemplate($params);

Return a version of $PARAMS augmented with our required template path.

=cut

sub expandTemplate {
    my ( $self, $params ) = @_;
    my $backend = $self->_backend->name;
    # Generate path to file to load
    my $backend_dir = $self->_config->backend_dir;
    my $backend_tmpl = join "/", $backend_dir, $backend;
    my $intra_tmpl =  join "/", $backend_tmpl, "intra-includes",
        ( $params->{method}//q{} ) . ".inc";
    my $opac_tmpl =  join "/", $backend_tmpl, "opac-includes",
        ( $params->{method}//q{} ) . ".inc";
    # Set files to load
    $params->{template} = $intra_tmpl;
    $params->{opac_template} = $opac_tmpl;
    return $params;
}

#### Abstract Imports

=head3 getLimits

    my $limit_rules = $abstract->getLimits( {
        type  => 'brw_cat' | 'branch',
        value => $value
    } );

Return the ILL limit rules for the supplied combination of type / value.

As the config may have no rules for this particular type / value combination,
or for the default, we must define fall-back values here.

=cut

sub getLimits {
    my ( $self, $params ) = @_;
    my $limits = $self->_config->getLimitRules($params->{type});

    if (     defined $params->{value}
          && defined $limits->{$params->{value}} ) {
            return $limits->{$params->{value}};
    }
    else {
        return $limits->{default} || { count => -1, method => 'active' };
    }
}

=head3 getPrefix

    my $prefix = $abstract->getPrefix( {
        branch  => $branch_code
    } );

Return the ILL prefix as defined by our $params: either per borrower category,
per branch or the default.

=cut

sub getPrefix {
    my ( $self, $params ) = @_;
    my $brn_prefixes = $self->_config->getPrefixes();
    return $brn_prefixes->{$params->{branch}} || ""; # "the empty prefix"
}

=head3 get_type

    my $type = $abstract->get_type();

Return a string representing the material type of this request or undef

=cut

sub get_type {
    my ($self) = @_;
    my $attr = $self->illrequestattributes->find({ type => 'type'});
    return if !$attr;
    return $attr->value;
};

#### Illrequests Imports

=head3 check_limits

    my $ok = $illRequests->check_limits( {
        borrower   => $borrower,
        branchcode => 'branchcode' | undef,
    } );

Given $PARAMS, a hashref containing a $borrower object and a $branchcode,
see whether we are still able to place ILLs.

LimitRules are derived from koha-conf.xml:
 + default limit counts, and counting method
 + branch specific limit counts & counting method
 + borrower category specific limit counts & counting method
 + err on the side of caution: a counting fail will cause fail, even if
   the other counts passes.

=cut

sub check_limits {
    my ( $self, $params ) = @_;
    my $patron     = $params->{patron};
    my $branchcode = $params->{librarycode} || $patron->branchcode;

    # Establish maximum number of allowed requests
    my ( $branch_rules, $brw_rules ) = (
        $self->getLimits( {
            type => 'branch',
            value => $branchcode
        } ),
        $self->getLimits( {
            type => 'brw_cat',
            value => $patron->categorycode,
        } ),
    );
    my ( $branch_limit, $brw_limit )
        = ( $branch_rules->{count}, $brw_rules->{count} );
    # Establish currently existing requests
    my ( $branch_count, $brw_count ) = (
        $self->_limit_counter(
            $branch_rules->{method}, { branchcode => $branchcode }
        ),
        $self->_limit_counter(
            $brw_rules->{method}, { borrowernumber => $patron->borrowernumber }
        ),
    );

    # Compare and return
    # A limit of -1 means no limit exists.
    # We return blocked if either branch limit or brw limit is reached.
    if ( ( $branch_limit != -1 && $branch_limit <= $branch_count )
             || ( $brw_limit != -1 && $brw_limit <= $brw_count ) ) {
        return 0;
    } else {
        return 1;
    }
}

sub _limit_counter {
    my ( $self, $method, $target ) = @_;

    # Establish parameters of counts
    my $resultset;
    if ($method && $method eq 'annual') {
        $resultset = Koha::Illrequests->search({
            -and => [
                %{$target},
                \"YEAR(placed) = YEAR(NOW())"
            ]
        });
    } else {                    # assume 'active'
        # XXX: This status list is ugly. There should be a method in config
        # to return these.
        my $where = { status => { -not_in => [ 'QUEUED', 'COMP' ] } };
        $resultset = Koha::Illrequests->search({ %{$target}, %{$where} });
    }

    # Fetch counts
    return $resultset->count;
}

=head3 requires_moderation

    my $status = $illRequest->requires_moderation;

Return the name of the status if moderation by staff is required; or 0
otherwise.

=cut

sub requires_moderation {
    my ( $self ) = @_;
    my $require_moderation = {
        'CANCREQ' => 'CANCREQ',
    };
    return $require_moderation->{$self->status};
}

=head3 biblio

    my $biblio = $request->biblio;

For a given request, return the biblio associated with it,
or undef if none exists

=cut

sub biblio {
    my ( $self ) = @_;
    my $biblio_rs = $self->_result->biblio;
    return unless $biblio_rs;
    return Koha::Biblio->_new_from_dbic($biblio_rs);
}

=head3 check_out

    my $stage_summary = $request->check_out;

Handle the check_out method. The first stage involves gathering the required
data from the user via a form, the second stage creates an item and tries to
issue it to the patron. If successful, it notifies the patron, then it
returns a summary of how things went

=cut

sub check_out {
    my ( $self, $params ) = @_;

    # Objects required by the template
    my $itemtypes = Koha::ItemTypes->search(
        {},
        { order_by => ['description'] }
    );
    my $libraries = Koha::Libraries->search(
        {},
        { order_by => ['branchcode'] }
    );
    my $biblio = $self->biblio;

    # Find all statistical patrons
    my $statistical_patrons = Koha::Patrons->search(
        { 'category_type' => 'x' },
        { join => { 'categorycode' => 'borrowers' } }
    );

    if (!$params->{stage} || $params->{stage} eq 'init') {
        # Present a form to gather the required data
        #
        # We may be viewing this page having previously tried to issue
        # the item (in which case, we may already have created an item)
        # so we pass the biblio for this request
        return {
            method  => 'check_out',
            stage   => 'form',
            value   => {
                itemtypes   => $itemtypes,
                libraries   => $libraries,
                statistical => $statistical_patrons,
                biblio      => $biblio
            }
        };
    } elsif ($params->{stage} eq 'form') {
        # Validate what we've got and return with an error if we fail
        my $errors = {};
        if (!$params->{item_type} || length $params->{item_type} == 0) {
            $errors->{item_type} = 1;
        }
        if ($params->{inhouse} && length $params->{inhouse} > 0) {
            my $patron_count = Koha::Patrons->search({
                cardnumber => $params->{inhouse}
            })->count();
            if ($patron_count != 1) {
                $errors->{inhouse} = 1;
            }
        }

        # Check we don't have more than one item for this bib,
        # if we do, something very odd is going on
        # Having 1 is OK, it means we're likely trying to issue
        # following a previously failed attempt, the item exists
        # so we'll use it
        my @items = $biblio->items->as_list;
        my $item_count = scalar @items;
        if ($item_count > 1) {
            $errors->{itemcount} = 1;
        }

        # Failed validation, go back to the form
        if (%{$errors}) {
            return {
                method  => 'check_out',
                stage   => 'form',
                value   => {
                    params      => $params,
                    statistical => $statistical_patrons,
                    itemtypes   => $itemtypes,
                    libraries   => $libraries,
                    biblio      => $biblio,
                    errors      => $errors
                }
            };
        }

        # Passed validation
        #
        # Create an item if one doesn't already exist,
        # if one does, use that
        my $itemnumber;
        if ($item_count == 0) {
            my $item_hash = {
                biblionumber  => $self->biblio_id,
                homebranch    => $params->{branchcode},
                holdingbranch => $params->{branchcode},
                location      => $params->{branchcode},
                itype         => $params->{item_type},
                barcode       => 'ILL-' . $self->illrequest_id
            };
            try {
                my $item = Koha::Item->new($item_hash)->store;
                $itemnumber = $item->itemnumber;
            };
        } else {
            $itemnumber = $items[0]->itemnumber;
        }
        # Check we have an item before going forward
        if (!$itemnumber) {
            return {
                method  => 'check_out',
                stage   => 'form',
                value   => {
                    params      => $params,
                    itemtypes   => $itemtypes,
                    libraries   => $libraries,
                    statistical => $statistical_patrons,
                    errors      => { item_creation => 1 }
                }
            };
        }

        # Do the check out
        #
        # Gather what we need
        my $target_item = Koha::Items->find( $itemnumber );
        # Determine who we're issuing to
        my $patron = $params->{inhouse} && length $params->{inhouse} > 0 ?
            Koha::Patrons->find({ cardnumber => $params->{inhouse} }) :
            $self->patron;

        my @issue_args = (
            $patron,
            scalar $target_item->barcode
        );
        if ($params->{duedate} && length $params->{duedate} > 0) {
            push @issue_args, dt_from_string($params->{duedate});
        }
        # Check if we can check out
        my ( $error, $confirm, $alerts, $messages ) =
            C4::Circulation::CanBookBeIssued(@issue_args);

        # If we got anything back saying we can't check out,
        # return it to the template
        my $problems = {};
        if ( $error && %{$error} ) { $problems->{error} = $error };
        if ( $confirm && %{$confirm} ) { $problems->{confirm} = $confirm };
        if ( $alerts && %{$alerts} ) { $problems->{alerts} = $alerts };
        if ( $messages && %{$messages} ) { $problems->{messages} = $messages };

        if (%{$problems}) {
            return {
                method  => 'check_out',
                stage   => 'form',
                value   => {
                    params           => $params,
                    itemtypes        => $itemtypes,
                    libraries        => $libraries,
                    statistical      => $statistical_patrons,
                    patron           => $patron,
                    biblio           => $biblio,
                    check_out_errors => $problems
                }
            };
        }

        # We can allegedly check out, so make it so
        my $issue = C4::Circulation::AddIssue(@issue_args);

        if ($issue) {
            # Update the request status
            $self->status('CHK')->store;
            return {
                method  => 'check_out',
                stage   => 'done_check_out',
                value   => {
                    params    => $params,
                    patron    => $patron,
                    check_out => $issue
                }
            };
        } else {
            return {
                method  => 'check_out',
                stage   => 'form',
                value   => {
                    params    => $params,
                    itemtypes => $itemtypes,
                    libraries => $libraries,
                    errors    => { item_check_out => 1 }
                }
            };
        }
    }

}

=head3 generic_confirm

    my $stage_summary = $illRequest->generic_confirm;

Handle the generic_confirm extended method.  The first stage involves creating
a template email for the end user to edit in the browser.  The second stage
attempts to submit the email.

=cut

sub generic_confirm {
    my ( $self, $params ) = @_;
    my $branch = Koha::Libraries->find($params->{current_branchcode})
        || die "Invalid current branchcode. Are you logged in as the database user?";
    if ( !$params->{stage}|| $params->{stage} eq 'init' ) {
        # Get the message body from the notice definition
        my $letter = $self->get_notice({
            notice_code => 'ILL_PARTNER_REQ',
            transport   => 'email'
        });

        my $partners = Koha::Patrons->search({
            categorycode => $self->_config->partner_code
        });
        return {
            error   => 0,
            status  => '',
            message => '',
            method  => 'generic_confirm',
            stage   => 'draft',
            value   => {
                draft => {
                    subject => $letter->{title},
                    body    => $letter->{content}
                },
                partners => $partners,
            }
        };

    } elsif ( 'draft' eq $params->{stage} ) {
        # Create the to header
        my $to = $params->{partners};
        if ( defined $to ) {
            $to =~ s/^\x00//;       # Strip leading NULLs
        }
        Koha::Exceptions::Ill::NoTargetEmail->throw(
            "No target email addresses found. Either select at least one partner or check your ILL partner library records.")
          if ( !$to );

        # Take the null delimited string that we receive and create
        # an array of associated patron objects
        my @to_patrons = map {
            Koha::Patrons->find({ borrowernumber => $_ })
        } split(/\x00/, $to);

        # Create the from, replyto and sender headers
        my $from = $branch->from_email_address;
        my $replyto = $branch->inbound_ill_address;
        Koha::Exceptions::Ill::NoLibraryEmail->throw(
            "Your library has no usable email address. Please set it.")
          if ( !$from );

        # So we get a notice hashref, then substitute the possibly
        # modified title and body from the draft stage
        my $letter = $self->get_notice({
            notice_code => 'ILL_PARTNER_REQ',
            transport   => 'email'
        });
        $letter->{title} = $params->{subject};
        $letter->{content} = $params->{body};

        if ($letter) {

            # Keep track of who received this notice
            my @queued = ();
            # Iterate our array of recipient patron objects
            foreach my $patron(@to_patrons) {
                # Create the params we pass to the notice
                my $params = {
                    letter                 => $letter,
                    borrowernumber         => $patron->borrowernumber,
                    message_transport_type => 'email',
                    to_address             => $patron->email,
                    from_address           => $from,
                    reply_address          => $replyto
                };
                my $result = C4::Letters::EnqueueLetter($params);
                if ( $result ) {
                    push @queued, $patron->email;
                }
            }

            # If all notices were queued successfully,
            # store that
            if (scalar @queued == scalar @to_patrons) {
                $self->status("GENREQ")->store;
                $self->_backend_capability(
                    'set_requested_partners',
                    {
                        request => $self,
                        to => join("; ", @queued)
                    }
                );
                return {
                    error   => 0,
                    status  => '',
                    message => '',
                    method  => 'generic_confirm',
                    stage   => 'commit',
                    next    => 'illview',
                };
            }

        }
        return {
            error   => 1,
            status  => 'email_failed',
            message => 'Email queueing failed',
            method  => 'generic_confirm',
            stage   => 'draft',
        };
    } else {
        die "Unknown stage, should not have happened."
    }
}

=head3 send_patron_notice

    my $result = $request->send_patron_notice($notice_code);

Send a specified notice regarding this request to a patron

=cut

sub send_patron_notice {
    my ( $self, $notice_code, $additional_text ) = @_;

    # We need a notice code
    if (!$notice_code) {
        return {
            error => 'notice_no_type'
        };
    }

    # Map from the notice code to the messaging preference
    my %message_name = (
        ILL_PICKUP_READY    => 'Ill_ready',
        ILL_REQUEST_UNAVAIL => 'Ill_unavailable',
        ILL_REQUEST_UPDATE  => 'Ill_update'
    );

    # Get the patron's messaging preferences
    my $borrower_preferences = C4::Members::Messaging::GetMessagingPreferences({
        borrowernumber => $self->borrowernumber,
        message_name   => $message_name{$notice_code}
    });
    my @transports = keys %{ $borrower_preferences->{transports} };

    # Notice should come from the library where the request was placed,
    # not the patrons home library
    my $branch = Koha::Libraries->find($self->branchcode);
    my $from_address = $branch->from_email_address;
    my $reply_address = $branch->inbound_ill_address;

    # Send the notice to the patron via the chosen transport methods
    # and record the results
    my @success = ();
    my @fail = ();
    for my $transport (@transports) {
        my $letter = $self->get_notice({
            notice_code     => $notice_code,
            transport       => $transport,
            additional_text => $additional_text
        });
        if ($letter) {
            my $result = C4::Letters::EnqueueLetter({
                letter                 => $letter,
                borrowernumber         => $self->borrowernumber,
                message_transport_type => $transport,
                from_address           => $from_address,
                reply_address          => $reply_address
            });
            if ($result) {
                push @success, $transport;
            } else {
                push @fail, $transport;
            }
        } else {
            push @fail, $transport;
        }
    }
    if (scalar @success > 0) {
        my $logger = Koha::Illrequest::Logger->new;
        $logger->log_patron_notice({
            request => $self,
            notice_code => $notice_code
        });
    }
    return {
        result => {
            success => \@success,
            fail    => \@fail
        }
    };
}

=head3 send_staff_notice

    my $result = $request->send_staff_notice($notice_code);

Send a specified notice regarding this request to staff

=cut

sub send_staff_notice {
    my ( $self, $notice_code ) = @_;

    # We need a notice code
    if (!$notice_code) {
        return {
            error => 'notice_no_type'
        };
    }

    # Get the staff notices that have been assigned for sending in
    # the syspref
    my $staff_to_send = C4::Context->preference('ILLSendStaffNotices') // q{};

    # If it hasn't been enabled in the syspref, we don't want to send it
    if ($staff_to_send !~ /\b$notice_code\b/) {
        return {
            error => 'notice_not_enabled'
        };
    }

    my $letter = $self->get_notice({
        notice_code => $notice_code,
        transport   => 'email'
    });

    # Try and get an address to which to send staff notices
    my $branch = Koha::Libraries->find($self->branchcode);
    my $to_address = $branch->inbound_ill_address;
    my $from_address = $branch->inbound_ill_address;

    my $params = {
        letter                 => $letter,
        borrowernumber         => $self->borrowernumber,
        message_transport_type => 'email',
        from_address           => $from_address
    };

    if ($to_address) {
        $params->{to_address} = $to_address;
    } else {
        return {
            error => 'notice_no_create'
        };
    }

    if ($letter) {
        C4::Letters::EnqueueLetter($params)
            or warn "can't enqueue letter $letter";
        return {
            success => 'notice_queued'
        };
    } else {
        return {
            error => 'notice_no_create'
        };
    }
}

=head3 get_notice

    my $notice = $request->get_notice($params);

Return a compiled notice hashref for the passed notice code
and transport type

=cut

sub get_notice {
    my ( $self, $params ) = @_;

    my $title = $self->illrequestattributes->find(
        { type => 'title' }
    );
    my $author = $self->illrequestattributes->find(
        { type => 'author' }
    );
    my $metahash = $self->metadata;
    my @metaarray = ();
    foreach my $key (sort { lc $a cmp lc $b } keys %{$metahash}) {
        my $value = $metahash->{$key};
        push @metaarray, "- $key: $value" if $value;
    }
    my $metastring = join("\n", @metaarray);

    my $illrequestattributes = {
        map { $_->type => $_->value } $self->illrequestattributes->as_list
    };

    my $letter = C4::Letters::GetPreparedLetter(
        module                 => 'ill',
        letter_code            => $params->{notice_code},
        branchcode             => $self->branchcode,
        message_transport_type => $params->{transport},
        lang                   => $self->patron->lang,
        tables                 => {
            illrequests => $self->illrequest_id,
            borrowers   => $self->borrowernumber,
            biblio      => $self->biblio_id,
            branches    => $self->branchcode,
        },
        substitute  => {
            ill_bib_title      => $title ? $title->value : '',
            ill_bib_author     => $author ? $author->value : '',
            ill_full_metadata  => $metastring,
            additional_text    => $params->{additional_text},
            illrequestattributes => $illrequestattributes,
        }
    );

    return $letter;
}


=head3 attach_processors

Receive a Koha::Illrequest::SupplierUpdate and attach
any processors we have for it

=cut

sub attach_processors {
    my ( $self, $update ) = @_;

    foreach my $processor(@{$self->{processors}}) {
        if (
            $processor->{target_source_type} eq $update->{source_type} &&
            $processor->{target_source_name} eq $update->{source_name}
        ) {
            $update->attach_processor($processor);
        }
    }
}

=head3 append_to_note

    append_to_note("Some text");

Append some text to the staff note

=cut

sub append_to_note {
    my ($self, $text) = @_;
    my $current = $self->notesstaff;
    $text = ($current && length $current > 0) ? "$current\n\n$text" : $text;
    $self->notesstaff($text)->store;
}

=head3 id_prefix

    my $prefix = $record->id_prefix;

Return the prefix appropriate for the current Illrequest as derived from the
borrower and branch associated with this request's Status, and the config
file.

=cut

sub id_prefix {
    my ( $self ) = @_;
    my $prefix = $self->getPrefix( {
        branch  => $self->branchcode,
    } );
    $prefix .= "-" if ( $prefix );
    return $prefix;
}

=head3 _censor

    my $params = $illRequest->_censor($params);

Return $params, modified to reflect our censorship requirements.

=cut

sub _censor {
    my ( $self, $params ) = @_;
    my $censorship = $self->_config->censorship;
    $params->{censor_notes_staff} = $censorship->{censor_notes_staff}
        if ( $params->{opac} );
    $params->{display_reply_date} = ( $censorship->{censor_reply_date} ) ? 0 : 1;

    return $params;
}

=head3 store

    $Illrequest->store;

Overloaded I<store> method that, in addition to performing the 'store',
possibly records the fact that something happened

=cut

sub store {
    my ( $self, $attrs ) = @_;

    my %updated_columns = $self->_result->get_dirty_columns;

    my @holds;
    if( $self->in_storage and defined $updated_columns{'borrowernumber'} and
        Koha::Patrons->find( $updated_columns{'borrowernumber'} ) )
    {
        # borrowernumber has changed
        my $old_illreq = $self->get_from_storage;
        @holds = Koha::Holds->search( {
            borrowernumber => $old_illreq->borrowernumber,
            biblionumber   => $self->biblio_id,
        } )->as_list if $old_illreq;
    }

    my $ret = $self->SUPER::store;

    if ( scalar @holds ) {
        # move holds to the changed borrowernumber
        foreach my $hold ( @holds ) {
            $hold->borrowernumber( $updated_columns{'borrowernumber'} )->store;
        }
    }

    $attrs->{log_origin} = 'core';

    if ($ret && defined $attrs) {
        my $logger = Koha::Illrequest::Logger->new;
        $logger->log_maybe({
            request => $self,
            attrs   => $attrs
        });
    }

    return $ret;
}

=head3 requested_partners

    my $partners_string = $illRequest->requested_partners;

Return the string representing the email addresses of the partners to
whom a request has been sent

=cut

sub requested_partners {
    my ( $self ) = @_;
    return $self->_backend_capability(
        'get_requested_partners',
        { request => $self }
    );
}

=head3 TO_JSON

    $json = $illrequest->TO_JSON

Overloaded I<TO_JSON> method that takes care of inserting calculated values
into the unblessed representation of the object.

TODO: This method does nothing and is not called anywhere. However, bug 74325
touches it, so keeping this for now until both this and bug 74325 are merged,
at which point we can sort it out and remove it completely

=cut

sub TO_JSON {
    my ( $self, $embed ) = @_;

    my $object = $self->SUPER::TO_JSON();

    return $object;
}

=head2 Internal methods

=head3 to_api_mapping

=cut

sub to_api_mapping {
    return {
        accessurl         => 'access_url',
        batch_id          => 'ill_batch_id',
        backend           => 'ill_backend_id',
        borrowernumber    => 'patron_id',
        branchcode        => 'library_id',
        completed         => 'completed_date',
        deleted_biblio_id => undef,
        illrequest_id     => 'ill_request_id',
        notesopac         => 'opac_notes',
        notesstaff        => 'staff_notes',
        orderid           => 'ill_backend_request_id',
        placed            => 'requested_date',
        price_paid        => 'paid_price',
        replied           => 'replied_date',
        status_alias      => 'status_av',
        updated           => 'timestamp',
    };
}

=head3 strings_map

    my $strings = $self->string_map({ [ public => 0|1 ] });

Returns a map of column name to string representations. Extra information
is returned depending on the column characteristics as shown below.

Accepts a param hashref where the I<public> key denotes whether we want the public
or staff client strings.

Example:

    {
        status => {
            backend => 'backendName',
            str     => 'Status description',
            type    => 'ill_status',
        },
        status_alias => {
            category => 'ILL_STATUS_ALIAS,
            str      => $value, # the AV description, depending on $params->{public}
            type     => 'av',
        }
    }

=cut

sub strings_map {
    my ( $self, $params ) = @_;

    my $cache     = Koha::Cache::Memory::Lite->get_instance();
    my $cache_key = 'ill:status_graph:' . $self->backend;

    my $status_graph_union = $cache->get($cache_key);
    unless ($status_graph_union) {
        $status_graph_union = $self->capabilities;
        $cache->set( $cache_key, $status_graph_union );
    }

    my $status_string =
      ( exists $status_graph_union->{ $self->status } && defined $status_graph_union->{ $self->status }->{name} )
      ? $status_graph_union->{ $self->status }->{name}
      : $self->status;

    my $status_code =
      ( exists $status_graph_union->{ $self->status } && defined $status_graph_union->{ $self->status }->{id} )
      ? $status_graph_union->{ $self->status }->{id}
      : $self->status;

    my $strings = {
        status => {
            backend => $self->backend, # the backend identifier
            str     => $status_string, # the status description, taken from the status graph
            code    => $status_code,   # the status id, taken from the status graph
            type    => 'ill_status',   # fixed type
        }
    };

    my $status_alias = $self->statusalias;
    if ($status_alias) {
        $strings->{"status_alias"} = {
            category => 'ILL_STATUS_ALIAS',
            str      => $params->{public} ? $status_alias->lib_opac : $status_alias->lib,
            code     => $status_alias->authorised_value,
            type     => 'av',
        };
    }

    my $batch = $self->batch;
    if ($batch) {
        $strings->{"batch"} = {
            ill_batch_id => $batch->ill_batch_id,
            name => $batch->name,
            backend => $batch->backend,
            patron_id => $batch->patron_id,
            library_id => $batch->library_id,
            status_code => $batch->status_code
        };
    }

    return $strings;
}

=head3 _type

=cut

sub _type {
    return 'Illrequest';
}

=head1 AUTHOR

Alex Sassmannshausen <alex.sassmannshausen@ptfs-europe.com>
Andrew Isherwood <andrew.isherwood@ptfs-europe.com>

=cut

1;
