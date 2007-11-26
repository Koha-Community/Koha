#!/usr/bin/perl

# Script for handling import of MARC data into Koha db
#   and Z39.50 lookups

# Koha library project  www.koha.org

# Licensed under the GPL

# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use strict;

# standard or CPAN modules used
use CGI;
use CGI::Cookie;
use MARC::File::USMARC;

# Koha modules used
use C4::Context;
use C4::Auth;
use C4::Input;
use C4::Output;
use C4::Biblio;
use C4::ImportBatch;
use C4::Matcher;
use C4::UploadedFile;
use C4::BackgroundJob;

my $input = new CGI;
my $dbh = C4::Context->dbh;

my $fileID=$input->param('uploadedfileid');
my $matcher_id = $input->param('matcher');
my $parse_items = $input->param('parse_items');
my $comments = $input->param('comments');
my $syntax = $input->param('syntax');
my ($template, $loggedinuser, $cookie)
	= get_template_and_user({template_name => "tools/stage-marc-import.tmpl",
					query => $input,
					type => "intranet",
					authnotrequired => 0,
					flagsrequired => {tools => 1},
					debug => 1,
					});

$template->param(SCRIPT_NAME => $ENV{'SCRIPT_NAME'},
						uploadmarc => $fileID);

if ($fileID) {
    my %cookies = parse CGI::Cookie($cookie);
    my $uploaded_file = C4::UploadedFile->fetch($cookies{'CGISESSID'}->value, $fileID);
    my $fh = $uploaded_file->fh();
	my $marcrecord='';
	while (<$fh>) {
		$marcrecord.=$_;
	}

    my $job_size = scalar($marcrecord =~ /\035/g);
    # if we're matching, job size is doubled
    $job_size *= 2 if ($matcher_id ne "");

    # FIXME branch code
    my $filename = $uploaded_file->name();
    my $job = C4::BackgroundJob->new($cookies{'CGISESSID'}->value, $filename, $ENV{'SCRIPT_NAME'}, $job_size);
    my ($batch_id, $num_valid, $num_items, @import_errors) = BatchStageMarcRecords($syntax, $marcrecord, $filename, 
                                                                                   $comments, '', $parse_items, 0,
                                                                                   100, staging_progress_callback($job));
    my $num_with_matches = 0;
    my $checked_matches = 0;
    my $matcher_failed = 0;
    my $matcher_code = "";
    if ($matcher_id ne "") {
        my $matcher = C4::Matcher->fetch($matcher_id);
        if (defined $matcher) {
            $checked_matches = 1;
            $matcher_code = $matcher->code();
            $num_with_matches = BatchFindBibDuplicates($batch_id, $matcher, 10, 100, matching_progress_callback($job));
            SetImportBatchMatcher($batch_id, $matcher_id);
        } else {
            $matcher_failed = 1;
        }
    }

    my $results = {
	    staged => $num_valid,
 	    matched => $num_with_matches,
        num_items => $num_items,
        import_errors => scalar(@import_errors),
        total => $num_valid + scalar(@import_errors),
        checked_matches => $checked_matches,
        matcher_failed => $matcher_failed,
        matcher_code => $matcher_code,
        import_batch_id => $batch_id
    };
    $job->finish($results);

	$template->param(staged => $num_valid,
 	                 matched => $num_with_matches,
                     num_items => $num_items,
                     import_errors => scalar(@import_errors),
                     total => $num_valid + scalar(@import_errors),
                     checked_matches => $checked_matches,
                     matcher_failed => $matcher_failed,
                     matcher_code => $matcher_code,
                     import_batch_id => $batch_id
                    );

} else {
    # initial form
    my @matchers = C4::Matcher::GetMatcherList();
    $template->param(available_matchers => \@matchers);
}

output_html_with_http_headers $input, $cookie, $template->output;

exit 0;

sub staging_progress_callback {
    my $job = shift;
    return sub {
        my $progress = shift;
        $job->progress($job->progress() + $progress);
    }
}

sub matching_progress_callback {
    my $job = shift;
    return sub {
        my $progress = shift;
        $job->progress($job->progress() + $progress);
    }
}
