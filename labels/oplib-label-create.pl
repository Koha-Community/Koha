#!/usr/bin/perl
#
# Copyright 2015 KohaSuomi
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;
use vars qw($debug);

use CGI;
use CGI::Cookie;
use JSON::XS;
use POSIX;
use Try::Tiny;
use Scalar::Util qw(blessed);

use C4::Auth qw(get_template_and_user);
use C4::Output qw(output_html_with_http_headers);
use C4::Labels::PdfCreator;
use C4::Labels::SheetManager;
use C4::Labels::DataSourceManager;
use Koha::Virtualshelfcontents;
use C4::Members;
use Koha::Exception::Labels::UnknownItems;

my $cgi = new CGI;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "labels/oplib-label-create.tt",
        query           => $cgi,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { catalogue => 1 },
        debug           => 1,
    }
);

#JSONify the loggedinuser for javascript
my $json = JSON::XS->new();
my $loggedinuserJSON;
if ($loggedinuser) {
    $loggedinuserJSON = $json->encode(C4::Members::GetMember(borrowernumber => $loggedinuser));
}
else {
    $loggedinuserJSON = $json->encode({});
}

$template->param( loggedinuserJSON  => $loggedinuserJSON );
$template->param( dataSourceFunctions => $json->encode( C4::Labels::DataSourceManager::getAvailableDataSourceFunctions() ) );
$template->param( dataFormatFunctions => $json->encode( C4::Labels::DataSourceManager::getAvailableDataFormatFunctions() ) );
$template->param( fonts => C4::Fonts::getAvailableFontsNicely() );

my $op = $cgi->param('op') || ''; #operation code
my $barcodes = $cgi->param('barcodes');
unless ($barcodes) {
    $barcodes = [];
    my $items = getLabelPrintingListItems($loggedinuser);
    if (ref $items eq 'ARRAY') {
        foreach my $i (@$items) {
            push(@$barcodes, $i->{barcode});
        }
        $template->param(barcodesTextArea => join("\n",@$barcodes));
    }
}
my $marginsCookie = exists $cgi->{'.cookies'}->{'label_margins'} ? $cgi->{'.cookies'}->{'label_margins'} : $cgi->cookie(-name => 'label_margins', -value => '', -expires => '+3M');
my $sheetId = $cgi->param('sheetId') || $marginsCookie->{value}->[2] || 0;

#When we are using lableprinter by printing labels, we always get the leftMargin parameter, even when the input field is empty
my $leftMargin = (defined($cgi->param('leftMargin')) ? $cgi->param('leftMargin') : $marginsCookie->{value}->[0] || 0);
my $topMargin  = (defined($cgi->param('topMargin'))  ? $cgi->param('topMargin')  : $marginsCookie->{value}->[1] || 0);
my $margins = {left => $leftMargin || 0, top => $topMargin || 0};
$marginsCookie->{value}->[0] = $leftMargin;
$marginsCookie->{value}->[1] = $topMargin;
$marginsCookie->{value}->[2] = $sheetId;
$template->param(margins => $margins);
$template->param(sheetId => $sheetId);

##Barcodes have been submitted! How awesome!
##Separate the barcodes into an array and sanitate
if ($barcodes) {

    #Sanitate the barcodes! Always sanitate input!! Mon dieu!
    $barcodes = [split( /\n/, $barcodes )];
    for(my $i=0 ; $i<@$barcodes ; $i++){
        $barcodes->[$i] =~ s/^\s*//; #Trim barcode for whitespace.
        $barcodes->[$i] =~ s/\s*$//; #Otherwise very hard to debug!?!!?!?!?
    }
}

if ($op eq "printLabels") {
    my $dir = '/tmp/';
    my $file = 'printLabel'.strftime('%Y%m%d%H%M%S',localtime).'.pdf';

    try {
        my $sheet = C4::Labels::SheetManager::getSheet($sheetId);
        my $creator = C4::Labels::PdfCreator->new({margins => $margins, sheet => $sheet, file => $dir.$file});
        my $filePath = $creator->create($barcodes);

        my $filePathAndName = $dir.$file;
        sendPdf($cgi, $file, $filePathAndName);
        return 1;

    } catch {
        die "$_" unless(blessed($_) && $_->can('rethrow'));
        if ($_->isa('Koha::Exception::Labels::UnknownItems')) {
            $template->param('badBarcodeErrors', $_->badBunch);
            $template->param('barcode', $barcodes); #return barcodes if error happens!
            $template->param(barcodesTextArea => join("\n",@$barcodes)) if $barcodes;
        }
        else {
            $_->rethrow();
        }
    };
}

output_html_with_http_headers $cgi, $marginsCookie, $template->output;

sub sendPdf {
    my ($cgi, $fileName, $filePathAndName) = @_;
      #############################################
    ### Send the pdf to the user as an attachment ###
    print $cgi->header( -type       => 'application/pdf',
                        -cookie     => [$marginsCookie, $cookie],
                        -encoding   => 'utf-8',
                        -charset    => 'utf-8',
                        -attachment => $fileName,
                      ) if $marginsCookie;
    print $cgi->header( -type       => 'application/pdf',
                        -cookie     => [$cookie],
                        -encoding   => 'utf-8',
                        -charset    => 'utf-8',
                        -attachment => $fileName,
                      ) unless $marginsCookie;

    # slurp temporary filename and print it out for plack to pick up
    local $/ = undef;
    open(my $fh, '<', $filePathAndName) || die "$filePathAndName: $!";
    print <$fh>;
    close $fh;
    unlink $filePathAndName;
    ###              pdf sent hooray!             ###
      #############################################
}

sub getLabelPrintingListItems {
    my ($borrowernumber) = @_;
    my $dbh=C4::Context->dbh();
    my $query =
       "SELECT vc.*, i.*
         FROM virtualshelfcontents vc
         LEFT JOIN virtualshelves vs ON vs.shelfnumber = vc.shelfnumber
         LEFT JOIN items i ON i.itemnumber=vc.flags
         WHERE vc.borrowernumber=? AND vs.shelfname = 'labels printing' AND i.itemnumber IS NOT NULL";
    my @params = ($borrowernumber);
    my $sth3 = $dbh->prepare($query);
    $sth3->execute(@params);
    return $sth3->fetchall_arrayref({});
}
