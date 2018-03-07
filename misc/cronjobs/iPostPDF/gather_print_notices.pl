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
use HTML::Template;
use C4::Templates;
use C4::Items;
use C4::Reserves;
use File::Spec;
use Getopt::Long;
use Encode;
use Data::Dumper;
use POSIX qw(strftime);

sub usage {
    print STDERR <<USAGE;
Usage: $0 OUTPUT_DIRECTORY
  Will print all waiting print notices to
  OUTPUT_DIRECTORY/branchcode-CURRENT_DATE.pdf .

  -l --library  Get print notices by branchcode, can be repeated.
  -m --message  Choose which messages are printed, can be repeated.
  -c --claiming  Choose this for claiming template

USAGE
    exit $_[0];
}

my ( $stylesheet, $help, @branchcodes, @messagecodes, $claiming);

GetOptions(
    'h|help'  => \$help,
    'c|claiming'  => \$claiming,
    'library=s' => \@branchcodes,
    'message=s' => \@messagecodes,
) || usage(1);

usage(0) if ($help);

my $output_directory = $ARGV[0];

if ( !$output_directory || !-d $output_directory || !-w $output_directory ) {
    print STDERR
"Error: You must specify a valid and writeable directory to dump the print notices in.\n";
    usage(1);
}

my $fileplace = C4::Context->config('intranetdir');

my $today     = output_pref( { dt => dt_from_string, dateonly => 1, dateformat => 'iso' } ) ;
my @all_messages = @{ GetPrintMessages() };
exit unless (@all_messages);

if (@branchcodes) {
    my %seen = map { $_ => 1 } @branchcodes;
    @all_messages = grep { $seen{$_->{branchcode}} } @all_messages;
}

if (@messagecodes) {
    my %seen = map { $_ => 1 } @messagecodes;
    @all_messages = grep { $seen{$_->{letter_code}} } @all_messages;
}

## carriage return replaced by <br/> as output is html
foreach my $message (@all_messages) {
    local $_ = $message->{'content'};
    s/\n/<br \/>/g;
    s/\r//g;
    $message->{'content'} = $_;
}


foreach my $message (@all_messages) {
    my $letterTemplate;

    if ($claiming) {
        $letterTemplate = HTML::Template->new(filename => $fileplace.'/misc/cronjobs/iPostPDF/pdf_bill.tmpl');
        $message = claimingTemplate($message);
    }else{
        $letterTemplate = HTML::Template->new(filename => $fileplace.'/misc/cronjobs/iPostPDF/pdf_print.tmpl');
    }

    my $branch = GetBranchByEmail($message->{'from_address'});

    my $borrower = GetBorrower($message->{'borrowernumber'});

    my $pdfFile = $branch->{'branchcode'}.$message->{'message_id'}."_".$today. ".pdf";

   
    $letterTemplate->param(ITEMINFO => Encode::encode( "utf8", $message->{'content'}));

    open PDF, "| wkhtmltopdf.sh - " . $output_directory.$pdfFile;
    print PDF $letterTemplate->output;
    close(PDF);


    C4::Letters::_set_message_status(
        { message_id => $message->{'message_id'}, status => 'sent' } );

}

sub GetBorrower {
    my ($borrowernumber) = shift or return;
    my $sth = C4::Context->dbh->prepare("SELECT * FROM borrowers WHERE borrowernumber = ?");
    $sth->execute($borrowernumber);
    return $sth->fetchrow_hashref();
}

sub GetBranchByEmail {
    my ($email) = shift or return;
    my $sth = C4::Context->dbh->prepare("SELECT * FROM branches WHERE branchemail = ?");
    $sth->execute($email);
    return $sth->fetchrow_hashref();
}

sub claimingTemplate {
    my ($message) = shift or return;

    my $now = strftime "%d%m%Y", localtime;

    my $totalfines = 0;

    my $billNumberTag = "MessageID";
    my $billNumber = $message->{message_id};

    $message->{'content'} =~ s/$billNumberTag/$billNumber/g;

    my $referenseNumberTag = "ReferenceNumber";
    my $referenseNumber = $message->{message_id}." ".$message->{'borrowernumber'}." ".$now;

    $message->{'content'} =~ s/$referenseNumberTag/$referenseNumber/g;

    my $DueDateTag = "DueDate";
    my $date = time;
    $date = $date + (14 * 24 * 60 * 60);
    my $DueDate = strftime "%d.%m.%Y", localtime($date);

    $message->{'content'} =~ s/$DueDateTag/$DueDate/g;

    my $start = "<var>";
    my $end = "</var>";

    my @matches = $message->{'content'} =~ /$start(.*?)$end/g;

    foreach my $match (@matches) {
        $totalfines = $totalfines + $match;
        my $new_match = $match;
        $new_match =~ tr/./,/;
        $message->{'content'} =~ s/$match/$new_match/g;
    }

    $totalfines = sprintf("%.2f", $totalfines);
    $totalfines =~ tr/./,/;

    $message->{'content'} =~ s/TotalFines/$totalfines/g;

    return $message;

}