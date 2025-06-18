package Koha::ILL::Backend::Standard;

# Copyright PTFS Europe 2023
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;
use DateTime;
use File::Basename qw( dirname );
use C4::Installer;

use Koha::DateUtils qw/ dt_from_string /;
use Koha::I18N      qw(__);
use Koha::ILL::Requests;
use Koha::ILL::Request::Attribute;
use C4::Biblio  qw( AddBiblio );
use C4::Charset qw( MarcToUTF8Record );

=head1 NAME

Koha::ILL::Backend::Standard - Koha ILL Backend: Standard

=head1 SYNOPSIS

Koha ILL implementation for the "Standard" backend .

=head1 DESCRIPTION

=head2 Overview

We will be providing the Abstract interface which requires we implement the
following methods:
- create        -> initial placement of the request for an ILL order
- confirm       -> confirm placement of the ILL order (No-op in Standard)
- cancel        -> request an already 'confirm'ed ILL order be cancelled
- status_graph  -> return a hashref of additional statuses
- name          -> return the name of this backend
- metadata      -> return mapping of fields from requestattributes

=head2 On the Standard backend

The Standard backend is a simple backend that is supposed to act as a
fallback.  It provides the end user with some mandatory fields in a form as
well as the option to enter additional fields with arbitrary names & values.

=head1 API

=head2 Class Methods

=cut

=head3 new

my $backend = Koha::ILL::Backend::Standard->new;

=cut

sub new {

    # -> instantiate the backend
    my ( $class, $other ) = @_;
    my $framework =
        defined $other->{config}->{configuration}->{raw_config}->{framework}
        ? $other->{config}->{configuration}->{raw_config}->{framework}
        : 'FA';
    my $self = { framework => $framework };
    bless( $self, $class );
    return $self;
}

=head3 name

Return the name of this backend.

=cut

sub name {
    return "Standard";
}

=head3 capabilities

    $capability = $backend->capabilities($name);

Return the sub implementing a capability selected by NAME, or 0 if that
capability is not implemented.

=cut

sub capabilities {
    my ( $self, $name ) = @_;
    my ($query) = @_;
    my $capabilities = {

        # Get the requested partner email address(es)
        get_requested_partners => sub { _get_requested_partners(@_); },

        # Set the requested partner email address(es)
        set_requested_partners => sub { _set_requested_partners(@_); },

        # Migrate
        migrate => sub { $self->migrate(@_); },

        # Return whether we can create the request
        # i.e. the create form has been submitted
        can_create_request => sub { _can_create_request(@_) },

        # This is required for compatibility
        # with Koha versions prior to bug 33716
        should_display_availability => sub { _can_create_request(@_) },

        # View and manage a request
        illview => sub { illview(@_); },

        provides_batch_requests => sub { return 1; },

        # We can create ILL requests with data passed from the API
        create_api => sub { $self->create_api(@_) },

        opac_unauthenticated_ill_requests => sub { return 1; }
    };
    return $capabilities->{$name};
}

=head3 metadata

Return a hashref containing canonical values from the key/value
illrequestattributes store. We may want to ignore certain values
that we do not consider to be metadata

=cut

sub metadata {
    my ( $self, $request ) = @_;
    my $attrs    = $request->extended_attributes;
    my $metadata = {};
    my @ignore   = (
        'requested_partners', 'type', 'type_disclaimer_value', 'type_disclaimer_date', 'unauthenticated_first_name',
        'unauthenticated_last_name', 'unauthenticated_email', 'historycheck_requests'
    );
    my $core_fields = _get_core_fields();
    while ( my $attr = $attrs->next ) {
        my $type = $attr->type;
        if ( !grep { $_ eq $type } @ignore ) {
            my $name;
            $name = $core_fields->{$type} || ucfirst($type);
            $metadata->{$name} = $attr->value;
        }
    }
    return $metadata;
}

=head3 status_graph

This backend provides no additional actions on top of the core_status_graph.

=cut

sub status_graph {
    return {
        MIG => {
            prev_actions   => [ 'NEW', 'REQ', 'GENREQ', 'REQREV', 'QUEUED', 'CANCREQ', ],
            id             => 'MIG',
            name           => __('Switched provider'),
            ui_method_name => __('Switch provider'),
            method         => 'migrate',
            next_actions   => [],
            ui_method_icon => 'fa-search',
        },
        EDITITEM => {
            prev_actions   => ['NEW'],
            id             => 'EDITITEM',
            name           => __('Edited item metadata'),
            ui_method_name => __('Edit item metadata'),
            method         => 'edititem',
            next_actions   => [],
            ui_method_icon => 'fa-edit',
        },
        UNAUTH => {
            prev_actions   => [],
            id             => 'UNAUTH',
            name           => 'Unauthenticated',
            ui_method_name => 0,
            method         => 0,
            next_actions   => [ 'REQ', 'GENREQ', 'KILL' ],
            ui_method_icon => 0,
        },
    };
}

=head3 create

  my $response = $backend->create({ params => $params });

We just want to generate a form that allows the end-user to associate key
value pairs in the database.

=cut

sub create {
    my ( $self, $params ) = @_;
    my $other       = $params->{other};
    my $stage       = $other->{stage};
    my $core_fields = _get_core_string();
    if ( !$stage || $stage eq 'init' ) {

        # First thing we want to do, is check if we're receiving
        # an OpenURL and transform it into something we can
        # understand
        if ( $other->{openurl} ) {

            # We only want to transform once
            delete $other->{openurl};
            $params = _openurl_to_ill($params);
        }

        # We simply need our template .INC to produce a form.
        return {
            cwd     => dirname(__FILE__),
            error   => 0,
            status  => '',
            message => '',
            method  => 'create',
            stage   => 'form',
            value   => $params,
            core    => $core_fields
        };
    } elsif ( $stage eq 'form' ) {

        # We may be receiving a submitted form due to an additional
        # custom field being added or deleted, or the material type
        # having been changed, so check for these things
        if ( !_can_create_request($other) ) {
            if ( defined $other->{'add_new_custom'} ) {
                my ( $custom_keys, $custom_vals ) =
                    _get_custom( $other->{'custom_key'}, $other->{'custom_value'} );
                push @{$custom_keys}, '---';
                push @{$custom_vals}, '---';
                $other->{'custom_key'}   = join "\0", @{$custom_keys};
                $other->{'custom_value'} = join "\0", @{$custom_vals};
            } elsif ( defined $other->{'custom_delete'} ) {
                my $delete_idx = $other->{'custom_delete'};
                my ( $custom_keys, $custom_vals ) =
                    _get_custom( $other->{'custom_key'}, $other->{'custom_value'} );
                splice @{$custom_keys}, $delete_idx, 1;
                splice @{$custom_vals}, $delete_idx, 1;
                $other->{'custom_key'}   = join "\0", @{$custom_keys};
                $other->{'custom_value'} = join "\0", @{$custom_vals};
            } elsif ( defined $other->{'change_type'} ) {

                # We may be receiving a submitted form due to the user having
                # changed request material type, so we just need to go straight
                # back to the form, the type has been changed in the params
                delete $other->{'change_type'};
            }
            return {
                cwd     => dirname(__FILE__),
                status  => "",
                message => "",
                error   => 0,
                value   => $params,
                method  => "create",
                stage   => "form",
                core    => $core_fields
            };
        }

        # Received completed details of form.  Validate and create request.
        my $result = {
            cwd     => dirname(__FILE__),
            status  => "",
            message => "",
            error   => 1,
            value   => {},
            method  => "create",
            stage   => "form",
            core    => $core_fields
        };
        my $failed = 0;

        my $unauthenticated_request =
            C4::Context->preference("ILLOpacUnauthenticatedRequest") && !$other->{'cardnumber'};
        if ($unauthenticated_request) {
            ( $failed, $result ) = _validate_form_params( $other, $result, $params );
            return $result if $failed;
            my $unauth_request_error = Koha::ILL::Request::unauth_request_data_error($other);
            if ($unauth_request_error) {
                $result->{status} = $unauth_request_error;
                $result->{value}  = $params;
                $failed           = 1;
            }
        } else {
            ( $failed, $result ) = _validate_form_params( $other, $result, $params );

            my ( $brw_count, $brw ) =
                _validate_borrower( $other->{'cardnumber'} );

            if ( $brw_count == 0 ) {
                $result->{status} = "invalid_borrower";
                $result->{value}  = $params;
                $failed           = 1;
            } elsif ( $brw_count > 1 ) {

                # We must select a specific borrower out of our options.
                $params->{brw}   = $brw;
                $result->{value} = $params;
                $result->{stage} = "borrowers";
                $result->{error} = 0;
                $failed          = 1;
            }
        }

        return $result if $failed;

        $self->add_request( { request => $params->{request}, other => $other } );

        my $request_details = _get_request_details( $params, $other );

        ## -> create response.
        return {
            cwd     => dirname(__FILE__),
            error   => 0,
            status  => '',
            message => '',
            method  => 'create',
            stage   => 'commit',
            next    => 'illview',
            value   => $request_details,
            core    => $core_fields
        };
    } else {

        # Invalid stage, return error.
        return {
            cwd     => dirname(__FILE__),
            error   => 1,
            status  => 'unknown_stage',
            message => '',
            method  => 'create',
            stage   => $params->{stage},
            value   => {},
        };
    }
}

=head3 edititem

=cut

sub edititem {
    my ( $self, $params ) = @_;

    my $core        = _get_core_fields();
    my $core_fields = _get_core_string();

    # Don't allow editing of submitted requests
    return { method => 'illlist' } if $params->{request}->status ne 'NEW';

    my $other = $params->{other};
    my $stage = $other->{stage};
    if ( !$stage || $stage eq 'init' ) {

        my $attrs = $params->{request}->extended_attributes;

        # We need to identify which parameters are custom, and pass them
        # to the template in a predefined form
        my $custom_keys = [];
        my $custom_vals = [];
        while ( my $attr = $attrs->next ) {
            if ( !$core->{ $attr->type } ) {
                push @{$custom_keys}, $attr->type;
                push @{$custom_vals}, $attr->value;
            } else {
                $other->{ $attr->type } = $attr->value;
            }
        }
        $other->{'custom_key'}   = join "\0", @{$custom_keys};
        $other->{'custom_value'} = join "\0", @{$custom_vals};

        # Pass everything back to the template
        return {
            cwd     => dirname(__FILE__),
            error   => 0,
            status  => '',
            message => '',
            method  => 'edititem',
            stage   => 'form',
            value   => $params,
            core    => $core_fields
        };
    } elsif ( $stage eq 'form' ) {

        # We may be receiving a submitted form due to an additional
        # custom field being added or deleted, or the material type
        # having been changed, so check for these things
        if (   defined $other->{'add_new_custom'}
            || defined $other->{'custom_delete'}
            || defined $other->{'change_type'} )
        {
            if ( defined $other->{'add_new_custom'} ) {
                my ( $custom_keys, $custom_vals ) =
                    _get_custom( $other->{'custom_key'}, $other->{'custom_value'} );
                push @{$custom_keys}, '---';
                push @{$custom_vals}, '---';
                $other->{'custom_key'}   = join "\0", @{$custom_keys};
                $other->{'custom_value'} = join "\0", @{$custom_vals};
            } elsif ( defined $other->{'custom_delete'} ) {
                my $delete_idx = $other->{'custom_delete'};
                my ( $custom_keys, $custom_vals ) =
                    _get_custom( $other->{'custom_key'}, $other->{'custom_value'} );
                splice @{$custom_keys}, $delete_idx, 1;
                splice @{$custom_vals}, $delete_idx, 1;
                $other->{'custom_key'}   = join "\0", @{$custom_keys};
                $other->{'custom_value'} = join "\0", @{$custom_vals};
            } elsif ( defined $other->{'change_type'} ) {

                # We may be receiving a submitted form due to the user having
                # changed request material type, so we just need to go straight
                # back to the form, the type has been changed in the params
                delete $other->{'change_type'};
            }
            return {
                cwd     => dirname(__FILE__),
                status  => "",
                message => "",
                error   => 0,
                value   => $params,
                method  => "edititem",
                stage   => "form",
                core    => $core_fields
            };
        }

        # We don't want the request ID param getting any further
        delete $other->{illrequest_id};

        my $result = {
            cwd     => dirname(__FILE__),
            status  => "",
            message => "",
            error   => 1,
            value   => {},
            method  => "edititem",
            stage   => "form",
            core    => $core_fields
        };

        # Received completed details of form.  Validate and create request.
        ## Validate
        my $failed = 0;
        if ( !$other->{'type'} ) {
            $result->{status} = "missing_type";
            $result->{value}  = $params;
            $failed           = 1;
        }
        return $result if $failed;

        ## Update request

        # ...Update Illrequest
        my $request = $params->{request};
        $request->updated( dt_from_string() );
        $request->store;

        # ...Populate Illrequestattributes
        # generate $request_details
        my $request_details = _get_request_details( $params, $other );

        # We do this with a 'dump all and repopulate approach' inside
        # a transaction, easier than catering for create, update & delete
        my $dbh    = C4::Context->dbh;
        my $schema = Koha::Database->new->schema;
        $schema->txn_do(
            sub {
                # Delete all existing attributes for this request
                $dbh->do(
                    q|
                    DELETE FROM illrequestattributes WHERE illrequest_id=?
                |, undef, $request->id
                );

                # Insert all current attributes for this request
                foreach my $attr ( keys %{$request_details} ) {
                    my $value = $request_details->{$attr};
                    if ( $value && length $value > 0 ) {
                        if ( column_exists( 'illrequestattributes', 'backend' ) ) {
                            my @bind = ( $request->id, 'Standard', $attr, $value, 0 );
                            $dbh->do(
                                q|
                                INSERT INTO illrequestattributes
                                (illrequest_id, backend, type, value, readonly) VALUES
                                (?, ?, ?, ?, ?)
                            |, undef, @bind
                            );
                        } else {
                            my @bind = ( $request->id, $attr, $value, 0 );
                            $dbh->do(
                                q|
                                INSERT INTO illrequestattributes
                                (illrequest_id, type, value, readonly) VALUES
                                (?, ?, ?, ?)
                            |, undef, @bind
                            );
                        }
                    }
                }
            }
        );

        ## -> create response.
        return {
            error   => 0,
            status  => '',
            message => '',
            method  => 'create',
            stage   => 'commit',
            next    => 'illview',
            value   => $request_details,
            core    => $core_fields
        };
    } else {

        # Invalid stage, return error.
        return {
            error   => 1,
            status  => 'unknown_stage',
            message => '',
            method  => 'create',
            stage   => $params->{stage},
            value   => {},
        };
    }
}

=head3 confirm

  my $response = $backend->confirm({ params => $params });

Confirm the placement of the previously "selected" request (by using the
'create' method).

In the Standard backend we only want to display a bit of text to let staff
confirm that they have taken the steps they need to take to "confirm" the
request.

=cut

sub confirm {
    my ( $self, $params ) = @_;
    my $stage = $params->{other}->{stage};
    if ( !$stage || $stage eq 'init' ) {

        # We simply need our template .INC to produce a text block.
        return {
            method => 'confirm',
            stage  => 'confirm',
            value  => $params,
        };
    } elsif ( $stage eq 'confirm' ) {
        my $request = $params->{request};
        $request->orderid( $request->illrequest_id );
        $request->status("REQ");
        $request->store;

        # ...then return our result:
        return {
            method => 'confirm',
            stage  => 'commit',
            next   => 'illview',
            value  => {},
        };
    } else {

        # Invalid stage, return error.
        return {
            error   => 1,
            status  => 'unknown_stage',
            message => '',
            method  => 'confirm',
            stage   => $params->{stage},
            value   => {},
        };
    }
}

=head3 cancel

  my $response = $backend->cancel({ params => $params });

We will attempt to cancel a request that was confirmed.

In the Standard backend this simply means displaying text to the librarian
asking them to confirm they have taken all steps needed to cancel a confirmed
request.

=cut

sub cancel {
    my ( $self, $params ) = @_;
    my $stage = $params->{other}->{stage};
    if ( !$stage || $stage eq 'init' ) {

        # We simply need our template .INC to produce a text block.
        return {
            method => 'cancel',
            stage  => 'confirm',
            value  => $params,
        };
    } elsif ( $stage eq 'confirm' ) {
        $params->{request}->status("REQREV");
        $params->{request}->orderid(undef);
        $params->{request}->store;
        return {
            method => 'cancel',
            stage  => 'commit',
            next   => 'illview',
            value  => $params,
        };
    } else {

        # Invalid stage, return error.
        return {
            error   => 1,
            status  => 'unknown_stage',
            message => '',
            method  => 'cancel',
            stage   => $params->{stage},
            value   => {},
        };
    }
}

=head3 migrate

Migrate a request into or out of this backend.

=cut

sub migrate {
    my ( $self, $params ) = @_;
    my $other = $params->{other};

    my $stage = $other->{stage};
    my $step  = $other->{step};

    my $core_fields = _get_core_string();

    # We may be receiving a submitted form due to an additional
    # custom field being added or deleted, or the material type
    # having been changed, so check for these things
    if (   defined $other->{'add_new_custom'}
        || defined $other->{'custom_delete'}
        || defined $other->{'change_type'} )
    {
        if ( defined $other->{'add_new_custom'} ) {
            my ( $custom_keys, $custom_vals ) =
                _get_custom( $other->{'custom_key'}, $other->{'custom_value'} );
            push @{$custom_keys}, '---';
            push @{$custom_vals}, '---';
            $other->{'custom_key'}   = join "\0", @{$custom_keys};
            $other->{'custom_value'} = join "\0", @{$custom_vals};
        } elsif ( defined $other->{'custom_delete'} ) {
            my $delete_idx = $other->{'custom_delete'};
            my ( $custom_keys, $custom_vals ) =
                _get_custom( $other->{'custom_key'}, $other->{'custom_value'} );
            splice @{$custom_keys}, $delete_idx, 1;
            splice @{$custom_vals}, $delete_idx, 1;
            $other->{'custom_key'}   = join "\0", @{$custom_keys};
            $other->{'custom_value'} = join "\0", @{$custom_vals};
        } elsif ( defined $other->{'change_type'} ) {

            # We may be receiving a submitted form due to the user having
            # changed request material type, so we just need to go straight
            # back to the form, the type has been changed in the params
            delete $other->{'change_type'};
        }
        return {
            cwd     => dirname(__FILE__),
            status  => "",
            message => "",
            error   => 0,
            value   => $params,
            method  => "create",
            stage   => "form",
            core    => $core_fields
        };
    }

    # Receive a new request from another backend and supplement it with
    # anything we require specifically for this backend.
    if ( !$stage || $stage eq 'immigrate' ) {
        my $original_request = Koha::ILL::Requests->find( $other->{illrequest_id} );
        my $new_request      = $params->{request};
        $new_request->borrowernumber( $original_request->borrowernumber );
        $new_request->branchcode( $original_request->branchcode );
        $new_request->status('NEW');
        $new_request->backend( $self->name );
        $new_request->placed( dt_from_string() );
        $new_request->updated( dt_from_string() );
        $new_request->store;

        my @default_attributes = (qw/title type author year volume isbn issn article_title article_author pages/);
        my $original_attributes =
            $original_request->extended_attributes->search( { type => { '-in' => \@default_attributes } } );

        my @request_details_array = map {
            {
                'type'  => $_->type,
                'value' => $_->value,
            }
        } $original_attributes->as_list;

        push @request_details_array, {
            'type'  => 'migrated_from',
            'value' => $original_request->illrequest_id,
        };

        $new_request->extended_attributes( \@request_details_array );

        return {
            error   => 0,
            status  => '',
            message => '',
            method  => 'migrate',
            stage   => 'commit',
            next    => 'emigrate',
            value   => $params,
            core    => $core_fields
        };
    }

    # Cleanup any outstanding work, close the request.
    elsif ( $stage eq 'emigrate' ) {
        my $new_request = $params->{request};
        my $from_id     = $new_request->extended_attributes->find( { type => 'migrated_from' } )->value;
        my $request     = Koha::ILL::Requests->find($from_id);

        # Just cancel the original request now it's been migrated away
        $request->status("REQREV");
        $request->orderid(undef);
        $request->store;

        return {
            error   => 0,
            status  => '',
            message => '',
            method  => 'migrate',
            stage   => 'commit',
            next    => 'illview',
            value   => $params,
            core    => $core_fields
        };
    }
}

=head3 illview

   View and manage an ILL request

=cut

sub illview {
    my ( $self, $params ) = @_;

    return { method => "illview" };
}

## Helpers

=head3 _get_requested_partners

=cut

sub _get_requested_partners {

    # Take a request and retrieve an Illrequestattribute with
    # the type 'requested_partners'.
    my ($args) = @_;
    my $where = {
        illrequest_id => $args->{request}->id,
        type          => 'requested_partners'
    };
    my $res = Koha::ILL::Request::Attributes->find($where);
    return ($res) ? $res->value : undef;
}

=head3 _set_requested_partners

=cut

sub _set_requested_partners {

    # Take a request and set an Illrequestattribute on it
    # detailing the email address(es) of the requested
    # partner(s). We replace any existing value since, by
    # the time we get to this stage, any previous request
    # from partners would have had to be cancelled
    my ($args) = @_;
    my $where = {
        illrequest_id => $args->{request}->id,
        type          => 'requested_partners'
    };
    Koha::ILL::Request::Attributes->search($where)->delete();
    Koha::ILL::Request::Attribute->new(
        {
            illrequest_id => $args->{request}->id,
            column_exists( 'illrequestattributes', 'backend' ) ? ( backend => "Standard" ) : (),
            type  => 'requested_partners',
            value => $args->{to}
        }
    )->store;
}

=head3 _validate_borrower

=cut

sub _validate_borrower {

    # Perform cardnumber search.  If no results, perform surname search.
    # Return ( 0, undef ), ( 1, $brw ) or ( n, $brws )
    my ($input) = @_;
    my $patrons = Koha::Patrons->new;
    my ( $count, $brw );
    my $query = { cardnumber => $input };

    my $brws = $patrons->search($query);
    $count = $brws->count;
    my @criteria = qw/ surname userid firstname end /;
    while ( $count == 0 ) {
        my $criterium = shift @criteria;
        return ( 0, undef ) if ( "end" eq $criterium );
        $brws  = $patrons->search( { $criterium => $input } );
        $count = $brws->count;
    }
    if ( $count == 1 ) {
        $brw = $brws->next;
    } else {
        $brw = $brws;    # found multiple results
    }
    return ( $count, $brw );
}

=head3 _get_custom

=cut

sub _get_custom {

    # Take an string of custom keys and an string
    # of custom values, both delimited by \0 (by CGI)
    # and return an arrayref of each
    my ( $keys, $values ) = @_;
    my @k = defined $keys   ? split( "\0", $keys )   : ();
    my @v = defined $values ? split( "\0", $values ) : ();
    return ( \@k, \@v );
}

=head3 _prepare_custom

=cut

sub _prepare_custom {

    # Take an arrayref of custom keys and an arrayref
    # of custom values, return a hashref of them
    my ( $keys, $values ) = @_;
    my %out = ();
    if ($keys) {
        my @k = split( "\0", $keys );
        my @v = split( "\0", $values );
        %out = map { $k[$_] => $v[$_] } 0 .. $#k;
    }
    return \%out;
}

=head3 _get_request_details

    my $request_details = _get_request_details($params, $other);

Return the illrequestattributes for a given request

=cut

sub _get_request_details {
    my ( $params, $other ) = @_;

    # Get custom key / values we've been passed
    # Prepare them for addition into the Illrequestattribute object
    my $custom =
        _prepare_custom( $other->{'custom_key'}, $other->{'custom_value'} );

    my $return = {%$custom};
    my $core   = _get_core_fields();
    foreach my $key ( keys %{$core} ) {
        $return->{$key} = $params->{other}->{$key};
    }

    return $return;
}

=head3 _get_core_string

Return a comma delimited, quoted, string of core field keys

=cut

sub _get_core_string {
    my $core = _get_core_fields();
    return join( ",", map { '"' . $_ . '"' } keys %{$core} );
}

=head3 _get_core_fields

Return a hashref of core fields

=cut

sub _get_core_fields {
    return {
        article_author  => __('Article author'),
        article_title   => __('Article title'),
        associated_id   => __('Associated ID'),
        author          => __('Author'),
        chapter_author  => __('Chapter author'),
        chapter         => __('Chapter'),
        conference_date => __('Conference date'),
        doi             => __('DOI'),
        editor          => __('Editor'),
        format          => __('Format'),
        genre           => __('Genre'),
        institution     => __('Institution'),
        isbn            => __('ISBN'),
        issn            => __('ISSN'),
        issue           => __('Issue'),
        item_date       => __('Date'),
        language        => __('Language'),
        pages           => __('Pages'),
        pagination      => __('Pagination'),
        paper_author    => __('Paper author'),
        paper_title     => __('Paper title'),
        part_edition    => __('Part / Edition'),
        publication     => __('Publication'),
        published_date  => __('Publication date'),
        published_place => __('Place of publication'),
        publisher       => __('Publisher'),
        pubmedid        => __('PubMed ID'),
        pmid            => __('PubMed ID'),
        sponsor         => __('Sponsor'),
        studio          => __('Studio'),
        title           => __('Title'),
        type            => __('Type'),
        venue           => __('Venue'),
        volume          => __('Volume'),
        year            => __('Year'),
    };
}

=head3 add_request

Add an ILL request

=cut

sub add_request {

    my ( $self, $params ) = @_;

    my $unauthenticated_request =
        C4::Context->preference("ILLOpacUnauthenticatedRequest") && !$params->{other}->{'cardnumber'};

    # ...Populate Illrequestattributes
    # generate $request_details
    my $request_details = _get_request_details( $params, $params->{other} );

    my ( $brw_count, $brw );
    ( $brw_count, $brw ) = _validate_borrower( $params->{other}->{'cardnumber'} ) unless $unauthenticated_request;

    ## Create request

    # Create bib record
    my $biblionumber = $self->_standard_request2biblio($request_details);

    # ...Populate Illrequest
    my $request = $params->{request};
    $request->biblio_id($biblionumber) unless $biblionumber == 0;
    $request->borrowernumber( $brw ? $brw->borrowernumber : undef );
    $request->branchcode( $params->{other}->{branchcode} );
    $request->status( $unauthenticated_request ? 'UNAUTH' : 'NEW' );
    $request->backend( $params->{other}->{backend} );
    $request->placed( dt_from_string() );
    $request->updated( dt_from_string() );
    $request->batch_id(
        $params->{other}->{ill_batch_id} ? $params->{other}->{ill_batch_id} : $params->{other}->{batch_id} )
        if column_exists( 'illrequests', 'batch_id' );
    $request->store;

    my @request_details_array = map {
        {
            'type'  => $_,
            'value' => $request_details->{$_},
        }
    } keys %{$request_details};
    $request->extended_attributes( \@request_details_array );
    $request->add_unauthenticated_data( $params->{other} ) if $unauthenticated_request;

    return $request;
}

=head3 _openurl_to_ill

Take a hashref of OpenURL parameters and return
those same parameters but transformed to the ILL
schema

=cut

sub _openurl_to_ill {
    my ($params) = @_;

    # Parameters to not place in our custom
    # parameters arrays
    my $ignore = {
        openurl            => 1,
        backend            => 1,
        method             => 1,
        opac               => 1,
        cardnumber         => 1,
        branchcode         => 1,
        userid             => 1,
        password           => 1,
        koha_login_context => 1,
        stage              => 1
    };

    my $transform_metadata = {
        genre   => 'type',
        content => 'type',
        format  => 'type',
        atitle  => 'article_title',
        aulast  => 'author',
        author  => 'author',
        date    => 'year',
        issue   => 'issue',
        volume  => 'volume',
        isbn    => 'isbn',
        issn    => 'issn',
        doi     => 'doi',
        year    => 'year',
        title   => 'title',
        author  => 'author',
        aulast  => 'article_author',
        pages   => 'pages',
        ctitle  => 'chapter',
        clast   => 'chapter_author'
    };

    my $transform_value = {
        type => {
            fulltext   => 'article',
            selectedft => 'article',
            print      => 'book',
            ebook      => 'book',
            journal    => 'journal'
        }
    };

    my $return       = {};
    my $custom_key   = [];
    my $custom_value = [];

    # First make sure our keys are correct
    foreach my $meta_key ( keys %{ $params->{other} } ) {

        # If we are transforming this property...
        if ( exists $transform_metadata->{$meta_key} ) {

            # ...do it
            $return->{ $transform_metadata->{$meta_key} } = $params->{other}->{$meta_key};
        } else {

            # Otherwise, pass it through untransformed and maybe move it
            # to our custom parameters array
            if ( !exists $ignore->{$meta_key} ) {
                if ( $meta_key eq 'id' || $meta_key eq 'rft_id' ) {
                    if ( $params->{other}->{$meta_key} =~ /:/ ) {
                        my ( $k, $v ) = split /:/, $params->{other}->{$meta_key}, 2;
                        if ( defined $k && defined $v ) {
                            $return->{ lc $k } = $v;
                        }
                    } else {
                        $return->{doi} = $params->{other}->{$meta_key};
                    }
                } else {
                    push @{$custom_key},   $meta_key;
                    push @{$custom_value}, $params->{other}->{$meta_key};
                }
            } else {
                $return->{$meta_key} = $params->{other}->{$meta_key};
            }
        }
    }

    # Now check our values are correct
    foreach my $val_key ( keys %{$return} ) {
        my $value = $return->{$val_key};
        if ( exists $transform_value->{$val_key} && exists $transform_value->{$val_key}->{$value} ) {
            $return->{$val_key} = $transform_value->{$val_key}->{$value};
        }
    }
    if ( scalar @{$custom_key} > 0 ) {
        $return->{custom_key}   = join( "\0", @{$custom_key} );
        $return->{custom_value} = join( "\0", @{$custom_value} );
    }
    $params->{other}         = $return;
    $params->{custom_keys}   = $custom_key;
    $params->{custom_values} = $custom_value;
    return $params;

}

=head3 create_api

Create a local submission from data supplied via an
API call

=cut

sub create_api {
    my ( $self, $body, $request ) = @_;

    my $patron = Koha::Patrons->find( $body->{borrowernumber} );

    $body->{cardnumber} = $patron->cardnumber;

    foreach my $attr ( @{ $body->{extended_attributes} } ) {
        $body->{ $attr->{type} } = $attr->{value};
    }

    $body->{type} = $body->{'isbn'} ? 'book' : 'article';

    my $submission = $self->add_request( { request => $request, other => $body } );

    return $submission;
}

=head3 _can_create_request

Given the parameters we've been passed, should we create the request

=cut

sub _can_create_request {
    my ($params) = @_;
    return (   defined $params->{'stage'}
            && $params->{'stage'} eq 'form'
            && !defined $params->{'add_new_custom'}
            && !defined $params->{'custom_delete'}
            && !defined $params->{'change_type'} ) ? 1 : 0;
}

=head3 _standard_request2biblio

Given supplied metadata from a Standard request, create a basic biblio
record and return its ID

=cut

sub _standard_request2biblio {
    my ( $self, $metadata ) = @_;

    # We only want to create biblios for books
    return 0 unless $metadata->{type} eq 'book';

    # We're going to try and populate author, title & ISBN
    my $author = $metadata->{author} // '';
    my $title  = $metadata->{title}  // '';
    my $isbn   = $metadata->{isbn}   // '';

    # Create the MARC::Record object and populate
    my $record = MARC::Record->new();

    # Fix character set where appropriate
    my $marcflavour = C4::Context->preference('marcflavour') || 'MARC21';
    if ( $record->encoding() eq 'MARC-8' ) {
        ($record) = MarcToUTF8Record( $record, $marcflavour );
    }

    if ( $marcflavour eq 'MARC21' ) {
        $record->append_fields( MARC::Field->new( '020', '',  '',  a => $isbn ) )   if $isbn;
        $record->append_fields( MARC::Field->new( '100', '1', '',  a => $author ) ) if $author;
        $record->append_fields( MARC::Field->new( '245', '0', '0', a => $title ) )  if $title;
    } elsif ( $marcflavour eq 'UNIMARC' ) {
        $record->append_fields( MARC::Field->new( '010', '', '', a => $isbn ) ) if $isbn;
        $record->append_fields(
            MARC::Field->new( '200', '', '', $title ? ( 'a' => $title ) : undef, $author ? ( 'f' => $author ) : undef )
        ) if $author || $title;
    }

    # Suppress the record
    _set_suppression($record);

    # Create a biblio record
    my ( $biblionumber, $biblioitemnumber ) =
        AddBiblio( $record, $self->{framework} );

    return $biblionumber;
}

=head3 _set_suppression

    _set_suppression($record);

Take a MARC::Record object and set it to be suppressed

=cut

sub _set_suppression {
    my ($record) = @_;

    my $new942 = MARC::Field->new( '942', '', '', n => '1' );
    $record->append_fields($new942);

    return 1;
}

=head3 _validate_form_params

    _validate_form_params( $other, $result, $params );

Validate form parameters and return the validation result

=cut

sub _validate_form_params {
    my ( $other, $result, $params ) = @_;

    my $failed = 0;
    if ( !$other->{'type'} ) {
        $result->{status} = "missing_type";
        $result->{value}  = $params;
        $failed           = 1;
    } elsif ( !$other->{'branchcode'} ) {
        $result->{status} = "missing_branch";
        $result->{value}  = $params;
        $failed           = 1;
    } elsif ( !Koha::Libraries->find( $other->{'branchcode'} ) ) {
        $result->{status} = "invalid_branch";
        $result->{value}  = $params;
        $failed           = 1;
    }

    return ( $failed, $result );
}

=head1 AUTHORS

Alex Sassmannshausen <alex.sassmannshausen@ptfs-europe.com>
Martin Renvoize <martin.renvoize@ptfs-europe.com>
Andrew Isherwood <andrew.isherwood@ptfs-europe.com>

=cut

1;
