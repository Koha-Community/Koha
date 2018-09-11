#!/usr/bin/perl

# Script for handling import of MARC data into Koha db
#   and Z39.50 lookups

# Koha library project  www.koha-community.org

# Licensed under the GPL

# Copyright 2000-2002 Katipo Communications
#
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

# standard or CPAN modules used
use CGI qw ( -utf8 );
use CGI::Cookie;
use MARC::File::USMARC;

# Koha modules used
use C4::Context;
use C4::Auth;
use C4::Output;
use C4::Biblio;
use C4::ImportBatch;
use C4::Matcher;
use Koha::UploadedFiles;
use C4::BackgroundJob;
use C4::MarcModificationTemplates;
use Koha::Plugins;

my $input = new CGI;

my $fileID                     = $input->param('uploadedfileid');
my $runinbackground            = $input->param('runinbackground');
my $completedJobID             = $input->param('completedJobID');
my $matcher_id                 = $input->param('matcher');
my $overlay_action             = $input->param('overlay_action');
my $nomatch_action             = $input->param('nomatch_action');
my $parse_items                = $input->param('parse_items');
my $item_action                = $input->param('item_action');
my $comments                   = $input->param('comments');
my $record_type                = $input->param('record_type');
my $encoding                   = $input->param('encoding') || 'UTF-8';
my $format                     = $input->param('format') || 'ISO2709';
my $marc_modification_template = $input->param('marc_modification_template_id');
my $basketno                   = $input->param('basketno');
my $booksellerid               = $input->param('booksellerid');

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "tools/stage-marc-import.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { tools => 'stage_marc_import' },
        debug           => 1,
    }
);

$template->param(
    SCRIPT_NAME => '/cgi-bin/koha/tools/stage-marc-import.pl',
    uploadmarc  => $fileID,
    record_type => $record_type,
    basketno => $basketno,
    booksellerid => $booksellerid,
);

my %cookies = parse CGI::Cookie($cookie);
my $sessionID = $cookies{'CGISESSID'}->value;
if ($completedJobID) {
    my $job = C4::BackgroundJob->fetch($sessionID, $completedJobID);
    my $results = $job->results();
    $template->param(map { $_ => $results->{$_} } keys %{ $results });
} elsif ($fileID) {
    my $upload = Koha::UploadedFiles->find( $fileID );
    my $file = $upload->full_path;
    my $filename = $upload->filename;

    my ( $errors, $marcrecords );
    if( $format eq 'MARCXML' ) {
        ( $errors, $marcrecords ) = C4::ImportBatch::RecordsFromMARCXMLFile( $file, $encoding);
    } elsif( $format eq 'ISO2709' ) {
        ( $errors, $marcrecords ) = C4::ImportBatch::RecordsFromISO2709File( $file, $record_type, $encoding );
    } else { # plugin based
        $errors = [];
        $marcrecords = C4::ImportBatch::RecordsFromMarcPlugin( $file, $format, $encoding );
    }
    warn "$filename: " . ( join ',', @$errors ) if @$errors;
        # no need to exit if we have no records (or only errors) here
        # BatchStageMarcRecords can handle that

    my $job = undef;
    my $dbh;
    if ($runinbackground) {
        my $job_size = scalar(@$marcrecords);
        # if we're matching, job size is doubled
        $job_size *= 2 if ($matcher_id ne "");
        $job = C4::BackgroundJob->new($sessionID, $filename, '/cgi-bin/koha/tools/stage-marc-import.pl', $job_size);
        my $jobID = $job->id();

        # fork off
        if (my $pid = fork) {
            # parent
            # return job ID as JSON
            my $reply = CGI->new("");
            print $reply->header(-type => 'text/html');
            print '{"jobID":"' . $jobID . '"}';
            exit 0;
        } elsif (defined $pid) {
            # child
            # close STDOUT to signal to Apache that
            # we're now running in the background
            close STDOUT;
            # close STDERR; # there is no good reason to close STDERR
        } else {
            # fork failed, so exit immediately
            warn "fork failed while attempting to run tools/stage-marc-import.pl as a background job: $!";
            exit 0;
        }

        # if we get here, we're a child that has detached
        # itself from Apache

    }

    # New handle, as we're a child.
    $dbh = C4::Context->dbh({new => 1});
    $dbh->{AutoCommit} = 0;
    # FIXME branch code
    my ( $batch_id, $num_valid, $num_items, @import_errors ) =
      BatchStageMarcRecords(
        $record_type,    $encoding,
        $marcrecords,    $filename,
        $marc_modification_template,
        $comments,       '',
        $parse_items,    0,
        50, staging_progress_callback( $job, $dbh )
      );

    my $num_with_matches = 0;
    my $checked_matches = 0;
    my $matcher_failed = 0;
    my $matcher_code = "";
    if ($matcher_id ne "") {
        my $matcher = C4::Matcher->fetch($matcher_id);
        if (defined $matcher) {
            $checked_matches = 1;
            $matcher_code = $matcher->code();
            $num_with_matches =
              BatchFindDuplicates( $batch_id, $matcher, 10, 50,
                matching_progress_callback( $job, $dbh ) );
            SetImportBatchMatcher($batch_id, $matcher_id);
            SetImportBatchOverlayAction($batch_id, $overlay_action);
            SetImportBatchNoMatchAction($batch_id, $nomatch_action);
            SetImportBatchItemAction($batch_id, $item_action);
            $dbh->commit();
        } else {
            $matcher_failed = 1;
        }
    } else {
        $dbh->commit();
    }

    my $results = {
        staged          => $num_valid,
        matched         => $num_with_matches,
        num_items       => $num_items,
        import_errors   => scalar(@import_errors),
        total           => $num_valid + scalar(@import_errors),
        checked_matches => $checked_matches,
        matcher_failed  => $matcher_failed,
        matcher_code    => $matcher_code,
        import_batch_id => $batch_id,
        booksellerid    => $booksellerid,
        basketno        => $basketno
    };
    if ($runinbackground) {
        $job->finish($results);
        exit 0;
    } else {
	    $template->param(staged => $num_valid,
 	                     matched => $num_with_matches,
                         num_items => $num_items,
                         import_errors => scalar(@import_errors),
                         total => $num_valid + scalar(@import_errors),
                         checked_matches => $checked_matches,
                         matcher_failed => $matcher_failed,
                         matcher_code => $matcher_code,
                         import_batch_id => $batch_id,
                         booksellerid => $booksellerid,
                         basketno => $basketno
                        );
    }

} else {
    # initial form
    if ( C4::Context->preference("marcflavour") eq "UNIMARC" ) {
        $template->param( "UNIMARC" => 1 );
    }
    my @matchers = C4::Matcher::GetMatcherList();
    $template->param( available_matchers => \@matchers );

    my @templates = GetModificationTemplates();
    $template->param( MarcModificationTemplatesLoop => \@templates );

    if ( C4::Context->preference('UseKohaPlugins') &&
         C4::Context->config('enable_plugins') ) {

        my @plugins = Koha::Plugins->new()->GetPlugins({
            method => 'to_marc',
        });
        $template->param( plugins => \@plugins );
    }
}

output_html_with_http_headers $input, $cookie, $template->output;

exit 0;

sub staging_progress_callback {
    my $job = shift;
    my $dbh = shift;
    return sub {
        my $progress = shift;
        $job->progress($progress);
    }
}

sub matching_progress_callback {
    my $job = shift;
    my $dbh = shift;
    my $start_progress = $job->progress();
    return sub {
        my $progress = shift;
        $job->progress($start_progress + $progress);
    }
}
