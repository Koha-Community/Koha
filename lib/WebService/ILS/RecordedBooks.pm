package WebService::ILS::RecordedBooks;

use Modern::Perl;

=encoding utf-8

=head1 NAME

WebService::ILS::RecordedBooks - WebService::ILS module for RecordedBooks services

=head1 SYNOPSIS

    use WebService::ILS::RecordedBooks::Partner;
    or
    use WebService::ILS::RecordedBooks::Patron;

=head1 DESCRIPTION

L<WebService::ILS::RecordedBooks::Partner> - services
that use partner credentials, for any patron

L<WebService::ILS::RecordedBooks::PartnerPatron> - same as above,
except it operates on a single patron account

L<WebService::ILS::RecordedBooks::Patron> - services
that use individual patron credentials, in addition to partner credentials

L<WebService::ILS::RecordedBooks::PartnerPatron> is preferred over
L<WebService::ILS::RecordedBooks::Patron> because the later requires patron
credentials - username and password. However, if you do not know patron's
email or RecordedBooks id (barcode) you are stuck with Patron interface.

See L<WebService::ILS>

=cut

use Carp;
use HTTP::Request::Common;
use URI::Escape;
use JSON qw(to_json);

use parent qw(WebService::ILS::JSON);

use constant API_VERSION => "v1";
use constant BASE_DOMAIN => "rbdigital.com";

=head1 CONSTRUCTOR

=head2 new (%params_hash or $params_hashref)

=head3 Additional constructor params:

=over 12

=item C<ssl>            => if set to true use https

=item C<domain>         => RecordedBooks domain for title url

=back

C<client_id> is either RecordedBooks id (barcode) or email

C<domain> if set is either "whatever.rbdigital.com" or "whatever",
in which case rbdigital.com is appended.

=cut

use Class::Tiny qw(
    ssl
    domain
    _api_base_url
);

__PACKAGE__->_set_param_spec({
    client_id  => { required => 0 },
    library_id => { required => 1 },
    domain     => { required => 0 },
    ssl        => { required => 0, default => 1 },
});

sub BUILD {
    my $self = shift;
    my $params = shift;

    if (my $domain = $self->domain) {
        $self->domain("$domain.".BASE_DOMAIN) unless $domain =~ m/\./;
    }

    my $ssl = $self->ssl;
    my $ua = $self->user_agent;
    $ua->ssl_opts( verify_hostname => 0 ) if $ssl;

    my $api_url = sprintf "%s://api.%s", $ssl ? "https" : "http", BASE_DOMAIN;
    $self->_api_base_url($api_url);
}

sub api_url {
    my $self = shift;
    my $action = shift or croak "No action";

    return sprintf "%s/%s%s", $self->_api_base_url, API_VERSION, $action;
}

sub library_action_base_url {
    my $self = shift;

    return $self->api_url("/libraries/".$self->library_id);
}

sub products_url {
    my $self = shift;
    return $self->library_action_base_url."/search";
}

sub circulation_action_url {
    my $self = shift;
    my $action = shift or croak "No action";

    return $self->circulation_action_base_url(@_).$action;
}

sub _access_auth_string {
    my $self = shift;
    return $self->client_secret;
}

sub native_countries {
    my $self = shift;

    my $url = $self->api_url("/countries");
    return $self->get_without_auth($url);
}

sub native_facets {
    my $self = shift;

    my $url = $self->api_url("/facets");
    return $self->get_response($url);
}


sub native_facet_values {
    my $self = shift;
    my $facet = shift or croak "No facet";

    my $url = $self->api_url("/facets/$facet");
    return $self->get_without_auth($url);
}

sub native_libraries_search {
    my $self = shift;
    my $query = shift or croak "No query";
    my $region = shift;

    my %search_params = ( term => $query );
    $search_params{ar} = $region if $region;
    my $url = $self->api_url("/suggestive/libraries");
    return $self->get_without_auth($url, \%search_params);
}

sub get_without_auth {
    my $self = shift;
    my $url = shift or croak "No url";
    my $get_params = shift; # hash ref

    my $uri = URI->new($url);
    $uri->query_form($get_params) if $get_params;
    my $request = HTTP::Request::Common::GET( $uri );
    my $response = $self->user_agent->request( $request );
    $self->check_response($response);

    return $self->process_json_response($response, sub {
        my ($data) = @_;
        die "No data\n" unless $data;
        return $data;
    });
}

=head1 DISCOVERY METHODS

=head2 facets ()

=head3 Returns a hashref of facet => [values]

=cut

sub facets {
    my $self = shift;

    my $facets = $self->native_facets;
    my %facet_values;
    foreach (@$facets) {
        my $f = $_->{facetToken};
        $facet_values{$f} = [map $_->{valueToken}, @{ $self->native_facet_values($f) }];
    }
    return \%facet_values;
}

=head2 search ($params_hashref)

=head3 Additional input params:

=over 12

=item C<facets> => a hashref of facet values

=back

=cut

my %SORT_XLATE = (
    rating => undef,
    publication_date => undef, # not available
);
sub search {
    my $self = shift;
    my $params = shift || {};

    my $url = $self->products_url;

    if (my $query = delete $params->{query}) {
        $query = join " ", @$query if ref $query;
        $params->{all} = $query;
    }
    if (my $page_size = delete $params->{page_size}) {
        $params->{'page-size'} = $page_size;
    }
    if (my $page_number = delete $params->{page}) {
        die "page_size must be specified for paging" unless $params->{'page-size'};
        $params->{'page-index'} = $page_number - 1;
    }
    if (my $sort = delete $params->{sort}) {
        my $sa = $self->_parse_sort_string($sort, \%SORT_XLATE);
        if (@$sa) {
            my @params = %$params;
            foreach (@$sa) {
                my ($s, $d) = split ':';
                push @params, "sort-by", $s;
                push @params, "sort-order", $d if $d;
            }
            return $self->_search_result_xlate( $self->get_response($url, \@params) );
        }
    }

    return $self->_search_result_xlate( $self->get_response($url, $params) );
}

sub _search_result_xlate {
    my $self = shift;
    my $res = shift or return;

    my $domain = $self->domain;
    return {
        items => [ map {
            my $i = $self->_item_xlate($_->{item});
            $i->{url} ||= "https://$domain/#titles/$i->{isbn}" if $domain;
            $i->{available} = $_->{interest}{isAvailable};
            $i;
        } @{$res->{items} || []} ],
        page_size => $res->{pageSize},
        page => $res->{pageIndex} + 1,
        pages => $res->{pageCount},
    };
}

my %SEARCH_RESULT_ITEM_XLATE = (
    id => "id",
    title => "title",
    subtitle => "subtitle",
    shortDescription => "description",
    mediaType => "media",
    downloadUrl => "url",
    encryptionKey => "encryption_key",
    isbn => "isbn",
    hasDrm => "drm",
    releasedDate => "publication_date",
    size => "size",
    language => "language",
    expiration => "expires",
);
my %ITEM_FILES_XLATE = (
    id => "id",
    filename => "filename",
    display => "title",
    downloadUrl => "url",
    size => "size",
);
sub _item_xlate {
    my $self = shift;
    my $item = shift;

    my $std_item = $self->_result_xlate($item, \%SEARCH_RESULT_ITEM_XLATE);

    if (my $images = delete $item->{images}) { # XXX let's say that caller wouldn't mind
        $std_item->{images} = {map { $_->{name} => $_->{url} } @$images};
    }

    if (my $files = delete $item->{files}) {
        $std_item->{files} = [ map $self->_result_xlate($_, \%ITEM_FILES_XLATE), @$files ];
    }

    my %facets;
    if (my $publisher = delete $item->{publisher}) {
        if (ref $publisher) {
            if (my $f = $publisher->{facet}) {
                $facets{$f} = [$publisher->{token}];
            }
            $publisher = $publisher->{text};
        }
        $std_item->{publisher} = $publisher;
    }
    if (my $authors = delete $item->{authors}) {
        my @a;
        if (ref $authors) {
            foreach (@$authors) {
                push @a, $_->{text} if $_->{text};
                if (my $f = $_->{facet}) {
                    my $f_a = $facets{$f} ||= [];
                    push @$f_a, $_->{token};
                }
            }
        }
        else {
            push @a, $authors;
        }
        $std_item->{author} = join ", ", @a;
    }
    foreach my $v (values %$item) {
        my $ref = ref $v or next;
        $v = [$v] if $ref eq "HASH";
        next unless ref($v) eq "ARRAY";
        foreach (@$v) {
            if (my $f = $_->{facet}) {
                my $f_a = $facets{$f} ||= [];
                push @$f_a, $_->{token};
            }
        }
    }
    $std_item->{facets} = \%facets if keys %facets;

    return $std_item;
}

=head2 named_query_search ($query, $media)

  See C<native_named_query_search()> below for $query, $media

=cut

sub named_query_search {
    my $self = shift;
    return $self->_search_result_xlate( $self->native_named_query_search(@_) );
}

=head2 facet_search ($facets)

  See C<native_facet_search()> below for $facets

=cut

sub facet_search {
    my $self = shift;
    return $self->_search_result_xlate( $self->native_facet_search(@_) );
}

sub item_metadata {
    my $self = shift;
    my $ni = $self->native_item(@_) or return;
    return $self->_item_xlate( $ni->{item} );
}

=head1 CIRCULATION METHOD SPECIFICS

Differences to general L<WebService::ILS> interface

=cut

=head2 holds ()

=head2 place_hold ($isbn)

=head2 remove_hold ($isbn)

=cut

sub holds {
    my $self = shift;

    my $items = $self->native_holds(@_);
    return {
        total => scalar @$items,
        items => [ map {
            my $i = $self->_item_xlate($_);
            $i->{hold_id} = $_->{transactionId};
            $i;
        } @$items ],
    };
}

sub place_hold {
    my $self = shift;
    my $isbn = shift or croak "No isbn";

    my $url = $self->circulation_action_url("/holds/$isbn", @_);
    my $request = HTTP::Request::Common::POST( $url );
    my $response = $self->_request_with_auth($request);
    unless ($response->is_success) {
        $self->process_json_error_response($response, sub {
            my ($data) = @_;
            if (my $message = $data->{message}) {
                return 1 if $message =~ m/already exists/i;
                die $message;
            }
            die $self->_error_from_json($data) || "Cannot place hold: ".to_json($data);
        });
    }

    if (my $holds = $self->holds(@_)) {
        foreach my $i (@{ $holds->{items} }) {
            if ($i->{isbn} eq $isbn) {
                $i->{total} = $holds->{total};
                return $i;
            }
        }
    }

    my $content = $response->decoded_content;
    my $content_type = $response->header('Content-Type');
    my $error;
    if ($content_type && $content_type =~ m!application/json!) {
        if (my $data = eval { from_json( $content ) }) {
            $error = $self->_error_from_json($data);
        }
    }

    die $error || "Cannot place hold:\n$content";
}

sub remove_hold {
    my $self = shift;
    my $isbn = shift or croak "No isbn";

    my $url = $self->circulation_action_url("/holds/$isbn", @_);
    my $request = HTTP::Request::Common::DELETE( $url );
    my $response = $self->_request_with_auth($request);
    unless ($response->is_success) {
        return $self->process_json_error_response($response, sub {
            my ($data) = @_;
            if (my $message = $data->{message}) {
                return 1 if $message =~ m/not exists|expired/i;
                die $message;
            }
            die $self->_error_from_json($data) || "Cannot remove hold: ".to_json($data);
        });
    }
    return 1;
}

=head2 checkouts ()

=head2 checkout ($isbn, $days)

=head2 renew ($isbn)

=head2 return ($isbn)

=cut

sub checkouts {
    my $self = shift;

    my $items = $self->native_checkouts(@_);
    return {
        total => scalar @$items,
        items => [ map {
            my $i = $self->_item_xlate($_);
            $i->{checkout_id} = $_->{transactionId};
            $i;
        } @$items ],
    };
}

sub checkout {
    my $self = shift;
    my $isbn = shift or croak "No isbn";
    my $days = shift;

    if (my $checkouts = $self->checkouts(@_)) {
        foreach my $i (@{ $checkouts->{items} }) {
            if ( $i->{isbn} eq $isbn ) {
                $i->{total} = scalar @{ $checkouts->{items} };
                return $i;
            }
        }
    }

    my $url = $self->circulation_action_url("/checkouts/$isbn", @_);
    $url .= "?days=$days" if $days;
    my $res = $self->with_post_request(
        \&_basic_callback,
        $url
    );

    my $checkouts = $self->checkouts(@_) or die "Cannot checkout, unknown error";
    foreach my $i (@{ $checkouts->{items} }) {
        if ($i->{isbn} eq $isbn) {
            $i->{total} = scalar @{ $checkouts->{items} };
            return $i;
        }
    }
    die $res->{message} || "Cannot checkout, unknown error";
}

sub renew {
    my $self = shift;
    my $isbn = shift or croak "No isbn";

    my $url = $self->circulation_action_url("/checkouts/$isbn", @_);
    my $res = $self->with_put_request(
        \&_basic_callback,
        $url
    );

    my $checkouts = $self->checkouts(@_) or die "Cannot renew, unkmown error";
    foreach my $i (@{ $checkouts->{items} }) {
        if ($i->{isbn} eq $isbn) {
            $i->{total} = scalar @{ $checkouts->{items} };
            return $i;
        }
    }
    die $res->{output} || "Cannot renew, unknown error";
}

sub return {
    my $self = shift;
    my $isbn = shift or croak "No isbn";

    my $url = $self->circulation_action_url("/checkouts/$isbn", @_);
    my $request = HTTP::Request::Common::DELETE( $url );
    my $response = $self->_request_with_auth($request);
    unless ($response->is_success) {
        return $self->process_json_error_response($response, sub {
            my ($data) = @_;
            if (my $message = $data->{message}) {
                return 1 if $message =~ m/not exists|expired/i;
                die $message;
            }
            die "Cannot return: ".to_json($data);
        });
    }
    return 1;
}

=head1 NATIVE METHODS

=head2 native_search ($params_hashref)

See L<https://developer.overdrive.com/apis/search>

=cut

sub native_search {
    my $self = shift;
    my $search_params = shift;

    return $self->get_response($self->products_url, $search_params);
}

=head2 native_named_query_search ($query, $media)

  $query can be one of 'bestsellers', 'most-popular', 'newly-added'
  $media can be 'eaudio' or 'ebook'

=cut

my @MEDIA = qw( eaudio ebook );
my @NAMED_QUERY = ( 'bestsellers', 'most-popular', 'newly-added' );
sub native_named_query_search {
    my $self = shift;
    my $query = shift or croak "No query";
    my $media = shift or croak "No media";

    croak "Invalid media $media - should be one of ".join(", ", @MEDIA)
      unless grep { $_ eq $media } @MEDIA;
    croak "Invalid named query $query - should be one of ".join(", ", @NAMED_QUERY)
      unless grep { $_ eq $query } @NAMED_QUERY;

    my $url = $self->products_url."/$media/$query";
    return $self->get_response($url);
}

=head2 native_facet_search ($facets)

  $facets can be either:
  * a hashref of facet => [values],
  * an arrayref of values
  * a single value

=cut

sub native_facet_search {
    my $self = shift;
    my $facets = shift or croak "No facets";
    $facets = [$facets] unless ref $facets;

    my $url = $self->products_url;
    if (ref ($facets) eq "ARRAY") {
        $url = join "/", $url, @$facets;
        undef $facets;
    }
    return $self->get_response($url, $facets);
}

# Item API

=head2 native_item ($isbn)

=head2 native_item_summary ($isbn)

=head3 Returns subset of item fields, with addition of summary field

=cut

sub native_item {
    my $self = shift;
    my $isbn = shift or croak "No isbn";

    my $url = $self->title_url($isbn);
    return $self->get_response($url);
}

sub native_item_summary {
    my $self = shift;
    my $isbn = shift or croak "No isbn";

    my $url = $self->title_url("$isbn/summary");
    return $self->get_response($url);
}

=head2 native_holds ()

See L<http://developer.rbdigital.com/endpoints/title-holds>

=cut

sub native_holds {
    my $self = shift;

    my $url = $self->circulation_action_url("/holds/all", @_);
    return $self->get_response($url);
}

=head2 native_checkouts ()

=cut

sub native_checkouts {
    my $self = shift;

    my $url = $self->circulation_action_url("/checkouts/all", @_);
    return $self->get_response($url);
}

# Utility methods

sub _basic_callback { return $_[0]; }

sub get_response {
    my $self = shift;
    my $url = shift or croak "No url";
    my $get_params = shift; # hash ref

    return $self->with_get_request(\&_basic_callback, $url, $get_params);
}

sub _error_from_json {
    my $self = shift;
    my $data = shift or croak "No json data";
    return join " ", grep defined, $data->{errorCode}, $data->{message};
}

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
