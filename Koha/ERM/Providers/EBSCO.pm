package Koha::ERM::Providers::EBSCO;

use Modern::Perl;

use HTTP::Request;
use LWP::UserAgent;
use JSON qw( from_json decode_json encode_json );
use List::Util qw( first );

use Koha::Exceptions;

use Koha::ERM::EHoldings::Packages;

sub new {
    my $class = shift;
    my $self = {};
    return bless $self, $class;
}

sub config {
    return {
        custid  => C4::Context->preference('ERMProviderEbscoCustomerID') || C4::Context->config('ERMProviderEbscoCustomerID'),
        api_key => C4::Context->preference('ERMProviderEbscoApiKey') || C4::Context->config('ERMProviderEbscoApiKey'),
    };
}

sub build_title {
    my ( $self, $result ) = @_;
    my $title = {
        title_id          => $result->{titleId},
        publication_title => $result->{titleName},
        # date_first_issue_online => ?,
        # num_first_vol_online => ?,
        # num_first_issue_online => ?,
        # date_last_issue_online => ?,
        # num_last_vol_online => ?,
        # num_last_issue_online => ?,
        # title_url => ?,
        # embargo_info => ?,
        # coverage_depth => ?,
        # notes => ?,
        publisher_name => $result->{publisherName},
        publication_type => $result->{pubType},
        # date_monograph_published_print => ?,
        # date_monograph_published_online => ?,
        # monograph_volume => ?,
        # monograph_edition => ?,
        # first_editor => ?,
        # parent_publication_title_id => ?,
        # preceeding_publication_title_id => ?,
        # access_type => ?,
    };
    if ( $result->{contributorsList} ) {
        my @contributors = @{ $result->{contributorsList} };
        my $first_author = first { $_->{type} eq 'author' || $_->{type} eq 'Author' } @contributors;
        if ( $first_author ) {
            $title->{first_author} = $first_author->{contributor};
        }
    }
    for my $identifier ( @{ $result->{identifiersList} } ) {

        # FIXME $identifier->{type} : 0 for ISSN and 1 for ISBN
        if ( $identifier->{subtype} == 1 ) {
            $title->{print_identifier} = $identifier->{id};
        }
        elsif ( $identifier->{subtype} == 2 ) {
            $title->{online_identifier} = $identifier->{id};
        }
    }
    return $title;
}

sub build_vendor {
    my ( $self, $result ) = @_;
    my $vendor = {
        vendor_id    => $result->{vendorId},
        name         => $result->{vendorName},
        package_type => $result->{packageType},
    };
    return $vendor;
}

sub build_package {
    my ( $self, $result ) = @_;
    my $local_package = $self->get_local_package(
        $result->{vendorId} . '-' . $result->{packageId} );
    my $package = {
        package_id   => $result->{vendorId} . '-' . $result->{packageId},
        ( $local_package
            ? ( koha_internal_id => $local_package->package_id )
            : () ),
        name         => $result->{packageName},
        content_type => $result->{contentType}, # This does not exist in /vendors/1/packages/2/titles/3
        created_on   => undef,
        is_selected  => $result->{isSelected},
        package_type => $result->{packageType},
        vendor_id    => $result->{vendorId},
    };
    return $package;
}

sub build_resource {
    my ( $self, $result ) = @_;
    my $resource = {
        resource_id => $result->{vendorId} . '-'
          . $result->{packageId} . '-'
          . $result->{titleId},
        package_id  => $result->{vendorId} . '-' . $result->{packageId},
        title_id    => $result->{titleId},
        is_selected => $result->{isSelected},
        started_on  => $result->{managedCoverageList}->[0]->{beginCoverage},
        ended_on    => $result->{managedCoverageList}->[0]->{endCoverage},
    };
    return $resource;
}

sub build_additional_params {
    my ( $self, $query_params ) = @_;

    my $additional_params;
    if ( $query_params->{q} ) {
        my $q = from_json $query_params->{q};
        while ( my ( $attr, $value ) = each %$q ) {
            $additional_params->{$attr} = $value;
        }
    }

    return $additional_params;
}

sub get_local_package {
    my ( $self, $package_id ) = @_;
    return Koha::ERM::EHoldings::Packages->find(
        { provider => 'ebsco', external_id => $package_id } );
}

sub embed {
    my ( $self, $object, $info, $embed_header ) = @_;
    $embed_header ||= q{};

    my @embed_resources;

    foreach my $embed_req ( split /\s*,\s*/, $embed_header ) {
        if ( $embed_req eq 'vendor.name' ) {
            $object->{vendor} = { name => $info->{vendorName}, };
        }
        elsif ( $embed_req eq 'vendor' ) {
            $object->{vendor} = $self->build_vendor($info);
        }
        elsif ( $embed_req eq 'title' ) {
            $object->{title} = $self->build_title($info);
        }
        elsif ( $embed_req eq 'resources+count' ) {
            $object->{resources_count} = $info->{titleCount};
        }
        elsif ( $embed_req eq 'package' ) {
            $object->{package} = $self->build_package($info);
        }
        elsif ( $embed_req eq 'package.name' ) {
            $object->{package} = { name => $info->{packageName}, };
        }
        elsif ( $embed_req eq 'package_agreements.agreement' ) {
            # How to deal with 'package_agreements.agreement'?
            $object->{package_agreements} = [];
            my $package_id = $info->{vendorId} . '-' . $info->{packageId};
            my $local_package = $self->get_local_package($package_id);
            if ( $local_package ) {
                for my $package_agreement (
                    @{ $local_package->package_agreements->as_list } )
                {
                    push @{ $object->{package_agreements} },
                      {
                        %{ $package_agreement->unblessed },
                        agreement => $package_agreement->agreement->unblessed,
                      };
                }
            }
        }
        if ( $embed_req eq 'resources' || $embed_req eq 'resources.package' ) {
            push @embed_resources, $embed_req;
        }
    }

    if (@embed_resources) {
        for my $r ( @{ $info->{customerResourcesList} } ) {
            my $resource = {};
            for my $embed_req ( @embed_resources ) {
                if ( $embed_req eq 'resources' ) {
                    $resource = $self->build_resource($r);
                }
                elsif ( $embed_req eq 'resources.package' ) {
                    unless ( %$resource ) {
                        $resource = $self->build_resource($r);
                    }
                    $resource->{package} = $self->build_package($r);
                }
            }
            push @{$object->{resources}}, $resource;
        }
    }
    return $object;
}

sub build_query_pagination {
    my ( $self, $params ) = @_;
    my $per_page = $params->{_per_page}
      // C4::Context->preference('RESTdefaultPageSize') // 20;
    if ( $per_page == -1 || $per_page > 100 ) { $per_page = 100; }
    my $page = $params->{_page} || 1;

    return ( $per_page, $page );
}

sub build_query {
    my ( $self, $url, $params ) = @_;

    return $url unless $params && %$params;
    while ( my ( $attr, $value ) = each %$params ) {
        my $their_attr;
        if ( $attr eq 'name' ) {
            $url .= '&search=' . $value;
        }
        elsif ( $attr eq 'content_type' ) {
            $url .= '&contenttype=' . $value;
        }
        elsif ( $attr eq 'selection_type' ) {
            $url .= '&selection=' . $value;
        }
        elsif ( $attr eq 'publication_title' ) {
            $url .= '&search=' . $value;
        }
        elsif ( $attr eq 'publication_type' ) {
            $url .= '&resourcetype=' . $value;
        }
    }
    return $url;
}

sub request {
    my ( $self, $method, $url, $params, $payload ) = @_;

    $url = $self->build_query($url, $params) if $params;

    my $config = $self->config;
    my $base_url = 'https://api.ebsco.io/rm/rmaccounts/' . $config->{custid};
    my $request = HTTP::Request->new(
        $method => $base_url . $url,
        undef, ( $payload ? encode_json($payload) : undef )
    );
    $request->header( 'x-api-key' => $config->{api_key} );
    my $ua = LWP::UserAgent->new;
    my $response = $ua->simple_request($request);
    if ( $response->code >= 400 ) {
        my $result = decode_json( $response->decoded_content );
        my $message;
        if ( ref($result) eq 'ARRAY' ) {
            for my $r (@$result) {
                $message .= $r->{message};
            }
        }
        else {
            $message = $result->{message} || $result->{Message} || q{};
            if ( $result->{errors} ) {
                for my $e ( @{ $result->{errors} } ) {
                    $message .= $e->{message};
                }
            }
        }
        warn sprintf "ERROR - EBSCO API %s returned %s - %s\n", $url, $response->code, $message;
        if ( $response->code == 404 ) {
            Koha::Exceptions::ObjectNotFound->throw($message);
        } else {
            die sprintf "ERROR requesting EBSCO API\n%s\ncode %s: %s\n", $url, $response->code,
              $message;
        }
    } elsif ( $response->code == 204 ) { # No content
        return
    }

    return decode_json( $response->decoded_content );
}

1;
