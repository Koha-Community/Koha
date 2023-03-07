#!/usr/bin/perl

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

use Modern::Perl;

use CGI qw ( -utf8 );

use C4::Koha;
use C4::Biblio qw(
    GetFrameworkCode
    GetMarcSeries
    GetMarcSubjects
    GetMarcUrls
);
use C4::Auth qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use Koha::RecordProcessor;
use Koha::CsvProfiles;
use Koha::AuthorisedValues;
use Koha::Biblios;
use Koha::Items;

my $query = CGI->new;

my ( $template, $borrowernumber, $cookie ) = get_template_and_user (
    {
        template_name   => "opac-basket.tt",
        query           => $query,
        type            => "opac",
        authnotrequired => ( C4::Context->preference("OpacPublic") ? 1 : 0 ),
    }
);

my $bib_list     = $query->param('bib_list');
my $verbose      = $query->param('verbose');

if ($verbose)      { $template->param( verbose      => 1 ); }

my @bibs = split( /\//, $bib_list );
my @results;

my $num = 1;
my $marcflavour = C4::Context->preference('marcflavour');
if (C4::Context->preference('TagsEnabled')) {
	$template->param(TagsEnabled => 1);
	foreach (qw(TagsShowOnList TagsInputOnList)) {
		C4::Context->preference($_) and $template->param($_ => 1);
	}
}

my $logged_in_user = Koha::Patrons->find($borrowernumber);

my $record_processor = Koha::RecordProcessor->new({ filters => 'ViewPolicy' });
my $rules = C4::Context->yaml_preference('OpacHiddenItems');

foreach my $biblionumber ( @bibs ) {
    $template->param( biblionumber => $biblionumber );

    my $biblio           = Koha::Biblios->find( $biblionumber ) or next;
    my $dat              = $biblio->unblessed;

    # No filtering on the item records needed for the record itself
    # since the only reason item information is grabbed is because of branchcodes.
    my $record = $biblio->metadata->record;
    my $framework = &GetFrameworkCode( $biblionumber );
    $record_processor->options({
        interface => 'opac',
        frameworkcode => $framework
    });
    $record_processor->process($record);
    next unless $record;
    my $marcnotesarray   = $biblio->get_marc_notes({ opac => 1 });
    my $marcauthorsarray = $biblio->get_marc_contributors;
    my $marcsubjctsarray = GetMarcSubjects( $record, $marcflavour );
    my $marcseriesarray  = GetMarcSeries  ($record,$marcflavour);
    my $marcurlsarray    = GetMarcUrls    ($record,$marcflavour);

    # If every item is hidden, then the biblio should be hidden too.
    next
      if $biblio->hidden_in_opac({ rules => $rules });

    my $hasauthors = 0;
    if($dat->{'author'} || @$marcauthorsarray) {
      $hasauthors = 1;
    }

	# COinS format FIXME: for books Only
        my $fmt = substr $record->leader(), 6,2;
        my $fmts;
        $fmts->{'am'} = 'book';
        $dat->{ocoins_format} = $fmts->{$fmt};

    if ( $num % 2 == 1 ) {
        $dat->{'even'} = 1;
    }

    $num++;
    $dat->{biblionumber} = $biblionumber;
    $dat->{ITEM_RESULTS}   = $biblio->items->filter_by_visible_in_opac({ patron => $logged_in_user });
    $dat->{MARCNOTES}      = $marcnotesarray;
    $dat->{MARCSUBJCTS}    = $marcsubjctsarray;
    $dat->{MARCAUTHORS}    = $marcauthorsarray;
    $dat->{MARCSERIES}  = $marcseriesarray;
    $dat->{MARCURLS}    = $marcurlsarray;
    $dat->{HASAUTHORS}  = $hasauthors;
    my ( $host, $relatedparts, $hostinfo ) = $biblio->get_marc_host;
    $dat->{HOSTITEMENTRIES} = $host;
    $dat->{RELATEDPARTS} = $relatedparts;
    $dat->{HOSTINFO} = $hostinfo;

    push( @results, $dat );
}

my $resultsarray = \@results;

# my $itemsarray=\@items;

$template->param(
    csv_profiles => Koha::CsvProfiles->search(
        { type => 'marc', used_for => 'export_records', staff_only => 0 } ),
    bib_list => $bib_list,
    BIBLIO_RESULTS => $resultsarray,
);

output_html_with_http_headers $query, $cookie, $template->output, undef, { force_no_caching => 1 };
