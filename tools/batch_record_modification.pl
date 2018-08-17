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
# <http://www.gnu.org/licenses>

use Modern::Perl;

use CGI;
use List::MoreUtils qw( uniq );

use C4::Auth qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use C4::AuthoritiesMarc qw( BuildSummary ModAuthority );
use C4::BackgroundJob;
use C4::Biblio qw( GetMarcBiblio ModBiblio );
use C4::MarcModificationTemplates qw( GetModificationTemplateActions GetModificationTemplates ModifyRecordWithTemplate );

use Koha::Biblios;
use Koha::MetadataRecord::Authority;

my $input = new CGI;
our $dbh = C4::Context->dbh;
my $op = $input->param('op') // q|form|;
my $recordtype = $input->param('recordtype') // 'biblio';
my $mmtid = $input->param('marc_modification_template_id');

my ( @messages );

my ( $template, $loggedinuser, $cookie ) = get_template_and_user({
        template_name => 'tools/batch_record_modification.tt',
        query => $input,
        type => "intranet",
        authnotrequired => 0,
        flagsrequired => { tools => 'records_batchmod' },
});


my $sessionID = $input->cookie("CGISESSID");

my $runinbackground = $input->param('runinbackground');
my $completedJobID = $input->param('completedJobID');
if ( $completedJobID ) {
    my $job = C4::BackgroundJob->fetch($sessionID, $completedJobID);
    my $report = $job->get('report');
    my $messages = $job->get('messages');
    $template->param(
        report => $report,
        messages => $messages,
        view => 'report',
    );
    output_html_with_http_headers $input, $cookie, $template->output;
    $job->clear();
    exit;
}

my @templates = GetModificationTemplates( $mmtid );
unless ( @templates ) {
    $op = 'error';
    $template->param(
        view => 'errors',
        errors => ['no_template_defined'],
    );
    output_html_with_http_headers $input, $cookie, $template->output;
    exit;
}

if ( $mmtid ) {
    my @actions = GetModificationTemplateActions( $mmtid );
    unless ( @actions ) {
        $op = 'form';
        push @messages, {
            type => 'error',
            code => 'no_action_defined_for_the_template',
            mmtid => $mmtid,
        };
    }
}

if ( $op eq 'form' ) {
    # Display the form
    $template->param(
        view => 'form',
    );
} elsif ( $op eq 'list' ) {
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
    } else {
        # The user enters manually the list of id
        push @record_ids, split( /\s\n/, $input->param('recordnumber_list') );
    }

    for my $record_id ( uniq @record_ids ) {
        if ( $recordtype eq 'biblio' ) {
            # Retrieve biblio information
            my $biblio = Koha::Biblios->find( $record_id );
            unless ( $biblio ) {
                push @messages, {
                    type => 'warning',
                    code => 'biblio_not_exists',
                    biblionumber => $record_id,
                };
                next;
            }
            push @records, $biblio;
        } else {
            # Retrieve authority information
            my $authority = Koha::MetadataRecord::Authority->get_from_authid( $record_id );
            unless ( $authority ) {
                push @messages, {
                    type => 'warning',
                    code => 'authority_not_exists',
                    authid => $record_id,
                };
                next;
            }

            push @records, {
                authid => $record_id,
                summary => C4::AuthoritiesMarc::BuildSummary( $authority->record, $record_id ),
            };
        }
    }
    $template->param(
        records => \@records,
        mmtid => $mmtid,
        view => 'list',
    );
} elsif ( $op eq 'modify' ) {
    # We want to modify selected records!
    my @record_ids = $input->multi_param('record_id');

    my ( $job );
    if ( $runinbackground ) {
        my $job_size = scalar( @record_ids );
        $job = C4::BackgroundJob->new( $sessionID, "FIXME", '/cgi-bin/koha/tools/batch_record_modification.pl', $job_size );
        my $job_id = $job->id;
        if (my $pid = fork) {
            $dbh->{InactiveDestroy}  = 1;

            my $reply = CGI->new("");
            print $reply->header(-type => 'text/html');
            print '{"jobID":"' . $job_id . '"}';
            exit 0;
        } elsif (defined $pid) {
            close STDOUT;
        } else {
            warn "fork failed while attempting to run tools/batch_record_modification.pl as a background job";
            exit 0;
        }
    }

    my $report = {
        total_records => 0,
        total_success => 0,
    };
    my $progress = 0;
    $dbh->{RaiseError} = 1;
    RECORD_IDS: for my $record_id ( sort { $a <=> $b } @record_ids ) {
        $report->{total_records}++;
        next unless $record_id;

        if ( $recordtype eq 'biblio' ) {
            # Biblios
            my $biblionumber = $record_id;

            # Finally, modify the biblio
            my $error = eval {
                my $record = GetMarcBiblio({ biblionumber => $biblionumber });
                ModifyRecordWithTemplate( $mmtid, $record );
                my $frameworkcode = C4::Biblio::GetFrameworkCode( $biblionumber );
                ModBiblio( $record, $biblionumber, $frameworkcode );
            };
            if ( $error and $error != 1 or $@ ) { # ModBiblio returns 1 if everything as gone well
                push @messages, {
                    type => 'error',
                    code => 'biblio_not_modified',
                    biblionumber => $biblionumber,
                    error => ($@ ? $@ : $error),
                };
            } else {
                push @messages, {
                    type => 'success',
                    code => 'biblio_modified',
                    biblionumber => $biblionumber,
                };
                $report->{total_success}++;
            }
        } else {
            # Authorities
            my $authid = $record_id;
            my $error = eval {
                my $authority = Koha::MetadataRecord::Authority->get_from_authid( $authid );
                my $record = $authority->record;
                ModifyRecordWithTemplate( $mmtid, $record );
                ModAuthority( $authid, $record, $authority->authtypecode );
            };
            if ( $error and $error != $authid or $@ ) {
                push @messages, {
                    type => 'error',
                    code => 'authority_not_modified',
                    authid => $authid,
                    error => ($@ ? $@ : 0),
                };
            } else {
                push @messages, {
                    type => 'success',
                    code => 'authority_modified',
                    authid => $authid,
                };
                $report->{total_success}++;
            }
        }

        $job->set({
            view => 'report',
            report => $report,
            messages => \@messages,
        });
        $job->progress( ++$progress ) if $runinbackground;
    }

    if ($runinbackground) {
        $job->finish if defined $job;
    } else {
        $template->param(
            view => 'report',
            report => $report,
            messages => \@messages,
        );
    }
}

$template->param(
    messages => \@messages,
    recordtype => $recordtype,
    MarcModificationTemplatesLoop => \@templates,
);

output_html_with_http_headers $input, $cookie, $template->output;
