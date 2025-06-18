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
use Try::Tiny       qw( catch try );

use C4::Auth                      qw( get_template_and_user );
use C4::Output                    qw( output_html_with_http_headers );
use C4::Auth                      qw( get_template_and_user );
use C4::MarcModificationTemplates qw(
    GetModificationTemplateActions
    GetModificationTemplates
);

use Koha::Biblios;
use Koha::BackgroundJob::BatchUpdateBiblio;
use Koha::BackgroundJob::BatchUpdateAuthority;
use Koha::MetadataRecord::Authority;
use Koha::Virtualshelves;

my $input = CGI->new;
our $dbh = C4::Context->dbh;
my $op         = $input->param('op')         // q|form|;
my $recordtype = $input->param('recordtype') // 'biblio';
my $mmtid      = $input->param('marc_modification_template_id');

my (@messages);

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => 'tools/batch_record_modification.tt',
        query         => $input,
        type          => "intranet",
        flagsrequired => { tools => 'records_batchmod' },
    }
);

my $sessionID = $input->cookie("CGISESSID");

my @templates = GetModificationTemplates($mmtid);
unless (@templates) {
    $op = 'error';
    $template->param(
        view   => 'errors',
        errors => ['no_template_defined'],
    );
    output_html_with_http_headers $input, $cookie, $template->output;
    exit;
}

if ($mmtid) {
    my @actions = GetModificationTemplateActions($mmtid);
    unless (@actions) {
        $op = 'form';
        push @messages, {
            type  => 'error',
            code  => 'no_action_defined_for_the_template',
            mmtid => $mmtid,
        };
    }
}

if ( $op eq 'form' ) {

    # Display the form
    $template->param(
        view  => 'form',
        lists => Koha::Virtualshelves->search(
            [
                { public => 0, owner => $loggedinuser },
                { public => 1 }
            ]
        )
    );
} elsif ( $op eq 'cud-list' ) {

    # List all records to process
    my ( @records, @record_ids );
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
            my $biblio = Koha::Biblios->find($record_id);
            unless ($biblio) {
                push @messages, {
                    type         => 'warning',
                    code         => 'biblio_not_exists',
                    biblionumber => $record_id,
                };
                next;
            }
            push @records, $biblio;
        } else {

            # Retrieve authority information
            my $authority = Koha::MetadataRecord::Authority->get_from_authid($record_id);
            unless ($authority) {
                push @messages, {
                    type   => 'warning',
                    code   => 'authority_not_exists',
                    authid => $record_id,
                };
                next;
            }

            push @records, {
                authid  => $record_id,
                summary => C4::AuthoritiesMarc::BuildSummary( $authority->record, $record_id ),
            };
        }
    }
    $template->param(
        records => \@records,
        mmtid   => $mmtid,
        view    => 'list',
    );
} elsif ( $op eq 'cud-modify' ) {

    # We want to modify selected records!
    my @record_ids = $input->multi_param('record_id');

    try {
        my $patron = Koha::Patrons->find($loggedinuser);
        my $params = {
            mmtid           => $mmtid,
            record_ids      => \@record_ids,
            overlay_context => {
                source       => 'batchmod',
                categorycode => $patron->categorycode,
                userid       => $patron->userid
            }
        };

        my $job_id =
            $recordtype eq 'biblio'
            ? Koha::BackgroundJob::BatchUpdateBiblio->new->enqueue($params)
            : Koha::BackgroundJob::BatchUpdateAuthority->new->enqueue($params);

        $template->param(
            view   => 'enqueued',
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
    messages                      => \@messages,
    recordtype                    => $recordtype,
    MarcModificationTemplatesLoop => \@templates,
);

output_html_with_http_headers $input, $cookie, $template->output;
