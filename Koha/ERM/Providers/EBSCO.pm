package Koha::ERM::Providers::EBSCO;

use Modern::Perl;

use HTTP::Request;
use LWP::UserAgent;
use JSON qw( decode_json );
use List::Util qw( first );

use Koha::Exceptions;

sub new {
    my $class = shift;
    my $self = {};
    return bless $self, $class;
}

sub config {
    return {
        custid  => C4::Context->preference('ERMProviderEbscoCustomerID'),
        api_key => C4::Context->preference('ERMProviderEbscoApiKey'),
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
            $title->{first_author} = $first_author->{contributor}
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
        vendor_id => $result->{vendorId},
        name      => $result->{vendorName},
    };
    return $vendor;
}

sub build_package {
    my ( $self, $result ) = @_;
    my $package = {
        package_id => $result->{packageId},
        name       => $result->{packageName},
    };
    return $package;
}

sub build_resource {
    my ( $self, $result ) = @_;
    my $resource = {
        resource_id  => $result->{vendorId} . '-' . $result->{packageId} . '-'. $result->{titleId},
        is_selected  => $result->{isSelected},
    }
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
    my ( $self, $method, $url, $params ) = @_;

    $url = $self->build_query($url, $params) if $params;

    warn $url;
    my $config = $self->config;
    my $base_url = 'https://api.ebsco.io/rm/rmaccounts/' . $config->{custid};
    my $request = HTTP::Request->new( $method => $base_url . $url);
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
    }
    return decode_json( $response->decoded_content );
}

1;
