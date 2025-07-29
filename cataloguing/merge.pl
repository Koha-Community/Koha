#!/usr/bin/perl

# Copyright 2009 BibLibre
# Parts Copyright Catalyst IT 2011
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

use Modern::Perl;
use CGI qw ( -utf8 );

use C4::Output qw( output_html_with_http_headers );
use C4::Auth qw( get_template_and_user );
use C4::Biblio qw(
    DelBiblio
    GetBiblioData
    GetFrameworkCode
    GetMarcFromKohaField
    GetMarcStructure
    ModBiblio
    TransformHtmlToMarc
);
use C4::Serials qw( CountSubscriptionFromBiblionumber );
use C4::Reserves qw( MergeHolds );
use C4::Acquisition qw( ModOrder GetOrdersByBiblionumber );

use Koha::BiblioFrameworks;
use Koha::Biblios;
use Koha::Items;
use Koha::MetadataRecord;

my $input = CGI->new;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "cataloguing/merge.tt",
        query           => $input,
        type            => "intranet",
        flagsrequired   => { editcatalogue => 'edit_catalogue', nukat => 'merge_biblio' },
    }
);

my @biblionumbers = $input->multi_param('biblionumber');
my $op = $input->param('op') || q{};

my @errors;
#------------------------
# Merging
#------------------------
if ($op eq 'cud-merge') {

    my $dbh = C4::Context->dbh;

    # Creating a new record from the html code
    my $record       = TransformHtmlToMarc( $input, 1 );
    my $ref_biblionumber = $input->param('ref_biblionumber');
    @biblionumbers = grep { $_ != $ref_biblionumber } @biblionumbers;

    # prepare report
    my @report_records;
    my $report_fields_str = $input->param('report_fields');
    $report_fields_str ||= C4::Context->preference('MergeReportFields');
    my @report_fields;
    foreach my $field_str (split /,/, $report_fields_str) {
        if ($field_str =~ /(\d{3})([0-9a-z]*)/) {
            my ($field, $subfields) = ($1, $2);
            push @report_fields, {
                tag => $field,
                subfields => [ split //, $subfields ]
            }
        }
    }

    # Rewriting the leader
    my $biblio = Koha::Biblios->find($ref_biblionumber);
    $record->leader($biblio->metadata->record->leader());
    #Take new framework code
    my $frameworkcode = $input->param('frameworkcode');

    # Modifying the reference record
    ModBiblio($record, $ref_biblionumber, $frameworkcode);

    my $report_header = {};
    foreach my $biblionumber ($ref_biblionumber, @biblionumbers) {
        # build report
        my $biblio = Koha::Biblios->find($biblionumber);
        my $marcrecord = $biblio->metadata->record;
        my %report_record = (
            biblionumber => $biblionumber,
            fields => {},
        );
        foreach my $field (@report_fields) {
            my @marcfields = $marcrecord->field($field->{tag});
            foreach my $marcfield (@marcfields) {
                my $tag = $marcfield->tag();
                if (scalar @{$field->{subfields}}) {
                    foreach my $subfield (@{$field->{subfields}}) {
                        my @values = $marcfield->subfield($subfield);
                        $report_header->{ $tag . $subfield } = 1;
                        push @{ $report_record{fields}->{$tag . $subfield} }, @values;
                    }
                } elsif ($field->{tag} gt '009') {
                    my @marcsubfields = $marcfield->subfields();
                    foreach my $marcsubfield (@marcsubfields) {
                        my ($code, $value) = @$marcsubfield;
                        $report_header->{ $tag . $code } = 1;
                        push @{ $report_record{fields}->{ $tag . $code } }, $value;
                    }
                } else {
                    $report_header->{ $tag . '@' } = 1;
                    push @{ $report_record{fields}->{ $tag .'@' } }, $marcfield->data();
                }
            }
        }
        push @report_records, \%report_record;
    }

    my $rmerge;
    eval {
        my $newbiblio = Koha::Biblios->find($ref_biblionumber);
        $rmerge = $newbiblio->merge_with( \@biblionumbers );
    };
    if ($@) {
        push @errors, $@;
    }

    # Parameters
    $template->param(
        result           => 1,
        report_records   => \@report_records,
        report_header    => $report_header,
        ref_biblionumber => scalar $input->param('ref_biblionumber')
    );

#-------------------------
# Show records to merge
#-------------------------
} else {
    my $ref_biblionumber = $input->param('ref_biblionumber');

    if ($ref_biblionumber) {
        my $framework = $input->param('frameworkcode');
        $framework //= GetFrameworkCode($ref_biblionumber);

        # Getting MARC Structure
        my $tagslib = GetMarcStructure(1, $framework);

        my $marcflavour = lc(C4::Context->preference('marcflavour'));

        # Creating a loop for display
        my @records;
        foreach my $biblionumber (@biblionumbers) {
            my $biblio = Koha::Biblios->find($biblionumber);
            my $marcrecord = $biblio->metadata->record;
            my $frameworkcode = GetFrameworkCode($biblionumber);
            my $recordObj = Koha::MetadataRecord->new({'record' => $marcrecord, schema => $marcflavour});
            my $record = {
                recordid => $biblionumber,
                record => $marcrecord,
                frameworkcode => $frameworkcode,
                display => $recordObj->createMergeHash($tagslib),
            };
            if ($ref_biblionumber and $ref_biblionumber == $biblionumber) {
                $record->{reference} = 1;
                $template->param(ref_record => $record);
                unshift @records, $record;
            } else {
                push @records, $record;
            }
        }

        my ($biblionumbertag) = GetMarcFromKohaField('biblio.biblionumber');

        # Parameters
        $template->param(
            ref_biblionumber => $ref_biblionumber,
            records => \@records,
            ref_record => $records[0],
            framework => $framework,
            biblionumbertag => $biblionumbertag,
            MergeReportFields => C4::Context->preference('MergeReportFields'),
        );
    } else {
        my @records;
        foreach my $biblionumber (@biblionumbers) {
            my $frameworkcode = GetFrameworkCode($biblionumber);
            my $record = {
                biblionumber => $biblionumber,
                data => GetBiblioData($biblionumber),
                frameworkcode => $frameworkcode,
            };
            push @records, $record;
        }
        # Ask the user to choose which record will be the kept
        $template->param(
            choosereference => 1,
            records => \@records,
        );

        my $frameworks = Koha::BiblioFrameworks->search({}, { order_by => ['frameworktext'] });
        $template->param( frameworks => $frameworks );
    }
}

if (@errors) {
    # Errors
    $template->param( errors  => \@errors );
}

output_html_with_http_headers $input, $cookie, $template->output;
exit;
