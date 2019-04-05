#!/usr/bin/perl -w

# Copyright 2016 Koha-Suomi Oy
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
use File::Copy;
use Getopt::Long;
use Encode;
use Archive::Zip qw( :ERROR_CODES :CONSTANTS );
use Net::FTP;
use Data::Dumper;
use XML::Simple;

sub usage {
    print STDERR <<USAGE;
Usage: $0 OUTPUT_DIRECTORY
  Will print all waiting print notices to
  OUTPUT_DIRECTORY/branchcode-CURRENT_DATE.zip .

  -l --library  Get print notices by branchcode, can be repeated.
  -m --message  Choose which messages are printed, can be repeated.

USAGE
    exit $_[0];
}

my ( $stylesheet, $help, @branchcodes, @messagecodes);

GetOptions(
    'h|help'  => \$help,
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

#
# config
#
my $ftpHost = C4::Context->config('printmailProviders')->{'opusFTP'}->{'ftpHost'};
my $ftpUser = C4::Context->config('printmailProviders')->{'opusFTP'}->{'ftpUser'};
my $ftpPass = C4::Context->config('printmailProviders')->{'opusFTP'}->{'ftpPass'};
my $contact = C4::Context->config('printmailProviders')->{'opusFTP'}->{'contact'};
my $customerId = C4::Context->config('printmailProviders')->{'opusFTP'}->{'customerId'};
my $customerPass = C4::Context->config('printmailProviders')->{'opusFTP'}->{'customerPass'};

my $today = output_pref({ dt => dt_from_string, dateformat => 'iso', dateonly => 1 });
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
    my $letterTemplate = HTML::Template->new(filename => $fileplace.'/misc/cronjobs/iPostPDF/letter.tmpl');
    my $xmlTemplate = HTML::Template->new(filename => $fileplace.'/misc/cronjobs/iPostPDF/xml.tmpl');

    my $timestamp = time;

    my $borrower = GetBorrower($message->{'borrowernumber'});

    my $branch = Koha::Libraries->find($borrower->{branchcode});

    my $pdfFile = $branch->branchcode.$message->{'message_id'}."_".$today. ".pdf";
    my $xmlFile = $branch->branchcode.$message->{'message_id'}."_".$today. ".xml";
    my $zipFile = $branch->branchcode.$message->{'message_id'}."_".$today. ".zip";

    $letterTemplate->param(ITEMINFO => Encode::encode( "iso-8859-1", $message->{'content'}));

    $xmlTemplate->param(CONTACT => Encode::encode( "iso-8859-1", $contact));
    $xmlTemplate->param(CUSTOMERID => $customerId);
    $xmlTemplate->param(CUSTOMERPASS => $customerPass);
    $xmlTemplate->param(NAME => XML::Simple->new()->escape_value($borrower->{firstname}));
    $xmlTemplate->param(SURNAME => XML::Simple->new()->escape_value($borrower->{surname}));
    $xmlTemplate->param(ADDRESS1 => XML::Simple->new()->escape_value($borrower->{address}));
    $xmlTemplate->param(ADDRESS2 => XML::Simple->new()->escape_value($borrower->{address2});
    $xmlTemplate->param(ZIPCODE => XML::Simple->new()->escape_value($borrower->{zipcode}));
    $xmlTemplate->param(CITY => XML::Simple->new()->escape_value($borrower->{city}));
    $xmlTemplate->param(EXFILENAME => $pdfFile);

    open(my $fh, '>', $xmlFile);
    print $fh $xmlTemplate->output;;
    close $fh;

    open PDF, "| wkhtmltopdf.sh - " . $pdfFile;
    print PDF $letterTemplate->output;
    close(PDF);

    my $zip = Archive::Zip->new();
    $zip->addFile( $pdfFile );
    $zip->addFile( $xmlFile );

    unless ( $zip->writeToFileNamed($output_directory . $zipFile) == AZ_OK ) {
       die 'error creating zip-file';
    }

    unlink $pdfFile;
    unlink $xmlFile;

    C4::Letters::_set_message_status(
        { message_id => $message->{'message_id'}, status => 'sent' } );

}

my $ftp = Net::FTP->new($ftpHost, Passive => 1, Debug => 1) or die "Cannot connect to ftp server";
$ftp->login($ftpUser, $ftpPass) or die "Cannot login to ftp server", $ftp->message;
$ftp->cwd("/iPostPDF") or die "Cannot change working directory ", $ftp->message;
$ftp->binary;

my @zipfiles = <$output_directory*.zip>;
foreach my $file (@zipfiles) {
    my $filepath = $file;
    my $length = length $filepath;
    my $last_slash = rindex($file, '/');

    $file = substr($file, $last_slash + 1, $length - $last_slash);
    print "$file\n";
    $ftp->put($filepath, $file . ".temppi") or die "Cannot upload file";
    $ftp->rename($file . ".temppi", $file) or die "Cannot rename file";

    my $processeddirectory=$filepath;
    $processeddirectory=~m/^.+\//;
    $processeddirectory="$&old_notices";
    $processeddirectory=~s/^.zip//; # How did this get left here?
    print localtime . ": Moving source letters to $processeddirectory\n";
    mkdir "$processeddirectory" unless -d "$processeddirectory";

    move ("$filepath", "$processeddirectory");
}
$ftp->quit;

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