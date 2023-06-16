package Koha::REST::V1::ERM::UsageDataProviders;

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

use Mojo::Base 'Mojolicious::Controller';

use Koha::ERM::UsageDataProviders;

use Scalar::Util qw( blessed );
use Try::Tiny    qw( catch try );

=head1 API

=head2 Methods

=head3 list

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $usage_data_providers_set = Koha::ERM::UsageDataProviders->new;
        my $usage_data_providers =
          $c->objects->search($usage_data_providers_set);
        if (   $c->validation->output->{"x-koha-embed"}[0]
            && $c->validation->output->{"x-koha-embed"}[0] eq 'counter_files' )
        {
            foreach my $provider (@$usage_data_providers) {
                my $title_dates = _get_earliest_and_latest_dates( 'TR',
                    $provider->{erm_usage_data_provider_id} );
                $provider->{earliest_title} =
                    $title_dates->{earliest_date}
                  ? $title_dates->{earliest_date}
                  : '';
                $provider->{latest_title} =
                    $title_dates->{latest_date}
                  ? $title_dates->{latest_date}
                  : '';

                my $platform_dates = _get_earliest_and_latest_dates( 'PR',
                    $provider->{erm_usage_data_provider_id} );
                $provider->{earliest_platform} =
                    $platform_dates->{earliest_date}
                  ? $platform_dates->{earliest_date}
                  : '';
                $provider->{latest_platform} =
                    $platform_dates->{latest_date}
                  ? $platform_dates->{latest_date}
                  : '';

                my $item_dates = _get_earliest_and_latest_dates( 'IR',
                    $provider->{erm_usage_data_provider_id} );
                $provider->{earliest_item} =
                    $item_dates->{earliest_date}
                  ? $item_dates->{earliest_date}
                  : '';
                $provider->{latest_item} =
                  $item_dates->{latest_date} ? $item_dates->{latest_date} : '';

                my $database_dates = _get_earliest_and_latest_dates( 'DR',
                    $provider->{erm_usage_data_provider_id} );
                $provider->{earliest_database} =
                    $database_dates->{earliest_date}
                  ? $database_dates->{earliest_date}
                  : '';
                $provider->{latest_database} =
                    $database_dates->{latest_date}
                  ? $database_dates->{latest_date}
                  : '';
            }
        }

        return $c->render( status => 200, openapi => $usage_data_providers );
    }
    catch {
        $c->unhandled_exception($_);
    };

}

=head3 get

Controller function that handles retrieving a single Koha::ERM::UsageDataProvider object

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $usage_data_provider_id =
          $c->validation->param('erm_usage_data_provider_id');
        my $usage_data_provider =
          $c->objects->find( Koha::ERM::UsageDataProviders->search,
            $usage_data_provider_id );

        unless ($usage_data_provider) {
            return $c->render(
                status  => 404,
                openapi => { error => "Usage data provider not found" }
            );
        }

        return $c->render(
            status  => 200,
            openapi => $usage_data_provider
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 add

Controller function that handles adding a new Koha::ERM::UsageDataProvider object

=cut

sub add {
    my $c = shift->openapi->valid_input or return;

    return try {
        Koha::Database->new->schema->txn_do(
            sub {

                my $body = $c->validation->param('body');

                my $usage_data_provider =
                  Koha::ERM::UsageDataProvider->new_from_api($body)->store;

                $c->res->headers->location( $c->req->url->to_string . '/'
                      . $usage_data_provider->erm_usage_data_provider_id );
                return $c->render(
                    status  => 201,
                    openapi => $usage_data_provider->to_api
                );
            }
        );
    }
    catch {

        my $to_api_mapping = Koha::ERM::UsageDataProvider->new->to_api_mapping;

        if ( blessed $_ ) {
            if ( $_->isa('Koha::Exceptions::Object::DuplicateID') ) {
                return $c->render(
                    status  => 409,
                    openapi =>
                      { error => $_->error, conflict => $_->duplicate_id }
                );
            }
            elsif ( $_->isa('Koha::Exceptions::Object::FKConstraint') ) {
                return $c->render(
                    status  => 400,
                    openapi => {
                            error => "Given "
                          . $to_api_mapping->{ $_->broken_fk }
                          . " does not exist"
                    }
                );
            }
            elsif ( $_->isa('Koha::Exceptions::BadParameter') ) {
                return $c->render(
                    status  => 400,
                    openapi => {
                            error => "Given "
                          . $to_api_mapping->{ $_->parameter }
                          . " does not exist"
                    }
                );
            }
            elsif ( $_->isa('Koha::Exceptions::PayloadTooLarge') ) {
                return $c->render(
                    status  => 413,
                    openapi => { error => $_->error }
                );
            }
        }

        $c->unhandled_exception($_);
    };
}

=head3 update

Controller function that handles updating a Koha::ERM::UsageDataProvider object

=cut

sub update {
    my $c = shift->openapi->valid_input or return;

    my $usage_data_provider_id =
      $c->validation->param('erm_usage_data_provider_id');
    my $usage_data_provider =
      Koha::ERM::UsageDataProviders->find($usage_data_provider_id);

    unless ($usage_data_provider) {
        return $c->render(
            status  => 404,
            openapi => { error => "Usage data provider not found" }
        );
    }

    return try {
        Koha::Database->new->schema->txn_do(
            sub {

                my $body = $c->validation->param('body');

                $usage_data_provider->set_from_api($body)->store;

                $c->res->headers->location( $c->req->url->to_string . '/'
                      . $usage_data_provider->erm_usage_data_provider_id );
                return $c->render(
                    status  => 200,
                    openapi => $usage_data_provider->to_api
                );
            }
        );
    }
    catch {
        my $to_api_mapping = Koha::ERM::UsageDataProvider->new->to_api_mapping;

        if ( blessed $_ ) {
            if ( $_->isa('Koha::Exceptions::Object::FKConstraint') ) {
                return $c->render(
                    status  => 400,
                    openapi => {
                            error => "Given "
                          . $to_api_mapping->{ $_->broken_fk }
                          . " does not exist"
                    }
                );
            }
            elsif ( $_->isa('Koha::Exceptions::BadParameter') ) {
                return $c->render(
                    status  => 400,
                    openapi => {
                            error => "Given "
                          . $to_api_mapping->{ $_->parameter }
                          . " does not exist"
                    }
                );
            }
            elsif ( $_->isa('Koha::Exceptions::PayloadTooLarge') ) {
                return $c->render(
                    status  => 413,
                    openapi => { error => $_->error }
                );
            }
        }

        $c->unhandled_exception($_);
    };
}

=head3 delete

=cut

sub delete {
    my $c = shift->openapi->valid_input or return;

    my $usage_data_provider_id =
      $c->validation->param('erm_usage_data_provider_id');
    my $usage_data_provider =
      Koha::ERM::UsageDataProviders->find($usage_data_provider_id);
    unless ($usage_data_provider) {
        return $c->render(
            status  => 404,
            openapi => { error => "Usage data provider not found" }
        );
    }

    return try {
        $usage_data_provider->delete;
        return $c->render(
            status  => 204,
            openapi => q{}
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 run

=cut

sub run {
    my $c = shift->openapi->valid_input or return;

    my $udprovider = Koha::ERM::UsageDataProviders->find( $c->validation->param('erm_usage_data_provider_id') );

    unless ($udprovider) {
        return $c->render(
            status  => 404,
            openapi => { error => "Usage data provider not found" }
        );
    }

    return try {
        my $jobs = $udprovider->run;

        return $c->render(
            status  => 200,
            openapi => { jobs => [ @{$jobs} ] }
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 test_connection

=cut

sub test_connection {
    my $c = shift->openapi->valid_input or return;

    my $udprovider = Koha::ERM::UsageDataProviders->find( $c->validation->param('erm_usage_data_provider_id') );

    unless ($udprovider) {
        return $c->render(
            status  => 404,
            openapi => { error => "Usage data provider not found" }
        );
    }
    try {
        my $service_active = $udprovider->test_connection;
        return $c->render(
            status  => 200,
            openapi => $service_active
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 providers_report

=cut

sub providers_report {
    my $c = shift->openapi->valid_input or return;

    return try {

        my $args = $c->validation->output;

        my $usage_data_providers_set = Koha::ERM::UsageDataProviders->new;
        my $usage_data_providers = $c->objects->search( $usage_data_providers_set );

        my @query_params_array;
        my $json = JSON->new;

        if ( ref( $args->{q} ) eq 'ARRAY' ) {
            foreach my $q ( @{ $args->{q} } ) {
                push @query_params_array, $json->decode($q)
                    if $q; 
            }
        }

        my $metric_types = $query_params_array[0][0]->{'erm_usage_titles.erm_usage_muses.metric_type'};

        my @usage_data_provider_report_data;

        for my $usage_data_provider ( @{ $usage_data_providers } ) {

            # Split usage_data_providers into metric_types i.e. one table row per metric_type
            for my $metric_type ( @$metric_types ) {
                my @filtered_title_data;

                for my $title ( @{ $usage_data_provider->{'erm_usage_titles'} }) {
                    my $statistics = $title->{'erm_usage_muses'};
                    my @filtered_statistics = grep { $metric_type eq $_->{metric_type} } @$statistics;

                    my %title_hash = (
                        usage_data_provider_id => $title->{usage_data_provider_id},
                        title_id => $title->{title_id},
                        title => $title->{title},
                        erm_usage_muses => \@filtered_statistics,
                        online_issn => $title->{online_issn},
                        print_issn => $title->{print_issn},
                        title_doi => $title->{title_doi},
                        title_uri => $title->{title_uri},
                        metric_type => $metric_type,
                        publisher => $title->{publisher},
                        publisher_id => $title->{publisher_id},
                    );

                    push @filtered_title_data, \%title_hash;
                }


                my %usage_data_provider_hash = (
                    erm_usage_data_provider_id => $usage_data_provider->{erm_usage_data_provider_id},
                    erm_usage_titles => \@filtered_title_data,
                    aggregator => $usage_data_provider->{aggregator},
                    api_key => $usage_data_provider->{api_key},
                    begin_date => $usage_data_provider->{begin_date},
                    customer_id => $usage_data_provider->{customer_id},
                    description => $usage_data_provider->{description},
                    end_date => $usage_data_provider->{end_date},
                    method => $usage_data_provider->{method},
                    name => $usage_data_provider->{name},
                    report_release => $usage_data_provider->{report_release},
                    report_types => $usage_data_provider->{report_types},
                    requestor_email => $usage_data_provider->{requestor_email},
                    requestor_id => $usage_data_provider->{requestor_id},
                    requestor_name => $usage_data_provider->{requestor_name},
                    service_type => $usage_data_provider->{service_type},
                    service_url => $usage_data_provider->{service_url},
                    metric_type => $metric_type
                );

                push @usage_data_provider_report_data, \%usage_data_provider_hash;
            };
        };

        return $c->render( status => 200, openapi => \@usage_data_provider_report_data );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

1;
