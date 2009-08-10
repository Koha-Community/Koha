#!/usr/bin/perl

# Copyright (C) 2007 LibLime
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
use warnings;

# standard or CPAN modules used
use CGI;
use CGI::Cookie;
use MARC::File::USMARC;

# Koha modules used
use C4::Context;
use C4::Auth;
use C4::Output;
use C4::Biblio;
use C4::ImportBatch;
use C4::Matcher;
use C4::BackgroundJob;
use C4::Labels qw(add_batch);  

my $script_name = "/cgi-bin/koha/tools/manage-marc-import.pl";

my $input = new CGI;
my $op = $input->param('op') || '';
my $completedJobID = $input->param('completedJobID');
my $runinbackground = $input->param('runinbackground');
my $import_batch_id = $input->param('import_batch_id') || '';

# record list displays
my $offset = $input->param('offset') || 0;
my $results_per_page = $input->param('results_per_page') || 25; 

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "tools/manage-marc-import.tmpl",
                 query => $input,
                 type => "intranet",
                 authnotrequired => 0,
                 flagsrequired => {tools => 'manage_staged_marc'},
                 debug => 1,
                 });

my %cookies = parse CGI::Cookie($cookie);
my $sessionID = $cookies{'CGISESSID'}->value;
my $dbh = C4::Context->dbh;

if ($op eq "create_labels") {
	#create a batch of labels, then lose $op & $import_batch_id so we get back to import batch list.
	my $label_batch_id = create_labelbatch_from_importbatch($import_batch_id);
	$template->param( label_batch => $label_batch_id );
	$op='';
	$import_batch_id='';
}
if ($op) {
    $template->param(script_name => $script_name, $op => 1);
} else {
    $template->param(script_name => $script_name);
}

if ($op eq "") {
    # displaying a list
    if ($import_batch_id eq '') {
        import_batches_list($template, $offset, $results_per_page);
    } else {
        import_biblios_list($template, $import_batch_id, $offset, $results_per_page);
    }
} elsif ($op eq "commit-batch") {
    if ($completedJobID) {
        add_saved_job_results_to_template($template, $completedJobID);
    } else {
        commit_batch($template, $import_batch_id);
    }
    import_biblios_list($template, $import_batch_id, $offset, $results_per_page);
} elsif ($op eq "revert-batch") {
    if ($completedJobID) {
        add_saved_job_results_to_template($template, $completedJobID);
    } else {
        revert_batch($template, $import_batch_id);
    }
    import_biblios_list($template, $import_batch_id, $offset, $results_per_page);
} elsif ($op eq "clean-batch") {
    CleanBatch($import_batch_id);
    import_batches_list($template, $offset, $results_per_page);
    $template->param( 
        did_clean       => 1,
        import_batch_id => $import_batch_id,
    );
} elsif ($op eq "redo-matching") {
    my $new_matcher_id = $input->param('new_matcher_id');
    my $current_matcher_id = $input->param('current_matcher_id');
    my $overlay_action = $input->param('overlay_action');
    my $nomatch_action = $input->param('nomatch_action');
    my $item_action = $input->param('item_action');
    redo_matching($template, $import_batch_id, $new_matcher_id, $current_matcher_id, 
                  $overlay_action, $nomatch_action, $item_action);
    import_biblios_list($template, $import_batch_id, $offset, $results_per_page);
} 

output_html_with_http_headers $input, $cookie, $template->output;

exit 0;

sub redo_matching {
    my ($template, $import_batch_id, $new_matcher_id, $current_matcher_id, $overlay_action, $nomatch_action, $item_action) = @_;
    my $rematch_failed = 0;
    return if not defined $new_matcher_id and not defined $current_matcher_id;
    my $old_overlay_action = GetImportBatchOverlayAction($import_batch_id);
    my $old_nomatch_action = GetImportBatchNoMatchAction($import_batch_id);
    my $old_item_action = GetImportBatchItemAction($import_batch_id);
    return if $new_matcher_id eq $current_matcher_id and 
              $old_overlay_action eq $overlay_action and 
              $old_nomatch_action eq $nomatch_action and 
              $old_item_action eq $item_action;
 
    if ($old_overlay_action ne $overlay_action) {
        SetImportBatchOverlayAction($import_batch_id, $overlay_action);
        $template->param('changed_overlay_action' => 1);
    }
    if ($old_nomatch_action ne $nomatch_action) {
        SetImportBatchNoMatchAction($import_batch_id, $nomatch_action);
        $template->param('changed_nomatch_action' => 1);
    }
    if ($old_item_action ne $item_action) {
        SetImportBatchItemAction($import_batch_id, $item_action);
        $template->param('changed_item_action' => 1);
    }

    if ($new_matcher_id eq $current_matcher_id) {
        return;
    } 

    my $num_with_matches = 0;
    if (defined $new_matcher_id and $new_matcher_id ne "") {
        my $matcher = C4::Matcher->fetch($new_matcher_id);
        if (defined $matcher) {
            $num_with_matches = BatchFindBibDuplicates($import_batch_id, $matcher);
            SetImportBatchMatcher($import_batch_id, $new_matcher_id);
        } else {
            $rematch_failed = 1;
        }
    } else {
        $num_with_matches = BatchFindBibDuplicates($import_batch_id, undef);
        SetImportBatchMatcher($import_batch_id, undef);
        SetImportBatchOverlayAction('create_new');
    }
    $template->param(rematch_failed => $rematch_failed);
    $template->param(rematch_attempted => 1);
    $template->param(num_with_matches => $num_with_matches);
}

sub create_labelbatch_from_importbatch {
	my ($batch_id) = @_;
	my @items = GetItemNumbersFromImportBatch($batch_id);
	my $labelbatch = add_batch('labels',\@items);
	return $labelbatch; 
}

sub import_batches_list {
    my ($template, $offset, $results_per_page) = @_;
    my $batches = GetImportBatchRangeDesc($offset, $results_per_page);

    my @list = ();
    foreach my $batch (@$batches) {
        push @list, {
            import_batch_id => $batch->{'import_batch_id'},
            num_biblios => $batch->{'num_biblios'},
            num_items => $batch->{'num_items'},
            upload_timestamp => $batch->{'upload_timestamp'},
            import_status => $batch->{'import_status'},
            file_name => $batch->{'file_name'},
            comments => $batch->{'comments'},
            can_clean => ($batch->{'import_status'} ne 'cleaned') ? 1 : 0,
        };
    }
    $template->param(batch_list => \@list); 
    my $num_batches = GetNumberOfNonZ3950ImportBatches();
    add_page_numbers($template, $offset, $results_per_page, $num_batches);
    $template->param(offset => $offset);
    $template->param(range_top => $offset + $results_per_page - 1);
    $template->param(num_results => $num_batches);
    $template->param(results_per_page => $results_per_page);

}

sub commit_batch {
    my ($template, $import_batch_id) = @_;

    my $job = undef;
    $dbh->{AutoCommit} = 0;
    my $callback = sub {};
    if ($runinbackground) {
        $job = put_in_background($import_batch_id);
        $callback = progress_callback($job, $dbh);
    }
    my ($num_added, $num_updated, $num_items_added, $num_items_errored, $num_ignored) = 
        BatchCommitBibRecords($import_batch_id, 50, $callback);
    $dbh->commit();

    my $results = {
        did_commit => 1,
        num_added => $num_added,
        num_updated => $num_updated,
        num_items_added => $num_items_added,
        num_items_errored => $num_items_errored,
        num_ignored => $num_ignored
    };
    if ($runinbackground) {
        $job->finish($results);
    } else {
        add_results_to_template($template, $results);
    }
}

sub revert_batch {
    my ($template, $import_batch_id) = @_;

    $dbh->{AutoCommit} = 0;
    my $job = undef;
    my $callback = sub {};
    if ($runinbackground) {
        $job = put_in_background($import_batch_id);
        $callback = progress_callback($job, $dbh);
    }
    my ($num_deleted, $num_errors, $num_reverted, $num_items_deleted, $num_ignored) = 
        BatchRevertBibRecords($import_batch_id, 50, $callback);
    $dbh->commit();

    my $results = {
        did_revert => 1,
        num_deleted => $num_deleted,
        num_items_deleted => $num_items_deleted,
        num_errors => $num_errors,
        num_reverted => $num_reverted,
        num_ignored => $num_ignored,
    };
    if ($runinbackground) {
        $job->finish($results);
    } else {
        add_results_to_template($template, $results);
    }
}

sub put_in_background {
    my $import_batch_id = shift;

    my $batch = GetImportBatch($import_batch_id);
    my $job = C4::BackgroundJob->new($sessionID, $batch->{'file_name'}, $ENV{'SCRIPT_NAME'}, $batch->{'num_biblios'});
    my $jobID = $job->id();

    # fork off
    if (my $pid = fork) {
        # parent
        # return job ID as JSON

        # prevent parent exiting from
        # destroying the kid's database handle
        # FIXME: according to DBI doc, this may not work for Oracle
        $dbh->{InactiveDestroy}  = 1;

        my $reply = CGI->new("");
        print $reply->header(-type => 'text/html');
        print "{ jobID: '$jobID' }";
        exit 0;
    } elsif (defined $pid) {
        # child
        # close STDOUT to signal to Apache that
        # we're now running in the background
        close STDOUT;
        close STDERR;
    } else {
        # fork failed, so exit immediately
        warn "fork failed while attempting to run $ENV{'SCRIPT_NAME'} as a background job";
        exit 0;
    }
    return $job;
}

sub progress_callback {
    my $job = shift;
    my $dbh = shift;
    return sub {
        my $progress = shift;
        $job->progress($progress);
        $dbh->commit();
    }
}

sub add_results_to_template {
    my $template = shift;
    my $results = shift;
    $template->param(map { $_ => $results->{$_} } keys %{ $results });
}

sub add_saved_job_results_to_template {
    my $template = shift;
    my $completedJobID = shift;
    my $job = C4::BackgroundJob->fetch($sessionID, $completedJobID);
    my $results = $job->results();
    add_results_to_template($template, $results);
}

sub import_biblios_list {
    my ($template, $import_batch_id, $offset, $results_per_page) = @_;

    my $batch = GetImportBatch($import_batch_id);
    my $biblios = GetImportBibliosRange($import_batch_id, $offset, $results_per_page);
    my @list = ();
    foreach my $biblio (@$biblios) {
        my $citation = $biblio->{'title'};
        $citation .= " $biblio->{'author'}" if $biblio->{'author'};
        $citation .= " (" if $biblio->{'issn'} or $biblio->{'isbn'};
        $citation .= $biblio->{'isbn'} if $biblio->{'isbn'};
        $citation .= ", " if $biblio->{'issn'} and $biblio->{'isbn'};
        $citation .= $biblio->{'issn'} if $biblio->{'issn'};
        $citation .= ")" if $biblio->{'issn'} or $biblio->{'isbn'};

        my $match = GetImportRecordMatches($biblio->{'import_record_id'}, 1);
        my $match_citation = '';
        if ($#$match > -1) {
            $match_citation .= $match->[0]->{'title'} if defined($match->[0]->{'title'});
            $match_citation .= ' ' . $match->[0]->{'author'} if defined($match->[0]->{'author'});
        }

        push @list,
          { import_record_id         => $biblio->{'import_record_id'},
            final_match_biblionumber => $biblio->{'matched_biblionumber'},
            citation                 => $citation,
            status                   => $biblio->{'status'},
            record_sequence          => $biblio->{'record_sequence'},
            overlay_status           => $biblio->{'overlay_status'},
            match_biblionumber       => $#$match > -1 ? $match->[0]->{'biblionumber'} : 0,
            match_citation           => $match_citation,
            match_score              => $#$match > -1 ? $match->[0]->{'score'} : 0,
          };
    }
    my $num_biblios = $batch->{'num_biblios'};
    $template->param(biblio_list => \@list); 
    add_page_numbers($template, $offset, $results_per_page, $num_biblios);
    $template->param(offset => $offset);
    $template->param(range_top => $offset + $results_per_page - 1);
    $template->param(num_results => $num_biblios);
    $template->param(results_per_page => $results_per_page);
    $template->param(import_batch_id => $import_batch_id);
    my $overlay_action = GetImportBatchOverlayAction($import_batch_id);
    $template->param("overlay_action_${overlay_action}" => 1);
    $template->param(overlay_action => $overlay_action);
    my $nomatch_action = GetImportBatchNoMatchAction($import_batch_id);
    $template->param("nomatch_action_${nomatch_action}" => 1);
    $template->param(nomatch_action => $nomatch_action);
    my $item_action = GetImportBatchItemAction($import_batch_id);
    $template->param("item_action_${item_action}" => 1);
    $template->param(item_action => $item_action);
    batch_info($template, $batch);
    
}

sub batch_info {
    my ($template, $batch) = @_;
    $template->param(batch_info => 1);
    $template->param(file_name => $batch->{'file_name'});
    $template->param(comments => $batch->{'comments'});
    $template->param(import_status => $batch->{'import_status'});
    $template->param(upload_timestamp => $batch->{'upload_timestamp'});
    $template->param(num_biblios => $batch->{'num_biblios'});
    $template->param(num_items => $batch->{'num_biblios'});
    if ($batch->{'import_status'} ne 'cleaned') {
        $template->param(can_clean => 1);
    }
    if ($batch->{'num_biblios'} > 0) {
        if ($batch->{'import_status'} eq 'staged' or $batch->{'import_status'} eq 'reverted') {
            $template->param(can_commit => 1);
        }
        if ($batch->{'import_status'} eq 'imported') {
            $template->param(can_revert => 1);
        }
    }
    if (defined $batch->{'matcher_id'}) {
        my $matcher = C4::Matcher->fetch($batch->{'matcher_id'});
        if (defined $matcher) {
            $template->param('current_matcher_id' => $batch->{'matcher_id'});
            $template->param('current_matcher_code' => $matcher->code());
            $template->param('current_matcher_description' => $matcher->description());
        }
    }
    add_matcher_list($batch->{'matcher_id'});
}

sub add_matcher_list {
    my $current_matcher_id = shift;
    my @matchers = C4::Matcher::GetMatcherList();
    if (defined $current_matcher_id) {
        for (my $i = 0; $i <= $#matchers; $i++) {
            if ($matchers[$i]->{'matcher_id'} eq $current_matcher_id) {
                $matchers[$i]->{'selected'} = 1;
            }
        }
    }
    $template->param(available_matchers => \@matchers);
}

sub add_page_numbers {
    my ($template, $offset, $results_per_page, $total_results) = @_;
    my $max_pages = POSIX::ceil($total_results / $results_per_page);
    return if $max_pages < 2;
    my $current_page = int($offset / $results_per_page) + 1;
    my @pages = ();
    for (my $i = 1; $i <= $max_pages; $i++) {
        push @pages, {
            page_number => $i,
            current_page => ($current_page == $i) ? 1 : 0,
            offset => ($i - 1) * $results_per_page
        }
    }
    $template->param(pages => \@pages);
}

