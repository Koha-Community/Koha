#!/usr/bin/perl -w

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

# standard or CPAN modules used
use IO::File;
use CGI;
use CGI::Session;
use C4::Context;
use C4::Auth qw/get_session/;
use CGI::Cookie; # need to check cookies before
                 # having CGI parse the POST request
use Digest::MD5;

my %cookies = fetch CGI::Cookie;
my $sessionID = $cookies{'CGISESSID'}->value;

my $session = get_session($sessionID);

# FIXME - add authentication based on cookie

my $query = CGI->new;
my $fileid = $session->param('current_upload');

my $reported_progress = 0;
if (defined $fileid and $fileid ne "") {
    my $progress = $session->param("$fileid.uploadprogress");
    if (defined $progress) {
        if ($progress eq "done") {
            $reported_progress = 100;
        } else {
            $reported_progress = $progress;
        }
    }
}


my $reply = CGI->new("");
print $reply->header(-type => 'text/html');
# response will be sent back as JSON
print "{ progress: $reported_progress }";
