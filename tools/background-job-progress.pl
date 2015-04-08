#!/usr/bin/perl

# Copyright (C) 2007 LibLime
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
#use warnings; FIXME - Bug 2505

# standard or CPAN modules used
use IO::File;
use CGI;
use CGI::Session;
use C4::Context;
use C4::Auth qw/check_cookie_auth/;
use C4::BackgroundJob;
use CGI::Cookie; # need to check cookies before
                 # having CGI parse the POST request

my $input = new CGI;
my %cookies = fetch CGI::Cookie;
my ($auth_status, $sessionID) = check_cookie_auth($cookies{'CGISESSID'}->value, { tools => '*' });
if ($auth_status ne "ok") {
    my $reply = CGI->new("");
    print $reply->header(-type => 'text/html');
    print '{"progress":"0"}';
    exit 0;
}

my $jobID = $input->param('jobID');
my $job = C4::BackgroundJob->fetch($sessionID, $jobID);
my $reported_progress = 0;
my $job_size = 100;
my $job_status = 'running';
if (defined $job) {
    $reported_progress = $job->progress();
    $job_size = $job->size();
    $job_status = $job->status();
}

my $reply = CGI->new("");
print $reply->header(-type => 'text/html');
# response will be sent back as JSON
print '{"progress":"' . $reported_progress . '","job_size":"' . $job_size . '","job_status":"' . $job_status . '"}';
