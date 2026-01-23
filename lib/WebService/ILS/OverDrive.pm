package WebService::ILS::OverDrive;

use Modern::Perl;

=encoding utf-8

=head1 NAME

WebService::ILS::OverDrive - WebService::ILS module for OverDrive services

=head1 SYNOPSIS

    use WebService::ILS::OverDrive::Library;
    or
    use WebService::ILS::OverDrive::Patron;

=head1 DESCRIPTION

L<WebService::ILS::OverDrive::Library> - anonymous discovery
services - no individual user credentials required

L<WebService::ILS::OverDrive::Patron> - discovery and circulation
services that require individual user credentials

See L<WebService::ILS>

=cut

use Carp;
use HTTP::Request::Common;
use URI::Escape;

use parent qw(WebService::ILS::JSON);

use constant API_VERSION => "v1";

use constant DISCOVERY_API_URL => "http://api.overdrive.com/";
use constant TEST_DISCOVERY_API_URL => "http://integration.api.overdrive.com/";

=head1 CONSTRUCTOR

=head2 new (%params_hash or $params_hashref)

=head3 Additional constructor params:

=over 10

=item C<test> => if set to true use OverDrive test API urls

=back

=cut

use Class::Tiny qw(
    collection_token
    test
), {
    _discovery_api_url => sub { $_[0]->test ? TEST_DISCOVERY_API_URL : DISCOVERY_API_URL },
};

__PACKAGE__->_set_param_spec({
    test       => { required => 0 },
});

=head1 DISCOVERY METHODS

=head2 search ($params_hashref)

=head3 Additional input params:

=over 16

=item C<no_details> => if true, no metadata calls will be made for result items;

only id, title, rating and media will be available

=back

=cut

my %SORT_XLATE = (
    available_date => "dateadded",
    rating => "starrating",
    publication_date => undef, # not available
);
sub search {
    my $self = shift;
    my $params = shift || {};

    my $short_response = delete $params->{no_details};

    my $url = $self->products_url;

    if (my $query = delete $params->{query}) {
        $query = join " ", @$query if ref $query;
        $params->{q} = $query;
    }
    my $page_size = delete $params->{page_size};
    $params->{limit} = $page_size if $page_size;
    if (my $page_number = delete $params->{page}) {
        croak "page_size must be specified for paging" unless $params->{limit};
        $params->{offset} = ($page_number - 1)*$page_size;
    }
    if (my $sort = delete $params->{sort}) {
        $params->{sort} = join ",", @{ $self->_parse_sort_string($sort, \%SORT_XLATE) };
    }
    $params->{formats} = join ",", @{$params->{formats}} if ref $params->{formats};

    my $res = $self->get_response($url, $params);
    my @items;
    foreach (@{$res->{products} || []}) {
        my $item;
        if ($short_response) {
            $item = $self->_item_xlate($_);
        } else {
            my $native_metadata = $self->native_item_metadata($_) or next;
            $item = $self->_item_metadata_xlate($native_metadata);
        }
        next unless $item;
        push @items, $item;
    }
    my $tot = $res->{totalItems};
    my %ret = (
        total => $tot,
        items => \@items,
    );
    if (my $page_size = $res->{limit}) {
        my $pages = int($tot/$page_size);
        $pages++ if $tot > $page_size*$pages;
        $ret{pages} = $pages;
        $ret{page_size} = $page_size;
        $ret{page} = $res->{offset}/$page_size + 1;
    }
    return \%ret;
}

my %SEARCH_RESULT_ITEM_XLATE = (
    id => "id",
    title => "title",
    subtitle => "subtitle",
    starRating => "rating",
    mediaType => "media",
);
sub _item_xlate {
    my $self = shift;
    my $item = shift;

    my $std_item = $self->_result_xlate($item, \%SEARCH_RESULT_ITEM_XLATE);

    if (my $formats = $item->{formats}) {
        $std_item->{formats} = [map $_->{id}, @$formats];
    }

    if (my $images = $item->{images}) {
        $std_item->{images} = {map { $_ => $images->{$_}{href} } keys %$images};
    }

    # XXX
    #if (my $details = $item->{contentDetails}) {
    #    $std_item->{details_url} = $details->{href};
    #}

    return $std_item;
}

my %METADATA_XLATE = (
    id => "id",
    mediaType => "media",
    title => "title",
    publisher => "publisher",
    shortDescription => "subtitle",
    starRating => "rating",
    popularity => "popularity",
);
sub item_metadata {
    my $self = shift;
    my $id = shift or croak "No item id";
    my $native_metadata = $self->get_response($self->products_url."/$id/metadata");
    return $self->_item_metadata_xlate($native_metadata);
}

sub _item_metadata_xlate {
    my $self = shift;
    my $metadata = shift or croak "No native metadata";

    my $item = $self->_result_xlate($metadata, \%METADATA_XLATE);

    my @authors;
    foreach (@{ $metadata->{creators} }) {
        push @authors, $_->{name} if $_->{role} eq "Author";
    }
    $item->{author} = join ", ", @authors;

    if (my $images = $metadata->{images}) {
        $item->{images} = {map { $_ => $images->{$_}{href} } keys %$images};
    }

    if (my $languages = $metadata->{languages}) {
        $item->{languages} = [map $_->{name}, @$languages];
    }

    if (my $subjects = $metadata->{subjects}) {
        $item->{subjects} = [map $_->{value}, @$subjects];
    }

    if (my $formats = $metadata->{formats}) {
        $item->{formats} = [map $_->{id}, @$formats];
    }

    return $item;
}

my %AVAILABILITY_RESULT_XLATE = (
    id => "id",
    available => "available",
    copiesAvailable => "copies_available",
    copiesOwned => "copies_owned",
    availabilityType => "type",
);
sub item_availability {
    my $self = shift;
    my $id = shift or croak "No item id";
    return $self->_result_xlate(
        $self->get_response($self->products_url."/$id/availability"),
        \%AVAILABILITY_RESULT_XLATE
    );
}

sub is_item_available {
    my $self = shift;
    my $id = shift or croak "No item id";
    my $type = shift;

    my $availability = $self->item_availability($id) or return;
    return unless $availability->{available};
    return !$type || $type eq $availability->{type};
}

=head1 NATIVE METHODS

=head2 native_search ($params_hashref)

See L<https://developer.overdrive.com/apis/search>

=head2 native_search_[next|prev|first|last] ($data_as returned_by_native_search*)

For iterating through search result pages. Each native_search_*() method
accepts record returned by any native_search*() method as input.

Example:

    my $res = $od->native_search({q => "Dogs"});
    while ($res) {
        do_something($res);
        $res = $od->native_search_next($res);
    }
    or
    my $res = $od->native_search({q => "Dogs"});
    my $last = $od->native_search_last($res);
    my $next_to_last = $od->native_search_prev($last);
    my $first = $od->native_search_first($next_to_last)
    # Same as $od->native_search_first($last)
    # Same as $res

=cut

# params: q, limit, offset, formats, sort ? availability
sub native_search {
    my $self = shift;
    my $search_params = shift;

    return $self->get_response($self->products_url, $search_params);
}

foreach my $f (qw(next prev first last)) {
    no strict 'refs';
    my $method = "native_search_$f";
    *$method = sub {
        my $self = shift;
        my $search_data = shift or croak "No search result data";
        my $url = _extract_link($search_data, $f) or return;
        return $self->get_response($url);
    }
}

# Item API

=head2 native_item_metadata ($item_data as returned by native_search*)

=head2 native_item_availability ($item_data as returned by native_search*)

Example:

    my $res = $od->native_search({q => "Dogs"});
    foreach (@{ $res->{products} }) {
        my $meta = $od->native_item_metadata($_);
        my $availability = $od->native_item_availability($_);
        ...
    }

=cut

sub native_item_metadata {
    my $self = shift;
    my $item = shift or croak "No item record";

    my $url = _extract_link($item, 'metadata') or die "No metadata link\n";
    return $self->get_response($url);
}

sub native_item_availability {
    my $self = shift;
    my $item = shift or croak "No item record";
    return $self->get_response(_extract_link($item, 'availability'));
}

# Discovery helpers

sub discovery_action_url {
    my $self = shift;
    my $action = shift;
    return $self->_discovery_api_url.$self->API_VERSION.$action;
}

sub products_url {
    my $self = shift;

    my $collection_token = $self->collection_token or die "No collection token";

    if ($collection_token) {
        return $self->_discovery_api_url.$self->API_VERSION."/collections/$collection_token/products";
    }
}

# API helpers

sub _extract_link {
    my ($data, $link) = @_;
    my $href = $data->{links}{$link}{href}
        or croak "No '$link' url in data";
}

# Utility methods

sub _basic_callback { return $_[0]; }

# This is not exatly how we meant to use with_get_request()
# ie processing should be placed within the callback.
# However, if all goes well, it is faster (from the development perspective)
# this way.
sub get_response {
    my $self = shift;
    my $url = shift or croak "No url";
    my $get_params = shift; # hash ref

    return $self->with_get_request(\&_basic_callback, $url, $get_params);
}

sub _error_from_json {
    my $self = shift;
    my $data = shift or croak "No json data";
    my $error = join " ", grep defined($_), $data->{errorCode}, $data->{error_description} || $data->{error} || $data->{message} || $data->{Message};
    $error = "$error\n" if $error; # strip code line when dying
    return $error;
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
