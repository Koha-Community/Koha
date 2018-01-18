package Koha::Illrequest;

# Copyright PTFS Europe 2016
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 51 Franklin
# Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use Clone 'clone';
use File::Basename qw( basename );
use Encode qw( encode );
use Mail::Sendmail;
use Try::Tiny;

use Koha::Database;
use Koha::Email;
use Koha::Exceptions::Ill;
use Koha::Illrequestattributes;
use Koha::Patron;

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

=head3 illrequestattributes

=cut

sub illrequestattributes {
    my ( $self ) = @_;
    return Koha::Illrequestattributes->_new_from_dbic(
        scalar $self->_result->illrequestattributes
    );
}

=head3 patron

=cut

sub patron {
    my ( $self ) = @_;
    return Koha::Patron->_new_from_dbic(
        scalar $self->_result->borrowernumber
    );
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
    $self->{_my_backend} = $backend_class->new({ config => $self->_config });
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
    try {
        $capability = $self->_backend->capabilities($name);
    } catch {
        return 0;
    };
    if ( $capability ) {
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
            next_actions   => [ 'REQREV', 'COMP' ],
            ui_method_icon => 'fa-check',
        },
        GENREQ => {
            prev_actions   => [ 'NEW', 'REQREV' ],
            id             => 'GENREQ',
            name           => 'Requested from partners',
            ui_method_name => 'Place request with partners',
            method         => 'generic_confirm',
            next_actions   => [ 'COMP' ],
            ui_method_icon => 'fa-send-o',
        },
        REQREV => {
            prev_actions   => [ 'REQ' ],
            id             => 'REQREV',
            name           => 'Request reverted',
            ui_method_name => 'Revert Request',
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
            next_actions   => [ ],
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
    };
}

=head3 _core_status_graph

    my $status_graph = $illrequest->_core_status_graph($origin, $new_graph);

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
            if ( grep $prev_action, @core_status_ids ) {
                my @next_actions =
                     @{$status_graph->{$prev_action}->{next_actions}};
                push @next_actions, $backend_status_key;
                $status_graph->{$prev_action}->{next_actions}
                    = \@next_actions;
            }
        }
        # Update all core methods' prev_actions
        foreach my $next_action ( @{$backend_status->{next_actions}} ) {
            if ( grep $next_action, @core_status_ids ) {
                my @prev_actions =
                     @{$status_graph->{$next_action}->{prev_actions}};
                push @prev_actions, $backend_status_key;
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
    my ( $self ) = @_;
    my $backends = $self->_config->available_backends;
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
    return {
        error   => 0,
        status  => '',
        message => '',
        method  => 'mark_completed',
        stage   => 'commit',
        next    => 'illview',
    };
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
    if ( ( !$params->{stage} || $params->{stage} eq 'init' )
             && C4::Context->preference("ILLModuleCopyrightClearance") ) {
        return {
            error   => 0,
            status  => '',
            message => '',
            method  => 'create',
            stage   => 'copyrightclearance',
            value   => {
                backend => $self->_backend->name
            }
        };
    } elsif (     defined $params->{stage}
               && $params->{stage} eq 'copyrightclearance' ) {
        $params->{stage} = 'init';
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

    return $self->expandTemplate($result);
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
        $params->{method} . ".inc";
    my $opac_tmpl =  join "/", $backend_tmpl, "opac-includes",
        $params->{method} . ".inc";
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
        brw_cat => $brw_cat,
        branch  => $branch_code,
    } );

Return the ILL prefix as defined by our $params: either per borrower category,
per branch or the default.

=cut

sub getPrefix {
    my ( $self, $params ) = @_;
    my $brn_prefixes = $self->_config->getPrefixes('branch');
    my $brw_prefixes = $self->_config->getPrefixes('brw_cat');

    return $brw_prefixes->{$params->{brw_cat}}
        || $brn_prefixes->{$params->{branch}}
        || $brw_prefixes->{default}
        || "";                  # "the empty prefix"
}

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
        my $draft->{subject} = "ILL Request";
        $draft->{body} = <<EOF;
Dear Sir/Madam,

    We would like to request an interlibrary loan for a title matching the
following description:

EOF

        my $details = $self->metadata;
        while (my ($title, $value) = each %{$details}) {
            $draft->{body} .= "  - " . $title . ": " . $value . "\n"
                if $value;
        }
        $draft->{body} .= <<EOF;

Please let us know if you are able to supply this to us.

Kind Regards

EOF

        my @address = map { $branch->$_ }
            qw/ branchname branchaddress1 branchaddress2 branchaddress3
                branchzip branchcity branchstate branchcountry branchphone
                branchemail /;
        my $address = "";
        foreach my $line ( @address ) {
            $address .= $line . "\n" if $line;
        }

        $draft->{body} .= $address;

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
                draft    => $draft,
                partners => $partners,
            }
        };

    } elsif ( 'draft' eq $params->{stage} ) {
        # Create the to header
        my $to = $params->{partners};
        if ( defined $to ) {
            $to =~ s/^\x00//;       # Strip leading NULLs
            $to =~ s/\x00/; /;      # Replace others with '; '
        }
        Koha::Exceptions::Ill::NoTargetEmail->throw(
            "No target email addresses found. Either select at least one partner or check your ILL partner library records.")
          if ( !$to );
        # Create the from, replyto and sender headers
        my $from = $branch->branchemail;
        my $replyto = $branch->branchreplyto || $from;
        Koha::Exceptions::Ill::NoLibraryEmail->throw(
            "Your library has no usable email address. Please set it.")
          if ( !$from );

        # Create the email
        my $message = Koha::Email->new;
        my %mail = $message->create_message_headers(
            {
                to          => $to,
                from        => $from,
                replyto     => $replyto,
                subject     => Encode::encode( "utf8", $params->{subject} ),
                message     => Encode::encode( "utf8", $params->{body} ),
                contenttype => 'text/plain',
            }
        );
        # Send it
        my $result = sendmail(%mail);
        if ( $result ) {
            $self->status("GENREQ")->store;
            return {
                error   => 0,
                status  => '',
                message => '',
                method  => 'generic_confirm',
                stage   => 'commit',
                next    => 'illview',
            };
        } else {
            return {
                error   => 1,
                status  => 'email_failed',
                message => $Mail::Sendmail::error,
                method  => 'generic_confirm',
                stage   => 'draft',
            };
        }
    } else {
        die "Unknown stage, should not have happened."
    }
}

=head3 id_prefix

    my $prefix = $record->id_prefix;

Return the prefix appropriate for the current Illrequest as derived from the
borrower and branch associated with this request's Status, and the config
file.

=cut

sub id_prefix {
    my ( $self ) = @_;
    my $brw = $self->patron;
    my $brw_cat = "dummy";
    $brw_cat = $brw->categorycode
        unless ( 'HASH' eq ref($brw) && $brw->{deleted} );
    my $prefix = $self->getPrefix( {
        brw_cat => $brw_cat,
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

=head3 TO_JSON

    $json = $illrequest->TO_JSON

Overloaded I<TO_JSON> method that takes care of inserting calculated values
into the unblessed representation of the object.

=cut

sub TO_JSON {
    my ( $self, $embed ) = @_;

    my $object = $self->SUPER::TO_JSON();
    $object->{id_prefix} = $self->id_prefix;

    if ( scalar (keys %$embed) ) {
        # Augment the request response with patron details if appropriate
        if ( $embed->{patron} ) {
            my $patron = $self->patron;
            $object->{patron} = {
                firstname  => $patron->firstname,
                surname    => $patron->surname,
                cardnumber => $patron->cardnumber
            };
        }
        # Augment the request response with metadata details if appropriate
        if ( $embed->{metadata} ) {
            $object->{metadata} = $self->metadata;
        }
        # Augment the request response with status details if appropriate
        if ( $embed->{capabilities} ) {
            $object->{capabilities} = $self->capabilities;
        }
        # Augment the request response with library details if appropriate
        if ( $embed->{library} ) {
            $object->{library} = Koha::Libraries->find(
                $self->branchcode
            )->TO_JSON;
        }
    }

    return $object;
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'Illrequest';
}

=head1 AUTHOR

Alex Sassmannshausen <alex.sassmannshausen@ptfs-europe.com>

=cut

1;
