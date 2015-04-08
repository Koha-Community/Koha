#!/usr/bin/perl

# Script for testing progressbar, part 2 - json submit handler
#   and Z39.50 lookups

# Koha library project  www.koha-community.org

# Licensed under the GPL

# Copyright 2010  Catalyst IT, Ltd
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

use strict;
use warnings;

# standard or CPAN modules used
use CGI;
use CGI::Cookie;

# Koha modules used
use C4::Context;
use C4::Auth;
use C4::Output;
use C4::BackgroundJob;

my $input = new CGI;

my $submitted=$input->param('submitted');
my $runinbackground = $input->param('runinbackground');
my $jobID = $input->param('jobID');
my $completedJobID = $input->param('completedJobID');

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "test/progressbar.tt",
                    query => $input,
                    type => "intranet",
                    debug => 1,
                    });

my %cookies = parse CGI::Cookie($cookie);
my $sessionID = $cookies{'CGISESSID'}->value;
if ($completedJobID) {
} elsif ($submitted) {
    my $job = undef;
    if ($runinbackground) {
        my $job_size = 100;
        $job = C4::BackgroundJob->new($sessionID, undef, $ENV{'SCRIPT_NAME'}, $job_size);
        $jobID = $job->id();

        # fork off
        if (my $pid = fork) {
            # parent
            # return job ID as JSON
            
            # prevent parent exiting from
            # destroying the kid's database handle
            # FIXME: according to DBI doc, this may not work for Oracle

            my $reply = CGI->new("");
            print $reply->header(-type => 'text/html');
            print '{"jobID":"' . $jobID . '"}';
            exit 0;
        } elsif (defined $pid) {
        # if we get here, we're a child that has detached
        # itself from Apache

            # close STDOUT to signal to Apache that
            # we're now running in the background
            close STDOUT;
            close STDERR;

            foreach (1..100) {
                $job->progress( $_ );
                sleep 1;
            }
            $job->finish();
        } else {
            # fork failed, so exit immediately
            die "fork failed while attempting to run $ENV{'SCRIPT_NAME'} as a background job";
        }

    }
} else {
    # initial form
    die "We should not be here";
}

exit 0;


