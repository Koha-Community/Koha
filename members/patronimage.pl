#!/usr/bin/perl
#
# Copyright 2008 Foundations Bible College & Seminary Inc.
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
#
#
#

use strict;
use CGI qw(:standard escapeHTML);
use C4::Context;
use C4::Members;

$|=1;

my $DEBUG = 0;
my $data = new CGI;
my $cardnumber;

=head1 NAME

patronimage.pl - Script for retrieving and formating Koha patron images for display

=head1 SYNOPSIS

<img src="patronimage.pl?crdnum= />

=head1 DESCRIPTION

This script, when called from within HTML and passed a valid patron cardnumber, will retrieve the image data associated with that cardnumber, format it in proper HTML format and pass it back to be displayed.

=cut

if ($data->param('crdnum')) {
    $cardnumber = $data->param('crdnum');
} else {
    $cardnumber = shift;
}


warn "Cardnumber passed in: $cardnumber" if $DEBUG;

my ($imagedata, $dberror) = GetPatronImage($cardnumber);

if ($dberror) {
    warn "Database Error!";
    exit;
}

# NOTE: Never dump the contents of $imagedata->{'patronimage'} via a warn to a log or nasty
# things will result... you have been warned!

if ($imagedata) {
    print $data->header (-type => $imagedata->{'mimetype'}, -Content_Length => length ($imagedata->{'imagefile'})), $imagedata->{'imagefile'};
    exit;
} else {
    warn "No image exists for $cardnumber" if $DEBUG;
    my $urlbase = url(-base => 1 -rewrite => 1);
    warn "URL base: $urlbase" if $DEBUG;
    print $data->redirect (-uri => "$urlbase/intranet-tmpl/prog/img/patron-blank.png");
}

exit;

=back

=head1 AUTHOR

Chris Nighswonger cnighswonger <at> foundations <dot> edu

=cut
