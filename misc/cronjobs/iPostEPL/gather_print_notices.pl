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

use
  CGI; # NOT a CGI script, this is just to keep C4::Templates::gettemplate happy
use C4::Context;
use Koha::DateUtils;
use C4::Debug;
use C4::Letters;
use C4::Templates;
use C4::Items;
use C4::Reserves;
use Koha::Items;
use File::Spec;
use Getopt::Long;

sub usage {
    print STDERR <<USAGE;
Usage: $0 OUTPUT_DIRECTORY
  Will print all waiting print notices to
  OUTPUT_DIRECTORY/notices-CURRENT_DATE.html .

  -s --split  Split messages into separate file by borrower home library to OUTPUT_DIRECTORY/notices-CURRENT_DATE-BRANCHCODE.html

  --holdbarcode  If you want to separate HOLD-letters based on the reserve's pickup branch instead of the borrowers homebranch
                 Define this regexp to find the Item barcodes from the HOLD-letters. Items need to be found so the reservation
                 information can be found. Regexp could be like 'Item: (\\S+)<br />' or 'Barcode (\\S+)<br />'. Remember that
                 these letters are htmlized, so lines end/start with <br />! You must define a capture group between
                 parenthesis () to catch the barcode.
  -m --message  Choose which messages are printed, can be repeated.
  -l --library  Get print notices by branchcode, can be repeated.
  -e --email    Get print notices by email postfix eg. \@mail.com, can be repeated.
  --prefix      Set prefix to output filename
USAGE
    exit $_[0];
}

my ( $stylesheet, $help, $split, $HOLDbarcodeParsingRegexp, @messagecodes, @branchcodes, @emails, $prefix );

GetOptions(
    'h|help'  => \$help,
    's|split' => \$split,
    'holdbarcode=s' => \$HOLDbarcodeParsingRegexp,
    'message=s' => \@messagecodes,
    'library=s' => \@branchcodes,
    'email=s' => \@emails,
    'prefix=s' => \$prefix,
) || usage(1);

usage(0) if ($help);

my $output_directory = $ARGV[0];

if ( !$output_directory || !-d $output_directory || !-w $output_directory ) {
    print STDERR
"Error: You must specify a valid and writeable directory to dump the print notices in.\n";
    usage(1);
}

my $today     = output_pref( { dt => dt_from_string, dateonly => 1, dateformat => 'iso' } ) ;
my $today_syspref = output_pref( { dt => dt_from_string, dateonly => 1 } );
my @all_messages = @{ GetPrintMessages() };
exit unless (@all_messages);

if (@branchcodes) {
    my %seen = map { $_ => 1 } @branchcodes;
    @all_messages = grep { $seen{$_->{branchcode}} } @all_messages;
}

if (@emails) {
    my %seen = map { $_ => 1 } @emails;
    @all_messages = grep { $seen{email_trim($_->{from_address})} } @all_messages;
}


if (@messagecodes) {
    my %seen = map { $_ => 1 } @messagecodes;
    @all_messages = grep { $seen{$_->{letter_code}} } @all_messages;
}

#@all_messages = grep { $_->{letter_code} !~ /^ODUE.+/ } @all_messages; #HACKMAN HERE Remove ODUE* letters, because they are sent via send_overdue_messages.pl

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
        my $defaultBranch = $message->{'branchcode'};

        #Catch HOLD print letters so we can direct them to branches which actually have the items waiting for pickup.
        if (defined $HOLDbarcodeParsingRegexp && $message->{letter_code} eq 'HOLD') {
            fetchPickupLocations( $defaultBranch, $message, \%messages_by_branch );
        }
        else {
            push( @{ $messages_by_branch{ $defaultBranch } }, $message );
        }
    }

    foreach my $branchcode ( keys %messages_by_branch ) {
        my @messages = @{ $messages_by_branch{$branchcode} };
        my $output_file = File::Spec->catdir( $output_directory,
            "notices-" . $today . "-$branchcode.html" );
        open $OUTPUT, '>encoding(utf-8)', $output_file
            or die "Could not open $output_file: $!";

        my $template =
          C4::Templates::gettemplate( '/batch/print-notices.tt', 'intranet',
            new CGI );

        $template->param(
            stylesheet => C4::Context->preference("NoticeCSS"),
            today      => $today_syspref,
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

    my $filename;

    if($prefix) {
        $filename = $prefix."-notices-" . $today . ".html";
    } else {
        $filename = "notices-" . $today . ".html";
    }
    my $output_file = File::Spec->catdir( $output_directory,
        $filename );
    open $OUTPUT, '>encoding(utf-8)', $output_file
        or die "Could not open $output_file: $!";


    my $template =
      C4::Templates::gettemplate( 'batch/print-notices.tt', 'intranet',
        new CGI );

    $template->param(
        stylesheet => C4::Context->preference("NoticeCSS"),
        today      => $today_syspref,
        messages   => \@all_messages,
    );

    print $OUTPUT $template->output;

    foreach my $message (@all_messages) {
        C4::Letters::_set_message_status(
            { message_id => $message->{'message_id'}, status => 'sent' } );
    }

    close $OUTPUT;

}

#Finds the barcodes using a regexp and then gets the reservations attached to them.
#Sends the same letter to the branches from which there are Items' pickup locations inside this one letter.
sub fetchPickupLocations {
    my ($defaultBranch, $message, $messages_by_branch) = @_;
    #Find out the barcodes
    my @barcodes = $message->{content} =~ /$HOLDbarcodeParsingRegexp/mg;
    my %targetBranches; #The same letter can have Items from multiple pickup locations so we need to send this letter to each separate pickup branch.
    foreach my $barcode (@barcodes) {
        my $itemnumber = C4::Items::GetItemnumberFromBarcode( $barcode );
        my $item = Koha::Items->find($itemnumber);
        my $holds = $item->current_holds if $item;
        if ( my $first_hold = $holds->next ) {
            $targetBranches{ $first_hold->branchcode } = 1 if $first_hold->branchcode;
        }
    }

    if (%targetBranches) { #Send the same message to each branch from which there are pickup locations.
        foreach my $branchcode (keys %targetBranches) {
            push( @{ $messages_by_branch->{ $branchcode } }, $message );
        }
    }
    else { #Or default to the default!
        push( @{ $messages_by_branch->{  $defaultBranch  } }, $message );
    }
}

sub  email_trim {
    my $s = shift;
    $s =~ s/^[^_]*@//;
    $s = "@".$s;
    return $s
};
