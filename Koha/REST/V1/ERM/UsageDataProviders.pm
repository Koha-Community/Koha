package Koha::REST::V1::ERM::UsageDataProviders;

# Copyright 2023 PTFS Europe

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
use Koha::ERM::MonthlyUsages;

use Scalar::Util qw( blessed );
use Try::Tiny    qw( catch try );

=head1 API

=head2 Methods

=head3 list

=cut

sub list {
    my $c = shift->openapi->valid_input or return;
    use Data::Dumper;

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

    my $body       = $c->validation->param('body');
    my $begin_date = $body->{begin_date};
    my $end_date   = $body->{end_date};

    unless ( $begin_date lt $end_date ) {
        return $c->render(
            status  => 400,
            openapi => { error => "Begin date must be before end date" }
        );
    }

    my $udprovider = Koha::ERM::UsageDataProviders->find( $c->validation->param('erm_usage_data_provider_id') );

    unless ($udprovider) {
        return $c->render(
            status  => 404,
            openapi => { error => "Usage data provider not found" }
        );
    }

    return try {
        my $jobs = $udprovider->run( { begin_date => $begin_date, end_date => $end_date } );

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

=head3 _get_earliest_and_latest_dates

=cut

sub _get_earliest_and_latest_dates {
    my ( $report_type, $id ) = @_;

    my @years = Koha::ERM::MonthlyUsages->search(
        { 
            usage_data_provider_id => $id,
            report_type => { -like => "%$report_type%" }
        }, 
        {
            columns => [
                { earliestYear => { min => "year" } },
                { latestYear => { max => "year" } },
            ]
        }
    )->unblessed;
    if($years[0][0]->{earliestYear}) {
        my @earliest_month = Koha::ERM::MonthlyUsages->search(
            { 
                usage_data_provider_id => $id,
                report_type => { -like => "%$report_type%" },
                year => $years[0][0]->{earliestYear},
            }, 
            {
                columns => [
                    { month => { min => "month" } },
                ]
            }
        )->unblessed;
        my @latest_month = Koha::ERM::MonthlyUsages->search(
            { 
                usage_data_provider_id => $id,
                report_type => { -like => "%$report_type%" },
                year => $years[0][0]->{latestYear},
            }, 
            {
                columns => [
                    { month => { max => "month" } },
                ]
            }
        )->unblessed;

        $earliest_month[0][0]->{month} = _format_month("0$earliest_month[0][0]->{month}");
        $latest_month[0][0]->{month} = _format_month("0$latest_month[0][0]->{month}");

        my $earliest_date = "$years[0][0]->{earliestYear}-$earliest_month[0][0]->{month}";
        my $latest_date = "$years[0][0]->{latestYear}-$latest_month[0][0]->{month}";

        return {
            earliest_date => $earliest_date,
            latest_date   => $latest_date,
        };
    } else {
        return {
            earliest_date => 0,
            latest_date   => 0,
        };
    }
}

=head3 _format_month

=cut

sub _format_month {
    my ( $month ) = @_;

    $month = length($month) eq 2 ? $month : "0$month";

    return $month;
}

1;
