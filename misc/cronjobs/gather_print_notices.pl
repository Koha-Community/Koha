#!/usr/bin/perl -w

# Copyright 2009 Jesse Weaver
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

BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/../kohalib.pl" };
}

use
  CGI; # NOT a CGI script, this is just to keep C4::Templates::gettemplate happy
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

  -s --split  Split messages into separate file by borrower home library to OUTPUT_DIRECTORY/notices-CURRENT_DATE-BRANCHCODE.html
USAGE
    exit $_[0];
}

my ( $stylesheet, $help, $split );

GetOptions(
    'h|help'  => \$help,
    's|split' => \$split,
) || usage(1);

usage(0) if ($help);

my $output_directory = $ARGV[0];

if ( !$output_directory || !-d $output_directory || !-w $output_directory ) {
    print STDERR
"Error: You must specify a valid and writeable directory to dump the print notices in.\n";
    usage(1);
}

my $today        = C4::Dates->new();
my @all_messages = @{ GetPrintMessages() };
exit unless (@all_messages);

## carriage return replaced by <br/> as output is html
foreach my $message (@all_messages) {
    local $_ = $message->{'content'};
    s/\n/<br \/>/g;
    s/\r//g;
    $message->{'content'} = $_;
}

my $OUTPUT;

if ($split) {
    my %messages_by_branch;
    foreach my $message (@all_messages) {
        push( @{ $messages_by_branch{ $message->{'branchcode'} } }, $message );
    }

    foreach my $branchcode ( keys %messages_by_branch ) {
        my @messages = @{ $messages_by_branch{$branchcode} };
        my $output_file = File::Spec->catdir( $output_directory,
            "holdnotices-" . $today->output('iso') . "-$branchcode.html" );
        open $OUTPUT, '>', $output_file
            or die "Could not open $output_file: $!";

        my $template =
          C4::Templates::gettemplate( 'batch/print-notices.tt', 'intranet',
            new CGI );

        $template->param(
            stylesheet => C4::Context->preference("NoticeCSS"),
            today      => $today->output(),
            messages   => \@messages,
        );

        print $OUTPUT $template->output;

        foreach my $message (@messages) {
            C4::Letters::_set_message_status(
                { message_id => $message->{'message_id'}, status => 'sent' } );
        }

        close $OUTPUT;
    }
}
else {
    my $output_file = File::Spec->catdir( $output_directory,
        "holdnotices-" . $today->output('iso') . ".html" );
    open $OUTPUT, '>', $output_file
        or die "Could not open $output_file: $!";


    my $template =
      C4::Templates::gettemplate( 'batch/print-notices.tt', 'intranet',
        new CGI );

    $template->param(
        stylesheet => C4::Context->preference("NoticeCSS"),
        today      => $today->output(),
        messages   => \@all_messages,
    );

    print $OUTPUT $template->output;

    foreach my $message (@all_messages) {
        C4::Letters::_set_message_status(
            { message_id => $message->{'message_id'}, status => 'sent' } );
    }

    close $OUTPUT;

}
