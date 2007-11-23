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
use CGI::Cookie; # need to check cookies before
                 # having CGI parse the POST request
use Digest::MD5;

my %cookies = fetch CGI::Cookie;
my $sessionID = $cookies{'CGISESSID'}->value;

my $dbh = C4::Context->dbh;
# FIXME get correct session -- not just mysql
my $session = new CGI::Session("driver:MySQL", $sessionID, {Handle=>$dbh});

# upload-file.pl must authenticate the user
# before processing the POST request,
# and quickly bounce if the user is
# not authorized.  Consequently, unlike
# most of the other CGI scripts, upload-file.pl
# requires that the session cookie already
# have been created., $fileid, $tmp_file_name

# FIXME - add authentication based on cookie

my $fileid = Digest::MD5::md5_hex(Digest::MD5::md5_hex(time().{}.rand().{}.$$));

# FIXME - make staging area configurable
my $TEMPROOT = "/tmp";
my $OUTPUTDIR = "$TEMPROOT/$sessionID"; 
mkdir $OUTPUTDIR;
my $tmp_file_name = "$OUTPUTDIR/$fileid";

my $fh = new IO::File $tmp_file_name, "w";
unless (defined $fh) {
    # FIXME - failed to create file for some reason
    send_reply('failed', '', '');
    exit 0;
}
$fh->binmode(); # for Windows compatibility
$session->param("$fileid.uploaded_tmpfile", $tmp_file_name);
$session->param('current_upload', $fileid);
$session->flush();

my $progress = 0;
my $first_chunk = 1;
my $max_size = $ENV{'CONTENT_LENGTH'}; # may not be the file size, exactly

my $query;
$|++;
$query = new CGI \&upload_hook, $session;
clean_up();
send_reply('done', $fileid, $tmp_file_name);

# FIXME - if possible, trap signal caused by user cancelling upload
# FIXME - something is wrong during cleanup: \t(in cleanup) Can't call method "commit" on unblessed reference at /usr/local/share/perl/5.8.8/CGI/Session/Driver/DBI.pm line 130 during global destruction.
exit 0;

sub clean_up {
    $session->param("$fileid.uploadprogress", 'done');
    $session->flush();
}

sub upload_hook {
    my ($file_name, $buffer, $bytes_read, $session) = @_;
    print $fh $buffer;
    # stash received file name
    if ($first_chunk) {
        $session->param("$fileid.uploaded_filename", $file_name);
        $session->flush();
        $first_chunk = 0;
    }
    my $percentage = int(($bytes_read / $max_size) * 100);
    if ($percentage > $progress) {
        $progress = $percentage;
        $session->param("$fileid.uploadprogress", $progress);
        $session->flush();
    }
}

sub send_reply {
    my ($upload_status, $fileid, $tmp_file_name) = @_;

    my $reply = CGI->new("");
    print $reply->header(-type => 'text/html');
    # response will be sent back as JSON
    print "{ status: '$upload_status', fileid: '$fileid', tmp_file_name: '$tmp_file_name' }";
}
