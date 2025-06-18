#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright 2013 BibLibre
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
use List::MoreUtils qw( uniq );
use Try::Tiny;

use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use C4::Auth   qw( get_template_and_user );
use C4::Biblio;
use C4::AuthoritiesMarc;
use Koha::Acquisition::Orders;
use Koha::Virtualshelves;

use Koha::Authorities;
use Koha::Biblios;
use Koha::Items;
use Koha::BackgroundJob::BatchDeleteBiblio;
use Koha::BackgroundJob::BatchDeleteAuthority;

my $input            = CGI->new;
my $op               = $input->param('op')               // q|form|;
my $recordtype       = $input->param('recordtype')       // 'biblio';
my $skip_open_orders = $input->param('skip_open_orders') // 0;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => 'tools/batch_delete_records.tt',
        query         => $input,
        type          => "intranet",
        flagsrequired => { tools => 'records_batchdel' },
    }
);

my @records;
my @messages;
if ( $op eq 'form' ) {

    # Display the form
    $template->param(
        op    => 'form',
        lists => Koha::Virtualshelves->search(
            [
                { public => 0, owner => $loggedinuser },
                { public => 1 }
            ]
        )
    );
} elsif ( $op eq 'cud-list' ) {

    # List all records to process
    my @record_ids;
    if ( my $bib_list = $input->param('bib_list') ) {

        # Come from the basket
        @record_ids = split /\//, $bib_list;
        $recordtype = 'biblio';
    } elsif ( my $uploadfile = $input->param('uploadfile') ) {

        # A file of id is given
        binmode $uploadfile, ':encoding(UTF-8)';
        while ( my $content = <$uploadfile> ) {
            next unless $content;
            $content =~ s/[\r\n]*$//;
            push @record_ids, $content if $content;
        }
    } elsif ( my $shelf_number = $input->param('shelf_number') ) {
        my $shelf    = Koha::Virtualshelves->find($shelf_number);
        my $contents = $shelf->get_contents;
        while ( my $content = $contents->next ) {
            my $biblionumber = $content->biblionumber;
            push @record_ids, $biblionumber;
        }
    } else {

        # The user enters manually the list of id
        push @record_ids, split( /\s\n/, scalar $input->param('recordnumber_list') );
    }

    for my $record_id ( uniq @record_ids ) {
        if ( $recordtype eq 'biblio' ) {

            # Retrieve biblio information
            my $biblio_object = Koha::Biblios->find($record_id);
            unless ($biblio_object) {
                push @messages, {
                    type         => 'warning',
                    code         => 'biblio_not_exists',
                    biblionumber => $record_id,
                };
                next;
            }
            my $biblio = $biblio_object->unblessed;
            my $record = $biblio_object->metadata->record;
            $biblio->{itemnumbers} =
                [ Koha::Items->search( { biblionumber => $record_id } )->get_column('itemnumber') ];
            $biblio->{holds_count}         = $biblio_object->holds->count;
            $biblio->{issues_count}        = C4::Biblio::CountItemsIssued($record_id);
            $biblio->{subscriptions_count} = $biblio_object->subscriptions->count;

            # Respect skip_open_orders
            next
                if $skip_open_orders
                && Koha::Acquisition::Orders->search(
                { biblionumber => $record_id, orderstatus => [ 'new', 'ordered', 'partial' ] } )->count;

            push @records, $biblio;
        } else {

            # Retrieve authority information
            my $authority = C4::AuthoritiesMarc::GetAuthority($record_id);
            unless ($authority) {
                push @messages, {
                    type   => 'warning',
                    code   => 'authority_not_exists',
                    authid => $record_id,
                };
                next;
            }

            $authority = {
                authid      => $record_id,
                summary     => C4::AuthoritiesMarc::BuildSummary( $authority, $record_id ),
                count_usage => Koha::Authorities->get_usage_count( { authid => $record_id } ),
            };
            push @records, $authority;
        }
    }
    $template->param(
        records => \@records,
        op      => 'list',
    );
} elsif ( $op eq 'cud-delete' ) {

    # We want to delete selected records!
    my @record_ids = $input->multi_param('record_id');

    try {
        my $params = {
            record_ids => \@record_ids,
        };

        my $job_id =
            $recordtype eq 'biblio'
            ? Koha::BackgroundJob::BatchDeleteBiblio->new->enqueue($params)
            : Koha::BackgroundJob::BatchDeleteAuthority->new->enqueue($params);

        $template->param(
            op     => 'enqueued',
            job_id => $job_id,
        );
    } catch {
        push @messages, {
            type  => 'error',
            code  => 'cannot_enqueue_job',
            error => $_,
        };
        $template->param( view => 'errors' );
    };
}

$template->param(
    messages   => \@messages,
    recordtype => $recordtype,
);

output_html_with_http_headers $input, $cookie, $template->output;
