#!/usr/bin/perl -w

# Copyright 2009 Jesse Weaver
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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use strict;
use warnings;

BEGIN {

    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/../kohalib.pl" };
}

use CGI; # NOT a CGI script, this is just to keep C4::Templates::gettemplate happy
use C4::Context;
use C4::Dates;
use C4::Debug;
use C4::Letters;
use C4::Templates;
use File::Spec;
use Getopt::Long;

sub usage {
    print STDERR <<USAGE;
Usage: $0 OUTPUT_DIRECTORY
  Will print all waiting print notices to
  OUTPUT_DIRECTORY/notices-CURRENT_DATE.html .
USAGE
    exit $_[0];
}

my ( $stylesheet, $help );

GetOptions(
    'h|help' => \$help,
) || usage( 1 );

usage( 0 ) if ( $help );

my $output_directory = $ARGV[0];

if ( !$output_directory || !-d $output_directory ) {
    print STDERR "Error: You must specify a valid directory to dump the print notices in.\n";
    usage( 1 );
}

my $today = C4::Dates->new();
my @messages = @{ GetPrintMessages() };
exit unless( @messages );

open OUTPUT, '>', File::Spec->catdir( $output_directory, "holdnotices-" . $today->output( 'iso' ) . ".html" );

my $template = C4::Templates::gettemplate( 'batch/print-notices.tmpl', 'intranet', new CGI );

$template->param(
    stylesheet => C4::Context->preference("NoticeCSS"),
    today => $today->output(),
    messages => \@messages,
);

print OUTPUT $template->output;

foreach my $message ( @messages ) {
    C4::Letters::_set_message_status( { message_id => $message->{'message_id'}, status => 'sent' } );
}
