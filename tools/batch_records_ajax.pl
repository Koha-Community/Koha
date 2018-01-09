#!/usr/bin/perl

# Copyright 2013 ByWater Solutions
# Based on circ/ysearch.pl: Copyright 2007 Tamil s.a.r.l.
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

=head1 NAME

batch_records_ajax.pl - A script for searching batch imported records via ajax

=head1 SYNOPSIS

This script is to be used as a data source for DataTables that load and display
the records from an import batch.

=cut

use Modern::Perl;

use CGI qw ( -utf8 );
use JSON qw/ to_json /;

use C4::Context;
use C4::Charset;
use C4::Auth qw/check_cookie_auth/;
use C4::ImportBatch;

my $input = new CGI;

my @sort_columns =
  qw/import_record_id title status overlay_status overlay_status/;

my $import_batch_id   = $input->param('import_batch_id');
my $offset            = $input->param('iDisplayStart');
my $results_per_page  = $input->param('iDisplayLength');
my $sorting_column    = $sort_columns[ $input->param('iSortCol_0') // 0 ];
my $sorting_direction = $input->param('sSortDir_0');

$results_per_page = undef if $results_per_page && $results_per_page == -1;

binmode STDOUT, ":encoding(UTF-8)";
print $input->header( -type => 'text/plain', -charset => 'UTF-8' );

my ( $auth_status, $sessionID ) =
  check_cookie_auth( $input->cookie('CGISESSID'), { tools => 'manage_staged_marc' } );
if ( $auth_status ne "ok" ) {
    exit 0;
}

my $batch = GetImportBatch($import_batch_id);
my $records =
  GetImportRecordsRange( $import_batch_id, $offset, $results_per_page, undef,
    { order_by => $sorting_column, order_by_direction => $sorting_direction } );
my @list = ();
foreach my $record (@$records) {
    my $citation = $record->{'title'} || $record->{'authorized_heading'};
    $citation .= " $record->{'author'}" if $record->{'author'};
    $citation .= " (" if $record->{'issn'} or $record->{'isbn'};
    $citation .= $record->{'isbn'} if $record->{'isbn'};
    $citation .= ", " if $record->{'issn'} and $record->{'isbn'};
    $citation .= $record->{'issn'} if $record->{'issn'};
    $citation .= ")" if $record->{'issn'} or $record->{'isbn'};

    my $match = GetImportRecordMatches( $record->{'import_record_id'}, 1 );
    my $match_citation = '';
    my $match_id;
    if ( $#$match > -1 ) {
        if ( $match->[0]->{'record_type'} eq 'biblio' ) {
            $match_citation .= $match->[0]->{'title'}
              if defined( $match->[0]->{'title'} );
            $match_citation .= ' ' . $match->[0]->{'author'}
              if defined( $match->[0]->{'author'} );
            $match_id = $match->[0]->{'biblionumber'};
        }
        elsif ( $match->[0]->{'record_type'} eq 'auth' ) {
            if ( defined( $match->[0]->{'authorized_heading'} ) ) {
                $match_citation .= $match->[0]->{'authorized_heading'};
                $match_id = $match->[0]->{'candidate_match_id'};
            }
        }
    }

    push @list,
      {
        DT_RowId        => $record->{'import_record_id'},
        import_record_id => $record->{'import_record_id'},
        citation        => $citation,
        status          => $record->{'status'},
        overlay_status  => $record->{'overlay_status'},
        match_citation  => $match_citation,
        matched         => $record->{'matched_biblionumber'}
          || $record->{'matched_authid'}
          || q{},
        score => $#$match > -1 ? $match->[0]->{'score'} : 0,
        match_id => $match_id,
        diff_url => $match_id ? "/cgi-bin/koha/tools/showdiffmarc.pl?batchid=$import_batch_id&importid=$record->{import_record_id}&id=$match_id" : undef
      };
}

my $data;
$data->{'iTotalRecords'}        = $batch->{'num_records'};
$data->{'iTotalDisplayRecords'} = $batch->{'num_records'};
$data->{'sEcho'}                = $input->param('sEcho') || undef;
$data->{'aaData'}               = \@list;

print to_json($data);
