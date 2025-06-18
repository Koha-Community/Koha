#!/usr/bin/perl

# Copyright 2013 ByWater Solutions
# Based on circ/ysearch.pl: Copyright 2007 Tamil s.a.r.l.
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

=head1 NAME

batch_records_ajax.pl - A script for searching batch imported records via ajax

=head1 SYNOPSIS

This script is to be used as a data source for DataTables that load and display
the records from an import batch.

=cut

use Modern::Perl;

use CGI  qw ( -utf8 );
use JSON qw( to_json );

use C4::Context;
use C4::Auth        qw( check_cookie_auth );
use C4::ImportBatch qw( GetImportBatch GetImportRecordsRange GetImportRecordMatches );

my $input = CGI->new;

my @sort_columns = qw/import_record_id title status overlay_status overlay_status/;

my $import_batch_id  = $input->param('import_batch_id');
my $offset           = $input->param('start');
my $results_per_page = $input->param('length');

# FIXME We handle sorting on one column only!
my $sorting_column    = $sort_columns[ $input->param('order[0][column]') // 0 ];
my $sorting_direction = $input->param('order[0][dir]');

$results_per_page = undef if $results_per_page && $results_per_page == -1;

binmode STDOUT, ":encoding(UTF-8)";
print $input->header( -type => 'text/plain', -charset => 'UTF-8' );

my ($auth_status) =
    check_cookie_auth( $input->cookie('CGISESSID'), { tools => 'manage_staged_marc' } );
if ( $auth_status ne "ok" ) {
    exit 0;
}

my $batch   = GetImportBatch($import_batch_id);
my $records = GetImportRecordsRange(
    $import_batch_id, $offset, $results_per_page, undef,
    { order_by => $sorting_column, order_by_direction => $sorting_direction }
);
my @list = ();
foreach my $record (@$records) {
    my $citation = $record->{'title'} || $record->{'authorized_heading'};

    my $matches = GetImportRecordMatches( $record->{'import_record_id'} );
    my $match_id;
    if ( scalar @$matches > 0 ) {
        foreach my $match (@$matches) {
            my $match_citation = '';
            if ( $match->{'record_type'} eq 'biblio' ) {
                $match_citation .= $match->{'title'}
                    if defined( $match->{'title'} );
                $match_citation .= ' ' . $match->{'author'}
                    if defined( $match->{'author'} );
                $match->{'match_citation'} = $match_citation;
            } elsif ( $match->{'record_type'} eq 'auth' ) {
                if ( defined( $match->{'authorized_heading'} ) ) {
                    $match_citation .= $match->{'authorized_heading'};
                    $match->{'match_citation'} = $match_citation;
                }
            }
        }
    }

    push @list,
        {
        DT_RowId         => $record->{'import_record_id'},
        import_record_id => $record->{'import_record_id'},
        citation         => $citation,
        author           => $record->{'author'},
        issn             => $record->{'issn'},
        isbn             => $record->{'isbn'},
        status           => $record->{'status'},
        overlay_status   => $record->{'overlay_status'},
        matched          => $record->{'matched_biblionumber'}
            || $record->{'matched_authid'}
            || q{},
        score    => scalar @$matches > 0 ? $matches->[0]->{'score'} : 0,
        matches  => $matches,
        diff_url => $match_id
        ? "/cgi-bin/koha/tools/showdiffmarc.pl?batchid=$import_batch_id&importid=$record->{import_record_id}&id=$match_id&type=$record->{record_type}"
        : undef
        };
}

my $data = {
    recordsTotal    => $batch->{num_records},
    recordsFiltered => $batch->{num_records},
    draw            => $input->param('draw') || undef,
    data            => \@list,
};

print to_json($data);
