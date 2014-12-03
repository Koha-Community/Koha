#!/usr/bin/perl
#
# Copyright 2006 Katipo Communications.
# Parts Copyright 2009 Foundations Bible College.
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

use Modern::Perl;
use utf8;
use vars qw($debug);

use CGI;
use CGI::Cookie;

use C4::Auth qw(get_template_and_user);
use C4::Output qw(output_html_with_http_headers);
use C4::BatchOverlay;
use C4::Search qw(SimpleSearch);
use C4::Biblio qw(GetMarcFromKohaField);
use Data::Dumper;

my $cgi = new CGI;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "cataloguing/batchOverlay.tmpl",
        query           => $cgi,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { tools => 'stage_marc_import' },
        debug           => 0,
    }
);

#die Data::Dumper::Dumper( $cgi );

my $codesString = $cgi->param('codesString'); #Could be anything, like EAN, barcode, ISSN, ISBN, ISMN
$template->param( codesString => $codesString );
my $operation = ($cgi->param('overlay')) ? 'overlay' : undef;
my $skipLocalBiblios = $cgi->param('skipLocalBiblios');

$template->param(
    serverloop   => _getRemoteSearchTargets()
);

my (@localSearchErrors, @ambiguousSearchTerms);
if ($codesString && $operation eq 'overlay') {
    my ( $tagid_biblionumber, $subfieldid_biblionumber ) = GetMarcFromKohaField( "biblio.biblionumber" );

    my @biblioNumbers;

    #Get the codes to overlay!
    my $codes = [split( /\n/, $codesString )];

    #Remove duplicate codes, because Zebra doesn't do real time indexing and then we get double import of component parts and parents get merged twice.
    my %codes; my @duplicateSearchTerms;
    for(my $i=0 ; $i<@$codes ; $i++){
        #Sanitate the codes! Always sanitate input!! Mon dieu!
        $codes->[$i] =~ s/^\s*//; #Trim codes from whitespace.
        $codes->[$i] =~ s/\s*$//; #Otherwise very hard to debug!?!!?!?!?
        unless ($codes{ $codes->[$i] }){ $codes{ $codes->[$i] } = 1; }
        else { push @duplicateSearchTerms, $codes->[$i]; }
    }
    if (scalar(@duplicateSearchTerms)) {
        $codes = [keys %codes];
        $template->param('duplicateSearchTerms' => \@duplicateSearchTerms);
    }

    if( not($skipLocalBiblios) ) {
        for(my $i=0 ; $i<@$codes ; $i++){
            my $code = $codes->[$i];
            next() unless $code;

            #Find the biblios by the given code! There should be only 1!
            my ($error, $results, $resultSetSize) = C4::Search::SimpleSearch( $code );
            unless ($resultSetSize) { #EAN is a bitch and often in our catalog we have an extra 0.
                $code = '0'.$code;
                ($error, $results, $resultSetSize) = C4::Search::SimpleSearch( $code );
            }
            if ($resultSetSize && $resultSetSize == 1 && !$error) {
                foreach my $result (@$results) {

                    #Get the biblionumber!
                    if ($result =~ /<(data|control)field tag="$tagid_biblionumber".*?>(.*?)<\/(data|control)field>/s) {
                        my $fieldStr = $2;
                        if ($fieldStr =~ /<subfield code="$subfieldid_biblionumber">(.*?)<\/subfield>/) {
                            push @biblioNumbers, $1;
                        }
                    }
                }
            }
            elsif ($resultSetSize && $resultSetSize > 1) { #Wow, an ambiguous search term, which result do we choose!!
                push @ambiguousSearchTerms, $code;
            }
            else {
                my $msg = $error ? "$code : $error" : $code; #Prevent undef concatenation error
                push @localSearchErrors, {searcherror => $msg};
            }
        }
    }

    unless  (@ambiguousSearchTerms || @localSearchErrors) {
        my ($reportElements, $batchOverlayErrorBuilder);
        ($reportElements, $batchOverlayErrorBuilder) = C4::BatchOverlay::batchOverlayBiblios( \@biblioNumbers ) if not($skipLocalBiblios);
        ($reportElements, $batchOverlayErrorBuilder) = C4::BatchOverlay::batchImportBiblios( $codes ) if $skipLocalBiblios;
        my $reports = C4::BatchOverlay::generateReport( $reportElements, 'asHtml' );

        $template->param('reports' => $reports);
        $template->param('batchOverlayErrors' => \@{$batchOverlayErrorBuilder->{errors}});
    }
}

$template->param('ambiguousSearchTerms' => \@ambiguousSearchTerms);
$template->param('localSearchErrors' => \@localSearchErrors);
output_html_with_http_headers $cgi, undef, $template->output;

=head _getRemoteSearchTargets
WARNING!! Duplicate code from cataloguing/z3950_search.pl since no module for getting these Z-targets exists in v3.16.
=cut
sub _getRemoteSearchTargets {
    my $dbh = C4::Context->dbh();
    my $sth = $dbh->prepare("SELECT id,host,name,checked FROM z3950servers WHERE recordtype <> 'authority' ORDER BY rank, name");
    $sth->execute();
    my $remoteSearchtargetLoop = $sth->fetchall_arrayref( {} );
    return $remoteSearchtargetLoop;
}