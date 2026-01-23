# Copyright 2015 Catalyst

package WebService::ILS::OverDrive::Patron;

use Modern::Perl;

=encoding utf-8

=head1 NAME

WebService::ILS::OverDrive::Patron - WebService::ILS module for OverDrive
circulation services

=head1 SYNOPSIS

    use WebService::ILS::OverDrive::Patron;

=head1 DESCRIPTION

These services require individual user credentials.
See L<WebService::ILS INDIVIDUAL USER AUTHENTICATION AND METHODS>

See L<WebService::ILS::OverDrive>

=cut

use Carp;
use HTTP::Request::Common;
use URI::Escape;
use Data::Dumper;

use parent qw(WebService::ILS::OverDrive);

use constant CIRCULATION_API_URL => "http://patron.api.overdrive.com/";
use constant TEST_CIRCULATION_API_URL => "http://integration-patron.api.overdrive.com/";
use constant OAUTH_BASE_URL => "https://oauth.overdrive.com/";
use constant TOKEN_URL => OAUTH_BASE_URL . 'token';
use constant AUTH_URL => OAUTH_BASE_URL . 'auth';

=head1 CONSTRUCTOR

=head2 new (%params_hash or $params_hashref)

=head3 Additional constructor params:

=over 16

=item C<auth_token> => auth token as previously obtained

=back

=cut

use Class::Tiny qw(
    user_id password website_id authorization_name
    auth_token
), {
    _circulation_api_url => sub { $_[0]->test ? TEST_CIRCULATION_API_URL : CIRCULATION_API_URL },
};

__PACKAGE__->_set_param_spec({
    auth_token      => { required => 0 },
});

=head1 INDIVIDUAL USER AUTHENTICATION METHODS

=head2 auth_by_user_id ($user_id, $password, $website_id, $authorization_name)

C<website_id> and C<authorization_name> (domain) are provided by OverDrive

=head3 Returns (access_token, access_token_type) or access_token

=cut

sub auth_by_user_id {
    my $self = shift;
    my $user_id = shift or croak "No user id";
    my $password = shift; # can be blank
    my $website_id = shift or croak "No website id";
    my $authorization_name = shift or croak "No authorization name";

    my $request = $self->_make_access_token_by_user_id_request($user_id, $password, $website_id, $authorization_name);
    $self->_request_access_token($request);

    $self->user_id($user_id);
    $self->password($password);
    $self->website_id($website_id);
    $self->authorization_name($authorization_name);
    return wantarray ? ($self->access_token, $self->access_token_type) : $self->access_token;
}

sub _make_access_token_by_user_id_request {
    my $self = shift;
    my $user_id = shift or croak "No user id";
    my $password = shift; # can be blank
    my $website_id = shift or croak "No website id";
    my $authorization_name = shift or croak "No authorization name";

    my %params = (
        grant_type => 'password',
        username => $user_id,
        scope => "websiteid:".$website_id." authorizationname:".$authorization_name,
    );
    if ($password) {
        $params{password} = $password;
    } else {
        $params{password} = "[ignore]";
        $params{password_required} = "false";
    }
    return HTTP::Request::Common::POST( 'https://oauth-patron.overdrive.com/patrontoken', \%params );
}

=head2 Authentication at OverDrive - Granted or "3-Legged" Authorization

With OverDrive there's an extra step - an auth code is returned to the
redirect back handler that needs to make an API call to convert it into
a auth token.

An example:

    my $overdrive = WebService::ILS::OverDrive::Patron({
        client_id => $client_id,
        client_secret => $client_secret,
        library_id => $library_id,
    });
    my $redirect_url = $overdrive->auth_url("http://myapp.com/overdrive-auth");
    $response->redirect($redirect_url);
    ...
    /overdrive-auth handler:
    my $auth_code = $req->param( $overdrive->auth_code_param_name )
        or some_error_handling(), return;
    # my $state = $req->param( $overdrive->state_token_param_name )...
    local $@;
    eval { $overdrive->auth_by_code( $auth_code ) };
    if ($@) { some_error_handling(); return; }
    $session{overdrive_access_token} = $access_token;
    $session{overdrive_access_token_type} = $access_token_type;
    $session{overdrive_auth_token} = $auth_token;
    ...
    Somewhere else in your app:
    my $ils = WebService::ILS::Provider({
        client_id => $client_id,
        client_secret => $client_secret,
        access_token => $session{overdrive_access_token},
        access_token_type => $session{overdrive_access_token_type},
        auth_token = $session{overdrive_auth_token}
    });
    my $checkouts = $overdrive->checkouts;

=head2 auth_url ($redirect_uri, $state_token)

=head3 Input params:

=over 18

=item C<redirect_uri> => return url which will handle redirect back after auth

=item C<state_token>  => a token that is returned back unchanged;

for additional security; not required

=back

=cut

sub auth_url {
    my $self = shift;
    my $redirect_uri = shift or croak "Redirect URI not specified";
    my $state_token = shift;

    my $library_id = $self->library_id or croak "No Library Id";

    return sprintf AUTH_URL .
            "?client_id=%s" .
            "&redirect_uri=%s" .
            "&scope=%s" .
            "&response_type=code" .
            "&state=%s",
        map uri_escape($_),
            $self->client_id,
            $redirect_uri,
            "accountid:$library_id",
            defined ($state_token) ? $state_token : ""
    ;
}

=head2 auth_code_param_name ()

=head2 state_token_param_name ()

=cut

use constant auth_code_param_name => "code";
use constant state_token_param_name => "code";

=head2 auth_by_code ($provider_code, $redirect_uri)

=head3 Returns (access_token, access_token_type, auth_token) or access_token

=cut

sub auth_by_code {
    my $self = shift;
    my $code = shift or croak "No authorization code";
    my $redirect_uri = shift or croak "Redirect URI not specified";

    my $auth_type = 'authorization_code';

    my $request = HTTP::Request::Common::POST( TOKEN_URL, {
        grant_type => 'authorization_code',
        code => $code,
        redirect_uri => $redirect_uri,
    } );
    $self->_request_access_token($request);
    return wantarray ? ($self->access_token, $self->access_token_type, $self->auth_token) : $self->access_token;
}

=head2 auth_by_token ($provider_token)

=head3 Returns (access_token, access_token_type, auth_token) or access_token

=cut

sub auth_by_token {
    my $self = shift;
    my $auth_token = shift or croak "No authorization token";

    $self->auth_token($auth_token);
    my $request = $self->_make_access_token_by_auth_token_request($auth_token);
    $self->_request_access_token($request);

    return wantarray ? ($self->access_token, $self->access_token_type, $self->auth_token) : $self->access_token;
}

sub _make_access_token_by_auth_token_request {
    my $self = shift;
    my $auth_token = shift or croak "No authorization token";

    return HTTP::Request::Common::POST( TOKEN_URL, {
            grant_type => 'refresh_token',
            refresh_token => $auth_token,
    } );
}

sub make_access_token_request {
    my $self = shift;

    if (my $auth_token = $self->auth_token) {
        return $self->_make_access_token_by_auth_token_request($auth_token);
    }
    elsif (my $user_id = $self->user_id) {
        return $self->_make_access_token_by_user_id_request(
            $user_id, $self->password, $self->website_id, $self->authorization_name
        );
    }

    die $self->ERROR_NOT_AUTHENTICATED."\n";
}

sub _request_access_token {
    my $self = shift;
    my $request = shift or croak "No request";

    my $data = $self->SUPER::_request_access_token($request)
      or die "Unsuccessful access token request";

    if (my $auth_token = $data->{refresh_token}) {
        $self->auth_token($auth_token);
    }

    return $data;
}

sub collection_token {
    my $self = shift;

    if (my $collection_token = $self->SUPER::collection_token) {
        return $collection_token;
    }

    $self->native_patron; # sets collection_token as a side-effect
    my $collection_token = $self->SUPER::collection_token
      or die "Patron has no collections\n";
    return $collection_token;
}

=head1 CIRCULATION METHOD SPECIFICS

Differences to general L<WebService::ILS> interface

=cut

my %PATRON_XLATE = (
    checkoutLimit => "checkout_limit",
    existingPatron => 'active',
    patronId => 'id',
    holdLimit => 'hold_limit',
);
sub patron {
    my $self = shift;
    return $self->_result_xlate($self->native_patron, \%PATRON_XLATE);
}

my %HOLDS_XLATE = (
    totalItems => 'total',
);
my %HOLDS_ITEM_XLATE = (
    reserveId => 'id',
    holdPlacedDate => 'placed_datetime',
    holdListPosition => 'queue_position',
);
sub holds {
    my $self = shift;

    my $holds = $self->native_holds;
    my $items = delete ($holds->{holds}) || [];

    my $res = $self->_result_xlate($holds, \%HOLDS_XLATE);
    $res->{items} = [
        map {
            my $item = $self->_result_xlate($_, \%HOLDS_ITEM_XLATE);
            my $item_id = $item->{id};
            my $metadata = $self->item_metadata($item_id);
            my $i = {%$item, %$metadata}; # we need my $i, don't ask me why...
        } @$items
    ];
    return $res;
}

=head2 place_hold ($item_id, $notification_email_address, $auto_checkout)

C<$notification_email_address> and C<$auto_checkout> are optional.
C<$auto_checkout> defaults to false.

=head3 Returns holds item record

It is prefered that the C<$notification_email_address> is specified.

If C<$auto_checkout> is set to true, the item will be checked out as soon as
it becomes available.

=cut

sub place_hold {
    my $self = shift;

    my $hold = $self->native_place_hold(@_) or return;
    my $res = $self->_result_xlate($hold, \%HOLDS_ITEM_XLATE);
    $res->{total} = $hold->{numberOfHolds};
    return $res;
}

# sub suspend_hold { - not really useful

sub remove_hold {
    my $self = shift;
    my $item_id = shift or croak "No item id";

    my $url = $self->circulation_action_url("/holds/$item_id");
    return $self->with_delete_request(
        \&_basic_callback,
        sub {
            my ($data) = @_;
            return 1 if $data->{errorCode} eq "PatronDoesntHaveTitleOnHold";
            die ($data->{message} || $data->{errorCode})."\n";
        },
        $url
    );
}

=head2 checkouts ()

For formats see C<checkout_formats()> below

=cut

my %CHECKOUTS_XLATE = (
    totalItems => 'total',
    totalCheckouts => 'total_format',
);
sub checkouts {
    my $self = shift;

    my $checkouts = $self->native_checkouts;
    my $items = delete ($checkouts->{checkouts}) || [];

    my $res = $self->_result_xlate($checkouts, \%CHECKOUTS_XLATE);
    $res->{items} = [
        map {
            my $item = $self->_checkout_item_xlate($_);
            my $item_id = $item->{id};
            my $formats = delete ($_->{formats});
            my $actions = delete ($_->{actions});
            my $metadata = $self->item_metadata($item_id);
            if ($formats) {
                $formats = $self->_formats_xlate($item_id, $formats);
            }
            else {
                $formats = {};
            }
            if ($actions) {
                if (my $format_action = $actions->{format}) {
                    foreach (@{$format_action->{fields}}) {
                        next unless $_->{name} eq "formatType";

                        foreach my $format (@{$_->{options}}) {
                            $formats->{$format} = undef unless exists $formats->{$format};
                        }
                        last;
                    }
                }
            }
            my $i = {%$item, %$metadata, formats => $formats}; # we need my $i, don't ask me why...
        } @$items
    ];
    return $res;
}

my %CHECKOUT_ITEM_XLATE = (
    reserveId => 'id',
    checkoutDate => 'checkout_datetime',
    expires => 'expires',
);
sub _checkout_item_xlate {
    my $self = shift;
    my $item = shift;

    my $i = $self->_result_xlate($item, \%CHECKOUT_ITEM_XLATE);
    if ($item->{isFormatLockedIn}) {
        my $formats = $item->{formats} or die "Item $item->{reserveId}: Format locked in, but no formats returned\n";
        $i->{format} = $formats->[0]{formatType};
    }
    return $i;
}

=head2 checkout ($item_id, $format, $allow_multiple_format_checkouts)

C<$format> and C<$allow_multiple_format_checkouts> are optional.
C<$allow_multiple_format_checkouts> defaults to false.

=head3 Returns checkout item record

An item can be available in multiple formats. Checkout is complete only
when the format is specified.

Checkout can be actioned without format being specified. In that case an
early return can be actioned. To complete checkout format must be locked
later (see L<lock_format()> below). That would be the case with
L<place_hold()> with C<$auto_checkout> set to true. Once format is locked,
an early return is not possible.

If C<$allow_multiple_format_checkouts> flag is set to true, mutiple formats
of the same item can be acioned. If it is false (default) and the item was
already checked out, the checked out item record will be returned regardless
of the format.

Checkout record will have an extra field C<format> if format is locked in.

=cut

sub checkout {
    my $self = shift;

    my $checkout = $self->native_checkout(@_) or return;
    return $self->_checkout_item_xlate($checkout);
}

=head2 checkout_formats ($item_id)

=head3 Returns a hashref of available title formats and immediate availability

  { format => available, ... }

If format is not immediately available it must be locked first

=cut

sub checkout_formats {
    my $self = shift;
    my $id = shift or croak "No item id";

    my $formats = $self->native_checkout_formats($id) or return;
    $formats = $formats->{'formats'} or return;
    return $self->_formats_xlate($id, $formats);
}

sub _formats_xlate {
    my $self = shift;
    my $id = shift or croak "No item id";
    my $formats = shift or croak "No formats";

    my %ret;
    my $id_uc = uc $id;
    foreach (@$formats) {
        die "Non-matching item id\nExpected $id\nGot $_->{reserveId}" unless uc($_->{reserveId}) eq $id_uc;
        my $format = $_->{formatType};
        my $available;
        if (my $lt = $_->{linkTemplates}) {
            $available = grep /^downloadLink/, keys %$lt;
        }
        $ret{$format} = $available;
    }
    return \%ret;
}

sub is_lockable {
    my $self = shift;
    my $checkout_formats = shift or croak "No checkout formats";
    while (my ($format, $available) = each %$checkout_formats) {
        return 1 unless $available;
    }
    return 0;
}

=head2 lock_format ($item_id, $format)

=head3 Returns locked format (should be the same as the input value)

=cut

sub lock_format {
    my $self = shift;
    my $item_id = shift or croak "No item id";
    my $format = shift or croak "No format";

    my $lock = $self->native_lock_format($item_id, $format) or return;
    die "Non-matching item id\nExpected $item_id\nGot $lock->{reserveId}" unless uc($lock->{reserveId}) eq uc($item_id);
    return $lock->{formatType};
}

=head2 checkout_download_url ($item_id, $format, $error_url, $success_url)

=head3 Returns OverDrive download url

Checked out items must be downloaded by users on the OverDrive site.
This method returns the url where the user should be sent to (redirected).
Once the download is complete, user will be redirected back to
C<$error_url> in case of an error, otherwise to optional C<$success_url>
if specified.

See L<https://developer.overdrive.com/apis/download>

=cut

sub checkout_download_url {
    my $self = shift;
    my $item_id = shift or croak "No item id";
    my $format = shift or croak "No format";
    my $error_url = shift or die "No error url";
    my $success_url = shift;

    $error_url = uri_escape($error_url);
    $success_url = $success_url ? uri_escape($success_url) : '';
    my $url = $self->circulation_action_url("/checkouts/$item_id/formats/$format/downloadlink?errorurl=$error_url&successurl=$success_url");
    my $response_data = $self->get_response($url);
    my $download_url =
        _extract_link($response_data, 'contentLink') ||
        _extract_link($response_data, 'contentlink')
        or die "Cannot get download url\n".Dumper($response_data);
    return $download_url;
}

sub return {
    my $self = shift;
    my $item_id = shift or croak "No item id";

    my $url = $self->circulation_action_url("/checkouts/$item_id");
    return $self->with_delete_request(
        \&_basic_callback,
        sub {
            my ($data) = @_;
            return 1 if $data->{errorCode} eq "PatronDoesntHaveTitleCheckedOut";
            die ($data->{message} || $data->{errorCode})."\n";
        },
        $url
    );
}

=head1 NATIVE METHODS

=head2 native_patron ()

See L<https://developer.overdrive.com/apis/patron-information>

=cut

sub native_patron {
    my $self = shift;

    my $url = $self->circulation_action_url("");
    my $patron = $self->get_response($url) or return;
    if (my $collection_token = $patron->{collectionToken}) {
        $self->SUPER::collection_token( $collection_token);
    }
    return $patron;
}

=head2 native_holds ()

=head2 native_place_hold ($item_id, $notification_email_address, $auto_checkout)

See L<https://developer.overdrive.com/apis/holds>

=cut

sub native_holds {
    my $self = shift;
    my $url = $self->circulation_action_url("/holds");
    return $self->get_response($url);
}

sub native_place_hold {
    my $self = shift;
    my $item_id = shift or croak "No item id";
    my $email = shift;
    my $auto_checkout = shift;

    my @fields = ( {name => "reserveId", value => $item_id } );
    push @fields, {name => "autoCheckout", value => "true"} if $auto_checkout;
    if ($email) {
        push @fields, {name => "emailAddress", value => $email};
    } else {
        push @fields, {name => "ignoreHoldEmail", value => "true"};
    }

    my $url = $self->circulation_action_url("/holds");
    return $self->with_json_request(
        \&_basic_callback,
        sub {
            my ($data) = @_;
            if ($data->{errorCode} eq "AlreadyOnWaitList") {
                if (my $holds = $self->native_holds) {
                    my $item_id_uc = uc $item_id;
                    foreach (@{ $holds->{holds} || [] }) {
                        if ( uc($_->{reserveId}) eq $item_id_uc ) {
                            $_->{numberOfHolds} = $holds->{totalItems};
                            return $_;
                        }
                    }
                }
            }

            die ($data->{message} || $data->{errorCode})."\n";
        },
        $url,
        {fields => \@fields}
    );
}

=head2 native_checkouts ()

=head2 native_checkout_info ($item_id)

=head2 native_checkout ($item_id, $format, $allow_multiple_format_checkouts)

=head2 native_checkout_formats ($item_id)

=head2 native_lock_format ($item_id, $format)

See L<https://developer.overdrive.com/apis/checkouts>

=cut

sub native_checkouts {
    my $self = shift;

    my $url = $self->circulation_action_url("/checkouts");
    return $self->get_response($url);
}

sub native_checkout_info {
    my $self = shift;
    my $id = shift or croak "No item id";

    my $url = $self->circulation_action_url("/checkouts/$id");
    return $self->get_response($url);
}

sub native_checkout_formats {
    my $self = shift;
    my $id = shift or croak "No item id";

    my $url = $self->circulation_action_url("/checkouts/$id/formats");
    return $self->get_response($url);
}

sub native_checkout {
    my $self = shift;
    my $item_id = shift or croak "No item id";
    my $format = shift;
    my $allow_multi = shift;

    if (my $checkouts = $self->native_checkouts) {
        my $item_id_uc = uc $item_id;
        foreach (@{ $checkouts->{checkouts} || [] }) {
            if ( uc($_->{reserveId}) eq $item_id_uc ) {
                if ($format) {
                    if ($_->{isFormatLockedIn}) {
                        return $_ if lc($_->{formats}[0]{formatType}) eq lc($format);
                        die "Item $item_id has already been locked for different format '$_->{formats}[0]{formatType}'\n"
                            unless $allow_multi;
                    }
#                   else { $self->native_lock_format()? }
                }
#               else { die if !$allow_multi ? }
                return $_;
            }
        }
    }

    my $url = $self->circulation_action_url("/checkouts");
    return $self->with_json_request(
        \&_basic_callback,
        undef,
        $url,
        {fields => _build_checkout_fields($item_id, $format)}
    );
}

sub native_lock_format {
    my $self = shift;
    my $item_id = shift or croak "No item id";
    my $format = shift or croak "No format";

    my $url = $self->circulation_action_url("/checkouts/$item_id/formats");
    return $self->with_json_request(
        \&_basic_callback,
        sub {
            my ($data) = @_;
            die "$format ".($data->{message} || $data->{errorCode})."\n";
        },
        $url,
        {fields => _build_checkout_fields($item_id, $format)}
    );
}

sub _build_checkout_fields {
    my ($id, $format) = @_;
    my @fields = ( {name => "reserveId", value => $id } );
    push @fields, {name => "formatType", value => $format} if $format;
    return \@fields;
}

# Circulation helpers

sub circulation_action_url {
    my $self = shift;
    my $action = shift;
    return $self->_circulation_api_url.$self->API_VERSION."/patrons/me$action";
}

# API helpers

sub _extract_link {
    my ($data, $link) = @_;
    return $data->{links}{$link}->{href};
}

sub _basic_callback { return $_[0]; }

1;

__END__

=head1 LICENSE

Copyright (C) Catalyst IT NZ Ltd
Copyright (C) Bywater Solutions

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Srdjan Janković E<lt>srdjan@catalyst.net.nzE<gt>

=cut
