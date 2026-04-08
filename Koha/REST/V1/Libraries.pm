package Koha::REST::V1::Libraries;

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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Mojo::Base 'Mojolicious::Controller';
use C4::Context;
use Koha::Libraries;
use Koha::Calendar;
use Koha::DateUtils qw( dt_from_string );

use Scalar::Util qw( blessed );

use Try::Tiny qw( catch try );

=head1 NAME

Koha::REST::V1::Library - Koha REST API for handling libraries (V1)

=head1 API

=head2 Methods

=cut

=head3 list

Controller function that handles listing Koha::Library objects

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $libraries = $c->objects->search( Koha::Libraries->new );
        return $c->render( status => 200, openapi => $libraries );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 get

Controller function that handles retrieving a single Koha::Library

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $library = Koha::Libraries->find( $c->param('library_id') );

        return $c->render_resource_not_found("Library")
            unless $library;

        return $c->render(
            status  => 200,
            openapi => $c->objects->to_api($library),
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 add

Controller function that handles adding a new Koha::Library object

=cut

sub add {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $library = Koha::Library->new_from_api( $c->req->json );
        $library->store;
        $c->res->headers->location( $c->req->url->to_string . '/' . $library->branchcode );

        return $c->render(
            status  => 201,
            openapi => $c->objects->to_api($library),
        );
    } catch {
        if ( blessed $_ && $_->isa('Koha::Exceptions::Object::DuplicateID') ) {
            return $c->render(
                status  => 409,
                openapi => { error => $_->error, conflict => $_->duplicate_id }
            );
        }

        $c->unhandled_exception($_);
    };
}

=head3 update

Controller function that handles updating a Koha::Library object

=cut

sub update {
    my $c = shift->openapi->valid_input or return;

    my $library = Koha::Libraries->find( $c->param('library_id') );

    return $c->render_resource_not_found("Library")
        unless $library;

    return try {
        my $params = $c->req->json;
        $library->set_from_api($params);
        $library->store();
        return $c->render(
            status  => 200,
            openapi => $c->objects->to_api($library),
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 delete

Controller function that handles deleting a Koha::Library object

=cut

sub delete {

    my $c = shift->openapi->valid_input or return;

    my $library = Koha::Libraries->find( $c->param('library_id') );

    return $c->render_resource_not_found("Library")
        unless $library;

    return try {
        $library->delete;
        return $c->render_resource_deleted;
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 list_desks

Controller function that handles retrieving the library's desks

=cut

sub list_desks {
    my $c = shift->openapi->valid_input or return;

    return $c->render( status => 404, openapi => { error => "Feature disabled" } )
        unless C4::Context->preference('UseCirculationDesks');

    return try {
        my $library = Koha::Libraries->find( $c->param('library_id') );

        return $c->render_resource_not_found("Library")
            unless $library;

        return $c->render(
            status  => 200,
            openapi => $c->objects->to_api( $library->desks )
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 list_cash_registers

Controller function that handles retrieving the library's cash registers

=cut

sub list_cash_registers {
    my $c = shift->openapi->valid_input or return;

    return $c->render( status => 404, openapi => { error => "Feature disabled" } )
        unless C4::Context->preference('UseCashRegisters');

    return try {
        my $library = Koha::Libraries->find( $c->param('library_id') );

        return $c->render_resource_not_found("Library")
            unless $library;

        return $c->render(
            status  => 200,
            openapi => $c->objects->to_api( $library->cash_registers )
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 list_closed_dates

Controller function that returns closed dates for a library within a date range.

=cut

sub list_closed_dates {
    my $c = shift->openapi->valid_input or return;

    my $library_id = $c->param('library_id');
    my $from       = $c->param('from');
    my $to         = $c->param('to');

    my $library = Koha::Libraries->find($library_id);

    return $c->render_resource_not_found("Library")
        unless $library;

    return try {
        my $from_dt = $from ? dt_from_string( $from, 'iso' ) : dt_from_string();
        my $to_dt   = $to   ? dt_from_string( $to,   'iso' ) : $from_dt->clone->add( months => 3 );

        if ( $to_dt->compare($from_dt) < 0 ) {
            return $c->render(
                status  => 400,
                openapi => { error => "'to' date must be after 'from' date", error_code => 'invalid_date_range' }
            );
        }

        if ( $to_dt->delta_days($from_dt)->in_units('days') > 365 ) {
            return $c->render(
                status  => 400,
                openapi => { error => "Date range cannot exceed 365 days", error_code => 'date_range_too_large' }
            );
        }

        my $calendar  = Koha::Calendar->new( branchcode => $library_id );
        my $holidays  = $calendar->_holidays;
        my $weekly    = $calendar->{weekly_closed_days};
        my $day_month = $calendar->{day_month_closed_days};

        my @closed;
        my $current = $from_dt->clone;
        while ( $current <= $to_dt ) {
            my $dominated;
            my $ymd = $current->ymd('');

            # Check special holidays hash first (includes exceptions)
            if ( defined $holidays->{$ymd} ) {
                $dominated = $holidays->{$ymd};    # 1 = closed, 0 = exception (open)
            }

            unless ( defined $dominated && $dominated == 0 ) {
                if (   $dominated
                    || $weekly->[ $current->day_of_week % 7 ]
                    || $day_month->{ $current->month }->{ $current->day } )
                {
                    push @closed, $current->ymd;
                }
            }

            $current->add( days => 1 );
        }

        return $c->render(
            status  => 200,
            openapi => \@closed
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

1;
