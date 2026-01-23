package WebService::ILS;

use Modern::Perl;

our $VERSION = "0.18";

=encoding utf-8

=head1 NAME

WebService::ILS - Standardised library discovery/circulation services

=head1 SYNOPSIS

    use WebService::ILS::<Provider Subclass>;
    my $ils = WebService::ILS::<Provider Subclass>->new({
        client_id => $client_id,
        client_secret => $client_secret
    });
    my %search_params = (
        query => "Some keyword",
        sort => "rating",
    );
    my $result = $ils->search(\%search_params);
    foreach (@{ $result->{items} }) {
        ...
    }
    foreach (2..$result->{pages}) {
        $search_params{page} = $_;
        my $next_results = $ils->search(\%search_params);
        ...
    }

    or

    my $native_result = $ils->native_search(\%native_search_params);

=head1 DESCRIPTION

WebService::ILS is an attempt to create a standardised interface for
online library services providers.

In addition, native API interface is provided.

Here we will describe constructor parameters and methods common to all
service providers. Diversions and native interfaces are documented
in corresponding modules.

=head2 Supported service providers

=over 4

=item B<WebService::ILS::OverDrive::Library>

OverDrive Library API L<https://developer.overdrive.com/discovery-apis>

=item B<WebService::ILS::OverDrive::Patron>

OverDrive Circulation API L<https://developer.overdrive.com/circulation-apis>

=back

=head1 INTERFACE

=head2 Error handling

Method calls will die on error. $@ will contain a multi-line string.
See C<error_message()> below.

=head2 Item record

Item record is returned by many methods, so we specify it here.

=over 12

=item C<id>

=item C<isbn>

=item C<title>

=item C<subtitle>

=item C<description>

=item C<author>

=item C<publisher>

=item C<publication_date>

=item C<language>

=item C<rating>         => user ratings metrics

=item C<popularity>     => checkout metrics

=item C<subjects>       => subject categories (tags)

=item C<facets>         => a hashref of facet => [values]

=item C<media>          => book, e-book, video, audio etc

=item C<formats>        => an arrayref of available formats

=item C<images>         => a hashref of size => url

=item C<encryption_key> => for decryption purposes

=item C<drm>            => subject to drm

=back

Not all fields are available for all service providers.
Field values are not standardised.

=cut

use Carp;
use Hash::Merge;
use Params::Check;
use LWP::UserAgent;
use HTTP::Status qw(:constants);
use MIME::Base64 qw();
use JSON qw(from_json);

our $DEBUG;

my %CONSTRUCTOR_PARAMS_SPEC;
sub _set_param_spec {
    my $class = shift;
    my $param_spec = shift;

    $CONSTRUCTOR_PARAMS_SPEC{$class} = $param_spec;
}
sub _get_param_spec {
    my $class = shift;
    if (my $ref = ref($class)) {
        $class = $ref;
    }

    my $p_s = $CONSTRUCTOR_PARAMS_SPEC{$class};
    return $p_s if $class eq __PACKAGE__;

    (my $superclass = $class) =~ s/::\w+$//o;
    return Hash::Merge::merge($p_s || {}, $superclass->_get_param_spec);
}

=head1 CONSTRUCTOR

=head2 new (%params_hash or $params_hashref)

=head3 Client (vendor) related constructor params, given by service provider:

=over 12

=item C<client_id>     => client (vendor) identifier

=item C<client_secret> => secret key (password)

=item C<library_id>    => sometimes service providers provide access
                          to different "libraries"

=back

=head3 General constructor params:

=over 12

=item C<user_agent>        => LWP::UserAgent or a derivative;
                              usually not needed, one is created for you.

=item C<user_agent_params> => LWP::UserAgent constructor params
                              so you don't need to create user agent yourself

=item C<access_token>      => as returned from the provider authentication system

=item C<access_token_type> => as returned from the provider authentication system

=back

These are also read-only attributes

Not all of client/library params are required for all service providers.

=cut

use Class::Tiny qw(
    user_agent
    client_id client_secret library_id
    access_token access_token_type
);

__PACKAGE__->_set_param_spec({
    client_id         => { required => 1, defined => 1 },
    client_secret     => { required => 1, defined => 1 },
    library_id        => { required => 0, defined => 1 },
    access_token      => { required => 0 },
    access_token_type => { required => 0 },
    user_agent        => { required => 0 },
    user_agent_params => { required => 0 },
});

sub BUILDARGS {
    my $self = shift;
    my $params = shift || {};
    if (!ref( $params )) {
        $params = {$params, @_};
    }

    local $Params::Check::WARNINGS_FATAL = 1;
    $params = Params::Check::check($self->_get_param_spec, $params)
        or croak "Invalid parameters: ".Params::Check::last_error();
    return $params;
}

sub BUILD {
    my $self = shift;
    my $params = shift;

    my $ua_params = delete $params->{user_agent_params} || {};
    $self->user_agent( LWP::UserAgent->new(%$ua_params) ) unless $self->user_agent;
    delete $self->{user_agent_params};
}

=head1 ATTRIBUTES

=head2 user_agent

As provided to constructor, or auto created. Useful if one wants to
change user agent attributes on the fly, eg

    $ils->user_agent->timeout(120);

=head1 DISCOVERY METHODS

=head2 search ($params_hashref)

=head3 Input params:

=over 12

=item C<query>     => query (search) string

=item C<page_size> => number of items per results page

=item C<page>      => wanted page number

=item C<sort>      => resultset sort option (see below)

=back

Sort  options are either an array or a comma separated string of options:

=over 12

=item C<publication_date> => date title was published

=item C<available_date>   => date title became available for users

=item C<rating>           => number of items per results page

=back

Sort order can be added after option with ":", eg
"publication_date:desc,rating:desc"

=head3 Returns search results record:

=over 12

=item C<items>      => an array of item records

=item C<page_size>  => number of items per results page

=item C<page>       => results page number

=item C<pages>      => total number of pages

=item C<total>      => total number of items found by the search

=back

=head2 item_metadata ($item_id)

=head3 Returns item record

=head2 item_availability ($item_id)

=head3 Returns item availability record:

=over 12

=item C<id>

=item C<available>        => boolean

=item C<copies_available> => number of copies available

=item C<copies_owned>     => number of copies owned

=item C<type>             => availability type, provider dependent

=back

Not all fields are available for all service providers.
For example, some will provide "copies_available", making "available"
redundant, whereas others will just provide "available".

=head2 is_item_available ($item_id)

=head3 Returns boolean

Simplified version of L<item_availability()>

=cut

sub search {
    die "search() not implemented";
}

# relevancy availability available_date title author popularity rating price publisher publication_date
sub _parse_sort_string {
    my $self = shift;
    my $sort = shift or croak "No sort options";
    my $xlate_table = shift || {};
    my $camelise = shift;

    $sort = [split /\s*,\s*/, $sort] unless ref $sort;

    foreach (@$sort) {
        my ($s,$d) = split ':';
        if (exists $xlate_table->{$s}) {
            next unless $xlate_table->{$s};
            $_ = $xlate_table->{$s};
        }
        else {
            $_ = $s;
        }
        #   join('', map{ ucfirst $_ } split(/(?<=[A-Za-z])_(?=[A-Za-z])|\b/, $s));
        $_ = join '', map ucfirst, split /(?<=[A-Za-z])_(?=[A-Za-z])|\b/ if $camelise;
        $_ = "$_:$d" if $d;
    }

    return $sort;
}

sub item_metadata {
    die "item_metadata() not implemented";
}

sub item_availability {
    die "item_availability() not implemented";
}

=head1 INDIVIDUAL USER AUTHENTICATION AND METHODS

=head2 user_id / password

Provider authentication API is used to get an authorized session.

=head3 auth_by_user_id($user_id, $password)

An example:

    my $ils = WebService::ILS::Provider({
        client_id => $client_id,
        client_secret => $client_secret,
    });
    eval { $ils->auth_by_user_id( $user_id, $password ) };
    if ($@) { some_error_handling(); return; }
    $session{ils_access_token} = $ils->access_token;
    $session{ils_access_token_type} = $ils->access_token_type;
    ...
    Somewhere else in your app:
    my $ils = WebService::ILS::Provider({
        client_id => $client_id,
        client_secret => $client_secret,
        access_token => $session{ils_access_token},
        access_token_type => $session{ils_access_token_type},
    });

    my $checkouts = $ils->checkouts;

=head2 Authentication at the provider

User is redirected to the provider authentication url, and after
authenticating at the provider redirected back with some kind of auth token.
Requires url to handle return redirect from the provider.

It can be used as an alternative to FB and Google auth.

This is just to give an idea, specifics heavily depend on the provider

=head3 auth_url ($redirect_back_uri)

Returns provider authentication url to redirect to

=head3 auth_token_param_name ()

Returns auth code url param name

=head3 auth_by_token ($provider_token)

An example:

    my $ils = WebService::ILS::Provider({
        client_id => $client_id,
        client_secret => $client_secret,
    });
    my $redirect_url = $ils->auth_url("http://myapp.com/ils-auth");
    $response->redirect($redirect_url);
    ...
    After successful authentication at the provider, provider redirects
    back to specified app url (http://myapp.com/ils-auth)

    /ils-auth handler:
    my $auth_token = $req->param( $ils->auth_token_param_name )
        or some_error_handling(), return;
    local $@;
    eval { $ils->auth_by_token( $auth_token ) };
    if ($@) { some_error_handling(); return; }
    $session{ils_access_token} = $ils->access_token;
    $session{ils_access_token_type} = $ils->access_token_type;
    ...
    Somewhere else in your app:
    passing access token to the constructor as above

=cut

=head1 CIRCULATION METHODS

=head2 patron ()

=head3 Returns patron record:

=over 12

=item C<id>

=item C<active>            => boolean

=item C<copies_available>  => number of copies available

=item C<checkout_limit>    => number of checkouts allowed

=item C<hold_limit>        => number of holds allowed

=back

=head2 holds ()

=head3 Returns holds record:

=over 12

=item C<total>             => number of items on hold

=item C<items>             => list of individual items

=back

In addition to Item record fields described above,
item records will have:

=over 12

=item C<placed_datetime>   => hold timestamp, with or without timezone

=item C<queue_position>    => user's position in the waiting queue,
                              if available

=back

=head2 place_hold ($item_id)

=head3 Returns holds item record (as described above)

In addition, C<total> field will be incorporated as well.

=head2 remove_hold ($item_id)

=head3 Returns true to indicate success

Returns true in case user does not have a hold on the item.
Throws exception in case of any other failure.

=head2 checkouts ()

=head3 Returns checkout record:

=over 12

=item C<total>             => number of items on hold

=item C<items>             => list of individual items

=back

In addition to Item record fields described above,
item records will have:

=over 12

=item C<checkout_datetime> => checkout timestamp, with or without timezone

=item C<expires>           => date (time) checkout expires

=item C<url>               => download/stream url

=item C<files>             => an arrayref of downloadable file details
                              title, url, size

=back

=head2 checkout ($item_id)

=head3 Returns checkout item record (as described above)

In addition, C<total> field will be incorporated as well.

=head2 return ($item_id)

=head3 Returns true to indicate success

Returns true in case user does not have the item checked out.
Throws exception in case of any other failure.

=cut

=head1 NATIVE METHODS

All Discovery and Circulation methods (with exception of remove_hold()
and return(), where it does not make sense) have native_*() counterparts,
eg native_search(), native_item_availability(), native_checkout() etc.

In case of single item methods, native_item_availability(),
native_checkout() etc, they take item_id as parameter. Otherwise, it's a
hashref of HTTP request params (GET or POST).

Return value is a record as returned by API.

Individual provider subclasses provide additional provider specific
native methods.

=head1 UTILITY METHODS

=head2 Error constants

=over 4

=item C<ERROR_ACCESS_TOKEN>

=item C<ERROR_NOT_AUTHENTICATED>

=back

=cut

use constant ERROR_ACCESS_TOKEN => "Error: Authorization Failed";
use constant ERROR_NOT_AUTHENTICATED => "Error: User Not Authenticated";

sub invalid_response_exception_string {
    my $self = shift;
    my $response = shift;

    return join "\n",
        $response->message,
        "Request:" => $response->request->as_string,
        "Response:" => $response->as_string
    ;
}

sub check_response {
    my $self = shift;
    my $response = shift;

    die $self->invalid_response_exception_string($response) unless $response->is_success;
}

=head2 error_message ($exception_string)

=head3 Returns error message probably suitable for displaying to the user

Example:

    my $res = eval { $ils->checkout($id) };
    if ($@) {
        my $msg = $ils->error_message($@);
        display($msg);
        log_error($@);
    }

=head2 is_access_token_error ($exception_string)

=head3 Returns true if the error is access token related

=head2 is_not_authenticated_error ($exception_string)

=head3 Returns true if the error is "Not authenticated"

=cut

sub error_message {
    my $self = shift;
    my $die_string = shift or return;
    $die_string =~ m/(.*?)\n/o;
    (my $msg = $1 || $die_string) =~ s! at /.* line \d+\.$!!;
    return $msg;
}

sub is_access_token_error {
    my $self = shift;
    my $die_string = shift or croak "No error message";
    return $self->error_message($die_string) eq ERROR_ACCESS_TOKEN;
}

sub is_not_authenticated_error {
    my $self = shift;
    my $die_string = shift or croak "No error message";
    return $self->error_message($die_string) eq ERROR_NOT_AUTHENTICATED;
}

# Client access authorization
#
sub _request_with_auth {
    my $self = shift;
    my $request = shift or croak "No request";

    my $has_token = $self->access_token;
    my $response = $self->_request_with_token($request);
    # token expired?
    $response = $self->_request_with_token($request, "FRESH TOKEN")
      if $response->code == HTTP_UNAUTHORIZED && $has_token;
    return $response;
}

sub make_access_token_request {
    die "make_access_token_request() not implemented";
}

sub _request_access_token {
    my $self = shift;
    my $request = shift or croak "No request";

    $request->header(
        Authorization => "Basic " . $self->_access_auth_string
    );

    my $response = $self->user_agent->request( $request );
    # XXX check content type
    return $self->process_json_response(
        $response,
        sub {
            my ($data) = @_;

            my ($token, $token_type) = $self->_extract_token_from_response($data);
            $token or die "No access token\n";
            $self->access_token($token);
            $self->access_token_type($token_type || 'Bearer');
            return $data;
        },
        sub {
            my ($data) = @_;

            die join "\n", ERROR_ACCESS_TOKEN, $self->_error_from_json($data) || $response->decoded_content;
        }
    );
}

sub _access_auth_string {
    my $self = shift;
    return MIME::Base64::encode( join(":", $self->client_id, $self->client_secret) );
}

sub _extract_token_from_response {
    my $self = shift;
    my $data = shift;

    return ($data->{access_token}, $data->{token_type});
}

sub _request_with_token {
    my $self = shift;
    my $request = shift or croak "No request";
    my $force_fresh = shift;

    my $token = $force_fresh ? undef : $self->access_token;
    unless ($token) {
        my $request = $self->make_access_token_request;
        $self->_request_access_token($request);
        $token = $self->access_token;
    }
    die "No access token" unless $token;
    my $token_type = $self->access_token_type;

    $request->header( Authorization => "$token_type $token" );
    return $self->user_agent->request( $request );
}

# Strictly speaking process_json_response() and process_json_error_response()
# should go to ::JSON. However, JSON is used for authentication services even for
# APIs that are XML, so need to be available
sub process_json_response {
    my $self = shift;
    my $response = shift or croak "No response";
    my $success_callback = shift;
    my $error_callback = shift;

    unless ($response->is_success) {
        return $self->process_json_error_response($response, $error_callback);
    }

    my $content_type = $response->header('Content-Type');
    die "Invalid Content-Type\n".$response->as_string
        unless $content_type && $content_type =~ m!application/json!;
    my $content = $response->decoded_content
        or die $self->invalid_response_exception_string($response);

    local $@;

    my $data = $content ? eval { from_json( $content ) } : {};
    die "$@\nResponse:\n".$response->as_string if $@;

    return $data unless $success_callback;

    my $res = eval {
        $success_callback->($data);
    };
    die "$@\nResponse:\n$content" if $@;
    return $res;
}

sub process_json_error_response {
    my $self = shift;
    my $response = shift or croak "No response";
    my $error_callback = shift;

    my $content_type = $response->header('Content-Type');
    if ($content_type && $content_type =~ m!application/json!) {
        my $content = $response->decoded_content
            or die $self->invalid_response_exception_string($response);

        my $data = eval { from_json( $content ) };
        die $content || $self->invalid_response_exception_string($response) if $@;

        if ($error_callback) {
            return $error_callback->($data);
        }

        die $self->_error_from_json($data) || "Invalid response:\n$content";
    }
    die $self->invalid_response_exception_string($response);
}

sub _error_from_json {};

# wrapper around error response handlers to include some debugging if the debug flag is set
sub _error_result {
    my $self = shift;
    my $process_sub = shift or croak "No process sub";
    my $request = shift or croak "No HTTP request";
    my $response = shift or croak "No HTTP response";

    return $process_sub->() unless $DEBUG;

    local $@;
    my $ret = eval { $process_sub->() };
    die join "\n", $@, "Request:", $request->as_string, "Response:", $response->as_string
        if $@;
    return $ret;
}

sub _result_xlate {
    my $self = shift;
    my $res = shift;
    my $xlate_table = shift;

    return {
        map {
            my $val = $res->{$_};
            defined($val) ? ($xlate_table->{$_} => $val) : ()
        } keys %$xlate_table
    };
}


=head1 TODO

Federated search

=cut

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
