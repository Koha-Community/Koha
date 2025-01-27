package Koha::REST::V1::ERM::EUsage::UsageDataProviders;

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

use MIME::Base64 qw( decode_base64 );
use Mojo::Base 'Mojolicious::Controller';

use Koha::ERM::EUsage::UsageDataProviders;
use Koha::ERM::EUsage::MonthlyUsages;
use Koha::ERM::EUsage::CounterFiles;

use Scalar::Util qw( blessed );
use Try::Tiny    qw( catch try );

=head1 API

=head2 Methods

=head3 list

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $usage_data_providers_set = Koha::ERM::EUsage::UsageDataProviders->new;
        my $usage_data_providers     = $c->objects->search($usage_data_providers_set);
        foreach my $provider (@$usage_data_providers) {
            my $title_dates = _get_earliest_and_latest_dates(
                'TR',
                $provider->{erm_usage_data_provider_id}
            );
            $provider->{earliest_title} =
                  $title_dates->{earliest_date}
                ? $title_dates->{earliest_date}
                : '';
            $provider->{latest_title} =
                  $title_dates->{latest_date}
                ? $title_dates->{latest_date}
                : '';

            my $platform_dates = _get_earliest_and_latest_dates(
                'PR',
                $provider->{erm_usage_data_provider_id}
            );
            $provider->{earliest_platform} =
                  $platform_dates->{earliest_date}
                ? $platform_dates->{earliest_date}
                : '';
            $provider->{latest_platform} =
                  $platform_dates->{latest_date}
                ? $platform_dates->{latest_date}
                : '';

            my $item_dates = _get_earliest_and_latest_dates(
                'IR',
                $provider->{erm_usage_data_provider_id}
            );
            $provider->{earliest_item} =
                  $item_dates->{earliest_date}
                ? $item_dates->{earliest_date}
                : '';
            $provider->{latest_item} =
                $item_dates->{latest_date} ? $item_dates->{latest_date} : '';

            my $database_dates = _get_earliest_and_latest_dates(
                'DR',
                $provider->{erm_usage_data_provider_id}
            );
            $provider->{earliest_database} =
                  $database_dates->{earliest_date}
                ? $database_dates->{earliest_date}
                : '';
            $provider->{latest_database} =
                  $database_dates->{latest_date}
                ? $database_dates->{latest_date}
                : '';

            my @last_run = Koha::ERM::EUsage::CounterFiles->search(
                {
                    usage_data_provider_id => $provider->{erm_usage_data_provider_id},
                },
                { columns => [ { date_uploaded => { max => "date_uploaded" } }, ] }
            )->unblessed;
            $provider->{last_run} = $last_run[0][0]->{date_uploaded} ? $last_run[0][0]->{date_uploaded} : '';

        }

        return $c->render( status => 200, openapi => $usage_data_providers );
    } catch {
        $c->unhandled_exception($_);
    };

}

=head3 get

Controller function that handles retrieving a single Koha::ERM::EUsage::UsageDataProvider object

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $usage_data_provider =
            Koha::ERM::EUsage::UsageDataProviders->find( $c->param('erm_usage_data_provider_id') );

        return $c->render_resource_not_found("Usage data provider")
            unless $usage_data_provider;

        return $c->render(
            status  => 200,
            openapi => $usage_data_provider
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 add

Controller function that handles adding a new Koha::ERM::EUsage::UsageDataProvider object

=cut

sub add {
    my $c = shift->openapi->valid_input or return;

    return try {
        Koha::Database->new->schema->txn_do(
            sub {

                my $body = $c->req->json;

                my $usage_data_provider = Koha::ERM::EUsage::UsageDataProvider->new_from_api($body)->store;

                $c->res->headers->location(
                    $c->req->url->to_string . '/' . $usage_data_provider->erm_usage_data_provider_id );
                return $c->render(
                    status  => 201,
                    openapi => $c->objects->to_api($usage_data_provider),
                );
            }
        );
    } catch {

        my $to_api_mapping = Koha::ERM::EUsage::UsageDataProvider->new->to_api_mapping;

        if ( blessed $_ ) {
            if ( $_->isa('Koha::Exceptions::Object::DuplicateID') ) {
                return $c->render(
                    status  => 409,
                    openapi => { error => $_->error, conflict => $_->duplicate_id }
                );
            } elsif ( $_->isa('Koha::Exceptions::Object::FKConstraint') ) {
                return $c->render(
                    status  => 400,
                    openapi => { error => "Given " . $to_api_mapping->{ $_->broken_fk } . " does not exist" }
                );
            } elsif ( $_->isa('Koha::Exceptions::BadParameter') ) {
                return $c->render(
                    status  => 400,
                    openapi => { error => "Given " . $to_api_mapping->{ $_->parameter } . " does not exist" }
                );
            } elsif ( $_->isa('Koha::Exceptions::PayloadTooLarge') ) {
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

Controller function that handles updating a Koha::ERM::EUsage::UsageDataProvider object

=cut

sub update {
    my $c = shift->openapi->valid_input or return;

    my $usage_data_provider = Koha::ERM::EUsage::UsageDataProviders->find( $c->param('erm_usage_data_provider_id') );

    return $c->render_resource_not_found("Usage data provider")
        unless $usage_data_provider;

    return try {
        Koha::Database->new->schema->txn_do(
            sub {

                my $body = $c->req->json;

                $usage_data_provider->set_from_api($body)->store;

                $c->res->headers->location(
                    $c->req->url->to_string . '/' . $usage_data_provider->erm_usage_data_provider_id );
                return $c->render(
                    status  => 200,
                    openapi => $c->objects->to_api($usage_data_provider),
                );
            }
        );
    } catch {
        my $to_api_mapping = Koha::ERM::EUsage::UsageDataProvider->new->to_api_mapping;

        if ( blessed $_ ) {
            if ( $_->isa('Koha::Exceptions::Object::FKConstraint') ) {
                return $c->render(
                    status  => 400,
                    openapi => { error => "Given " . $to_api_mapping->{ $_->broken_fk } . " does not exist" }
                );
            } elsif ( $_->isa('Koha::Exceptions::BadParameter') ) {
                return $c->render(
                    status  => 400,
                    openapi => { error => "Given " . $to_api_mapping->{ $_->parameter } . " does not exist" }
                );
            } elsif ( $_->isa('Koha::Exceptions::PayloadTooLarge') ) {
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

    my $usage_data_provider = Koha::ERM::EUsage::UsageDataProviders->find( $c->param('erm_usage_data_provider_id') );

    return $c->render_resource_not_found("Usage data provider")
        unless $usage_data_provider;

    return try {
        $usage_data_provider->delete;
        return $c->render_resource_deleted;
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 process_COUNTER_file

Controller function that handles processing of the COUNTER file
It will->enqueue_counter_file_processing_job for its respective usage data provider

=cut

sub process_COUNTER_file {
    my $c = shift->openapi->valid_input or return;

    return try {
        Koha::Database->new->schema->txn_do(
            sub {

                my $body = $c->req->json;

                my $file_content =
                    defined( $body->{file_content} )
                    ? decode_base64( $body->{file_content} )
                    : "";

                my $max_allowed_packet = C4::Context->dbh->selectrow_array(q{SELECT @@max_allowed_packet});
                Koha::Exceptions::PayloadTooLarge->throw("File size exceeds limit defined by server")
                    if length($file_content) > $max_allowed_packet;

                # Validate the file_content without storing, it'll throw an exception if fail
                my $counter_file_validation = Koha::ERM::EUsage::CounterFile->new( { file_content => $file_content } );
                $counter_file_validation->validate;

                # Validation was successful, enqueue the job
                my $udprovider = Koha::ERM::EUsage::UsageDataProviders->find( $c->param('erm_usage_data_provider_id') );

                my $jobs = $udprovider->enqueue_counter_file_processing_job(
                    {
                        file_content => $file_content,
                    }
                );

                return $c->render(
                    status  => 200,
                    openapi => { jobs => [ @{$jobs} ] }
                );
            }
        );
    } catch {

        my $to_api_mapping = Koha::ERM::EUsage::CounterFile->new->to_api_mapping;

        if ( blessed $_ ) {
            if ( $_->isa('Koha::Exceptions::Object::DuplicateID') ) {
                return $c->render(
                    status  => 409,
                    openapi => { error => $_->error, conflict => $_->duplicate_id }
                );
            } elsif ( $_->isa('Koha::Exceptions::Object::FKConstraint') ) {
                return $c->render(
                    status  => 400,
                    openapi => { error => "Given " . $to_api_mapping->{ $_->broken_fk } . " does not exist" }
                );
            } elsif ( $_->isa('Koha::Exceptions::BadParameter') ) {
                return $c->render(
                    status  => 400,
                    openapi => { error => "Given " . $to_api_mapping->{ $_->parameter } . " does not exist" }
                );
            } elsif ( $_->isa('Koha::Exceptions::PayloadTooLarge') ) {
                return $c->render(
                    status  => 413,
                    openapi => { error => $_->description }
                );
            } elsif ( $_->isa('Koha::Exceptions::ERM::EUsage::CounterFile::UnsupportedRelease') ) {
                return $c->render(
                    status  => 400,
                    openapi => { error => $_->description }
                );
            }
        }

        $c->unhandled_exception($_);
    };
}

=head3 process_SUSHI_response

Controller function that handles processing of the SUSHI response
It will ->enqueue_sushi_harvest_jobs for this usage data provider

=cut

sub process_SUSHI_response {
    my $c = shift->openapi->valid_input or return;

    my $body       = $c->req->json;
    my $begin_date = $body->{begin_date};
    my $end_date   = $body->{end_date};

    unless ( $begin_date lt $end_date ) {
        return $c->render(
            status  => 400,
            openapi => { error => "Begin date must be before end date" }
        );
    }

    my $udprovider = Koha::ERM::EUsage::UsageDataProviders->find( $c->param('erm_usage_data_provider_id') );

    return $c->render_resource_not_found("Usage data provider")
        unless $udprovider;

    return try {
        my $jobs = $udprovider->enqueue_sushi_harvest_jobs(
            {
                begin_date => $begin_date,
                end_date   => $end_date
            }
        );

        return $c->render(
            status  => 200,
            openapi => { jobs => [ @{$jobs} ] }
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 test_connection

=cut

sub test_connection {
    my $c = shift->openapi->valid_input or return;

    my $udprovider = Koha::ERM::EUsage::UsageDataProviders->find( $c->param('erm_usage_data_provider_id') );

    return $c->render_resource_not_found("Usage data provider")
        unless $udprovider;

    try {
        my $service_active = $udprovider->test_connection;
        return $c->render(
            status  => 200,
            openapi => $service_active
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 _get_earliest_and_latest_dates

=cut

sub _get_earliest_and_latest_dates {
    my ( $report_type, $id ) = @_;

    my @years = Koha::ERM::EUsage::MonthlyUsages->search(
        {
            usage_data_provider_id => $id,
            report_type            => { -like => "%$report_type%" }
        },
        {
            columns => [
                { earliestYear => { min => "year" } },
                { latestYear   => { max => "year" } },
            ]
        }
    )->unblessed;
    if ( $years[0][0]->{earliestYear} ) {
        my @earliest_month = Koha::ERM::EUsage::MonthlyUsages->search(
            {
                usage_data_provider_id => $id,
                report_type            => { -like => "%$report_type%" },
                year                   => $years[0][0]->{earliestYear},
            },
            { columns => [ { month => { min => "month" } }, ] }
        )->unblessed;
        my @latest_month = Koha::ERM::EUsage::MonthlyUsages->search(
            {
                usage_data_provider_id => $id,
                report_type            => { -like => "%$report_type%" },
                year                   => $years[0][0]->{latestYear},
            },
            { columns => [ { month => { max => "month" } }, ] }
        )->unblessed;

        $earliest_month[0][0]->{month} =
            _format_month("0$earliest_month[0][0]->{month}");
        $latest_month[0][0]->{month} =
            _format_month("0$latest_month[0][0]->{month}");

        my $earliest_date = "$years[0][0]->{earliestYear}-$earliest_month[0][0]->{month}";
        my $latest_date   = "$years[0][0]->{latestYear}-$latest_month[0][0]->{month}";

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
    my ($month) = @_;

    $month = length($month) eq 2 ? $month : "0$month";

    return $month;
}

1;
