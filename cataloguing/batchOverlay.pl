#!/usr/bin/perl
#
# Copyright 2014 Open source freedom fighters
# Copyright 2015 Vaara-kirjastot
# Copyright 2016 KohaSuomi
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

use CGI;
use CGI::Cookie;
binmode STDOUT, ":encoding(UTF-8)";

use JSON;

use C4::Auth qw(get_template_and_user);
use C4::Output qw(output_html_with_http_headers);
use C4::BatchOverlay;
use C4::BatchOverlay::ReportManager;
use C4::BatchOverlay::RuleManager;
use C4::BatchOverlay::LowlyFinder;
use C4::Search qw(SimpleSearch);
use C4::Biblio qw(GetMarcFromKohaField);
use Data::Dumper;

my $cgi = new CGI;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "cataloguing/batchOverlay.tt",
        query           => $cgi,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { tools => 'stage_marc_import' },
        debug           => 0,
    }
);


my $codesString = $cgi->param('codesString'); #Could be anything, like EAN, barcode, ISSN, ISBN, ISMN
$template->param( codesString => $codesString );
my $operation = $cgi->param('op');
my $showAllExceptions = $cgi->param('showAllExceptions');
$template->param( showAllExceptions => $showAllExceptions ) if $showAllExceptions;

if ( $operation eq 'encodingLevelReport' ) {
    my $encodingLevel = $cgi->param('encodingLevel');
    $template->param( encodingLevel => $encodingLevel );

    my $encodingSearchLimit = $cgi->param('encodingLevelLimit');
    $encodingSearchLimit = 5000 unless $encodingSearchLimit;
    $template->param( encodingLevelLimit => $encodingSearchLimit );

    my ($biblioResults, $resultSetSize) = C4::BatchOverlay::LowlyFinder::searchByEncodingLevel( $encodingLevel, $encodingSearchLimit );
    $template->param( biblioResults => $biblioResults );
    $template->param( biblioResultsSize => $resultSetSize );
}
elsif ($codesString && $operation eq 'overlay') {

    my @biblioNumbers;

    #Get the codes to overlay!
    my $codes = [split( /\n/, $codesString )];
    my $batchOverlayer = C4::BatchOverlay->new();
    my $reportContainer = $batchOverlayer->overlay($codes);

    $template->param( reportContainerId => $reportContainer->getId() ); #Preload the report for us.
}
elsif ($operation eq 'test') {
    my $ruleManager = C4::BatchOverlay::RuleManager->new();
    my $remoteTargetStatuses = $ruleManager->testRemoteTargetConnections();
    my $dryRunStatuses = $ruleManager->testDryRun();

    my $statuses = {
        remoteTargetStatuses => $remoteTargetStatuses,
        dryRunStatuses       => $dryRunStatuses,
    };
    print $cgi->header( -type => 'text/json', -charset => 'UTF-8' );
    print JSON::to_json($statuses);
    exit 0;
}

$template->param(
    reportContainers => C4::BatchOverlay::ReportManager->getReportContainers(),
);

output_html_with_http_headers $cgi, $cookie, $template->output;
