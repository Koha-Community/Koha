package Koha::REST::V1::ERM::EUsage::DefaultUsageReports;

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

use Koha::ERM::EUsage::DefaultUsageReport;
use Koha::ERM::EUsage::DefaultUsageReports;

use Scalar::Util qw( blessed );
use Try::Tiny    qw( catch try );

=head1 API

=head2 Methods

=head3 list

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $default_usage_report_set = Koha::ERM::EUsage::DefaultUsageReports->new;
        my $default_usage_report     = $c->objects->search($default_usage_report_set);
        return $c->render( status => 200, openapi => $default_usage_report );
    } catch {
        $c->unhandled_exception($_);
    };

}

=head3 add

Controller function that handles adding a new Koha::ERM::EUsage::DefaultUsageReport object

=cut

sub add {
    my $c = shift->openapi->valid_input or return;

    return try {
        Koha::Database->new->schema->txn_do(
            sub {

                my $body = $c->req->json;

                my $default_report = Koha::ERM::EUsage::DefaultUsageReport->new_from_api($body)->store;

                $c->res->headers->location(
                    $c->req->url->to_string . '/' . $default_report->erm_default_usage_report_id );
                return $c->render(
                    status  => 201,
                    openapi => $c->objects->to_api($default_report),
                );
            }
        );
    } catch {

        my $to_api_mapping = Koha::ERM::EUsage::DefaultUsageReport->new->to_api_mapping;

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

=head3 delete

=cut

sub delete {
    my $c = shift->openapi->valid_input or return;

    my $default_report = Koha::ERM::EUsage::DefaultUsageReports->find( $c->param('erm_default_usage_report_id') );

    return $c->render_resource_not_found("Default report")
        unless $default_report;

    return try {
        $default_report->delete;
        return $c->render_resource_deleted;
    } catch {
        $c->unhandled_exception($_);
    };
}

1;
