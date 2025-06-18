#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright 2020 Koha Development Team
#
# Koha is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3
# of the License, or (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General
# Public License along with Koha; if not, see
# <https://www.gnu.org/licenses>

use Modern::Perl;

use CGI;

use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use Koha::Checkouts;
use Koha::DateUtils qw( dt_from_string );
use Koha::Items;

my $input           = CGI->new;
my $op              = $input->param('op') // q|form|;
my $preview_results = $input->param('preview_results');

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => 'tools/batch_extend_due_dates.tt',
        query         => $input,
        type          => "intranet",
        flagsrequired => { tools => 'batch_extend_due_dates' },
    }
);

my @issue_ids;

if ( $op eq 'form' ) {
    $template->param( view => 'form', );
} elsif ( $op eq 'cud-list' ) {

    my @categorycodes     = $input->multi_param('categorycodes');
    my @itemtypecodes     = $input->multi_param('itemtypecodes');
    my @branchcodes       = $input->multi_param('branchcodes');
    my $from_due_date     = $input->param('from_due_date');
    my $to_due_date       = $input->param('to_due_date');
    my $new_hard_due_date = $input->param('new_hard_due_date');
    my $due_date_days     = $input->param('due_date_days');

    $new_hard_due_date &&= dt_from_string($new_hard_due_date);

    my $dtf = Koha::Database->new->schema->storage->datetime_parser;
    my $search_params;
    if (@categorycodes) {
        $search_params->{'patron.categorycode'} = { -in => \@categorycodes };
    }
    if (@itemtypecodes) {
        my $search_items->{'itype'} = { -in => \@itemtypecodes };
        my @itemnumbers = Koha::Items->search($search_items)->get_column('itemnumber');

        $search_params->{'itemnumber'} = { -in => \@itemnumbers };
    }
    if (@branchcodes) {
        $search_params->{'me.branchcode'} = { -in => \@branchcodes };
    }

    if ( $from_due_date and $to_due_date ) {
        my $to_due_date_endday = dt_from_string($to_due_date);
        $to_due_date_endday->set(    # We set last second of day to see all checkouts from that day
            hour   => 23,
            minute => 59,
            second => 59
        );
        $search_params->{'me.date_due'} = {
            -between => [
                $dtf->format_datetime( dt_from_string($from_due_date) ),
                $dtf->format_datetime($to_due_date_endday),
            ]
        };
    } elsif ($from_due_date) {
        $search_params->{'me.date_due'} =
            { '>=' => $dtf->format_datetime( dt_from_string($from_due_date) ) };
    } elsif ($to_due_date) {
        my $to_due_date_endday = dt_from_string($to_due_date);
        $to_due_date_endday->set(    # We set last second of day to see all checkouts from that day
            hour   => 23,
            minute => 59,
            second => 59
        );
        $search_params->{'me.date_due'} =
            { '<=' => $dtf->format_datetime($to_due_date_endday) };
    }

    my $checkouts = Koha::Checkouts->search(
        $search_params,
        { join => [ 'item', 'patron' ] }
    );

    my @new_due_dates;
    while ( my $checkout = $checkouts->next ) {
        if ($preview_results) {
            push(
                @new_due_dates,
                calc_new_due_date(
                    {
                        due_date          => dt_from_string( $checkout->date_due ),
                        new_hard_due_date => $new_hard_due_date,
                        add_days          => $due_date_days
                    }
                ),
            );
        } else {
            push( @issue_ids, $checkout->id );
        }
    }

    if ($preview_results) {
        $template->param(
            checkouts         => $checkouts,
            new_hard_due_date => $new_hard_due_date,
            due_date_days     => $due_date_days,
            new_due_dates     => \@new_due_dates,
            view              => 'list',
        );
    } else {
        $op = 'cud-modify';
    }
}

if ( $op eq 'cud-modify' ) {

    # We want to modify selected checkouts!
    my $new_hard_due_date = $input->param('new_hard_due_date');
    my $due_date_days     = $input->param('due_date_days');

    # @issue_ids will already be populated if we are skipping the results display
    @issue_ids = $input->multi_param('issue_id') unless @issue_ids;

    $new_hard_due_date &&= dt_from_string($new_hard_due_date);
    my $checkouts =
        Koha::Checkouts->search( { issue_id => { -in => \@issue_ids } } );
    while ( my $checkout = $checkouts->next ) {
        my $new_due_date = calc_new_due_date(
            {
                due_date          => dt_from_string( $checkout->date_due ),
                new_hard_due_date => $new_hard_due_date,
                add_days          => $due_date_days
            }
        );

        # Update checkout's due date
        $checkout->date_due($new_due_date)->store;

        # Update items.onloan
        $checkout->item->onloan($new_due_date)->store;
    }

    $template->param(
        view      => 'report',
        checkouts => $checkouts,
    );
}

sub calc_new_due_date {
    my ($params)          = @_;
    my $due_date          = $params->{due_date};
    my $new_hard_due_date = $params->{new_hard_due_date};
    my $add_days          = $params->{add_days};

    my $new;
    if ($new_hard_due_date) {
        $new = $new_hard_due_date->clone->set(
            hour   => $due_date->hour,
            minute => $due_date->minute,
            second => $due_date->second,
        );
    } else {
        $new = $due_date->clone->add( days => $add_days );
    }
    return $new;
}

output_html_with_http_headers $input, $cookie, $template->output;
