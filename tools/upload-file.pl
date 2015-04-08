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
use CGI::Cookie; # need to check cookies before
                 # having CGI parse the POST request
use C4::UploadedFile;

# upload-file.pl must authenticate the user
# before processing the POST request,
# and quickly bounce if the user is
# not authorized.  Consequently, unlike
# most of the other CGI scripts, upload-file.pl
# requires that the session cookie already
# have been created.

my %cookies = fetch CGI::Cookie;
my ($auth_status, $sessionID) = check_cookie_auth($cookies{'CGISESSID'}->value, { tools => '*' });
if ($auth_status ne "ok") {
    $auth_status = 'denied' if $auth_status eq 'failed';
    send_reply($auth_status, "");
    exit 0;
}

our $uploaded_file = C4::UploadedFile->new($sessionID);
unless (defined $uploaded_file) {
    # FIXME - failed to create file for some reason
    send_reply('failed', '');
    exit 0;
}
$uploaded_file->max_size($ENV{'CONTENT_LENGTH'}); # may not be the file size, exactly

my $query;
$query = new CGI \&upload_hook;
$uploaded_file->done();
send_reply('done', $uploaded_file->id());

# FIXME - if possible, trap signal caused by user cancelling upload
# FIXME - something is wrong during cleanup: \t(in cleanup) Can't call method "commit" on unblessed reference at /usr/local/share/perl/5.8.8/CGI/Session/Driver/DBI.pm line 130 during global destruction.
exit 0;

sub upload_hook {
    my ($file_name, $buffer, $bytes_read, $session) = @_;
    $uploaded_file->stash(\$buffer, $bytes_read);
    if ( ! $uploaded_file->name && $file_name ) { # save name on first chunk
        $uploaded_file->name($file_name);
    }
}

sub send_reply {
    my ($upload_status, $fileid) = @_;

    my $reply = CGI->new("");
    print $reply->header(-type => 'text/html');
    # response will be sent back as JSON
    print '{"status":"' . $upload_status . '","fileid":"' . $fileid . '"}';
}
