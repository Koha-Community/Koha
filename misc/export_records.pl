#!/usr/bin/perl

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
use MARC::File::XML;
use List::MoreUtils qw(uniq);
use Getopt::Long;
use Pod::Usage;

use C4::Auth;
use C4::Context;
use C4::Record;

use Koha::Biblioitems;
use Koha::Database;
use Koha::CsvProfiles;
use Koha::Exporter::Record;
use Koha::DateUtils qw( dt_from_string output_pref );

my ( $output_format, $timestamp, $dont_export_items, $csv_profile_id, $deleted_barcodes, $clean, $filename, $record_type, $id_list_file, $starting_authid, $ending_authid, $authtype, $starting_biblionumber, $ending_biblionumber, $itemtype, $starting_callnumber, $ending_callnumber, $start_accession, $end_accession, $help );
GetOptions(
    'format=s'                => \$output_format,
    'date=s'                  => \$timestamp,
    'dont_export_items'       => \$dont_export_items,
    'csv_profile_id=s'        => \$csv_profile_id,
    'deleted_barcodes'        => \$deleted_barcodes,
    'clean'                   => \$clean,
    'filename=s'              => \$filename,
    'record-type=s'           => \$record_type,
    'id_list_file=s'          => \$id_list_file,
    'starting_authid=s'       => \$starting_authid,
    'ending_authid=s'         => \$ending_authid,
    'authtype=s'              => \$authtype,
    'starting_biblionumber=s' => \$starting_biblionumber,
    'ending_biblionumber=s'   => \$ending_biblionumber,
    'itemtype=s'              => \$itemtype,
    'starting_callnumber=s'   => \$starting_callnumber,
    'ending_callnumber=s'     => \$ending_callnumber,
    'start_accession=s'       => \$start_accession,
    'end_accession=s'         => \$end_accession,
    'h|help|?'                => \$help
) || pod2usage(1);

if ($help) {
    pod2usage(1);
}

$filename ||= 'koha.mrc';
$output_format ||= 'iso2709';
$record_type ||= 'bibs';

# Retrocompatibility for the format parameter
$output_format = 'iso2709' if $output_format eq 'marc';

if ( $output_format eq 'csv' and $record_type eq 'auths' ) {
    pod2usage(q|CSV output is only available for biblio records|);
}

if ( $output_format eq 'csv' and not $csv_profile_id ) {
    pod2usage(q|Define a csv profile to export in CSV|);
}

if ( $timestamp and $record_type ne 'bibs' ) {
    pod2usage(q|--timestamp can only be used with biblios|);
}

if ( $record_type ne 'bibs' and $record_type ne 'auths' ) {
    pod2usage(q|--record_type is not valid|);
}

if ( $deleted_barcodes and $record_type ne 'bibs' ) {
    pod2usage(q|--deleted_barcodes can only be used with biblios|);
}

$start_accession = dt_from_string( $start_accession ) if $start_accession;
$end_accession   = dt_from_string( $end_accession )   if $end_accession;

my $dbh = C4::Context->dbh;

# Redirect stdout
open STDOUT, '>', $filename if $filename;


my @record_ids;

$timestamp = ($timestamp) ? output_pref({ dt => dt_from_string($timestamp), dateformat => 'iso', dateonly => 0, }): '';

if ( $record_type eq 'bibs' ) {
    if ( $timestamp ) {
        push @record_ids, $_->{biblionumber} for @{
            $dbh->selectall_arrayref(q| (
                SELECT biblio_metadata.biblionumber
                FROM biblio_metadata
                  LEFT JOIN items USING(biblionumber)
                WHERE biblio_metadata.timestamp >= ?
                  OR items.timestamp >= ?
            ) UNION (
                SELECT biblio_metadata.biblionumber
                FROM biblio_metadata
                  LEFT JOIN deleteditems USING(biblionumber)
                WHERE biblio_metadata.timestamp >= ?
                  OR deleteditems.timestamp >= ?
            ) |, { Slice => {} }, ( $timestamp ) x 4 );
        };
    } else {
        my $conditions = {
            ( $starting_biblionumber or $ending_biblionumber )
                ? (
                    "me.biblionumber" => {
                        ( $starting_biblionumber ? ( '>=' => $starting_biblionumber ) : () ),
                        ( $ending_biblionumber   ? ( '<=' => $ending_biblionumber   ) : () ),
                    }
                )
                : (),
            ( $starting_callnumber or $ending_callnumber )
                ? (
                    callnumber => {
                        ( $starting_callnumber ? ( '>=' => $starting_callnumber ) : () ),
                        ( $ending_callnumber   ? ( '<=' => $ending_callnumber   ) : () ),
                    }
                )
                : (),
            ( $start_accession or $end_accession )
                ? (
                    dateaccessioned => {
                        ( $start_accession ? ( '>=' => $start_accession ) : () ),
                        ( $end_accession   ? ( '<=' => $end_accession   ) : () ),
                    }
                )
                : (),
            ( $itemtype
                ?
                  C4::Context->preference('item-level_itypes')
                    ? ( 'items.itype' => $itemtype )
                    : ( 'me.itemtype' => $itemtype )
                : ()
            ),

        };
        my $biblioitems = Koha::Biblioitems->search( $conditions, { join => 'items' } );
        while ( my $biblioitem = $biblioitems->next ) {
            push @record_ids, $biblioitem->biblionumber;
        }
    }
}
elsif ( $record_type eq 'auths' ) {
    my $conditions = {
        ( $starting_authid or $ending_authid )
            ? (
                authid => {
                    ( $starting_authid ? ( '>=' => $starting_authid ) : () ),
                    ( $ending_authid   ? ( '<=' => $ending_authid   ) : () ),
                }
            )
            : (),
        ( $authtype ? ( authtypecode => $authtype ) : () ),
    };
    # Koha::MetadataRecord::Authority is not a Koha::Object...
    my $authorities = Koha::Database->new->schema->resultset('AuthHeader')->search( $conditions );
    @record_ids = map { $_->authid } $authorities->all;
}

@record_ids = uniq @record_ids;
if ( @record_ids and $id_list_file ) {
    open my $fh, '<', $id_list_file or die "Cannot open file $id_list_file ($!)";
    my @filter_record_ids = <$fh>;
    @filter_record_ids = map { my $id = $_; $id =~ s/[\r\n]*$//; $id } @filter_record_ids;
    # intersection
    my %record_ids = map { $_ => 1 } @record_ids;
    @record_ids = grep $record_ids{$_}, @filter_record_ids;
}

if ($deleted_barcodes) {
    for my $record_id ( @record_ids ) {
        my $barcode = $dbh->selectall_arrayref(q|
            SELECT DISTINCT barcode
            FROM deleteditems
            WHERE deleteditems.biblionumber = ?
        |, { Slice => {} }, $record_id );
        say $_->{barcode} for @$barcode;
    }
}
else {
    Koha::Exporter::Record::export(
        {   record_type        => $record_type,
            record_ids         => \@record_ids,
            format             => $output_format,
            csv_profile_id     => $csv_profile_id,
            export_items       => (not $dont_export_items),
            clean              => $clean || 0,
        }
    );
}
exit;


=head1 NAME

export records - This script exports record (biblios or authorities)

=head1 SYNOPSIS

export_records.pl [-h|--help] [--format=format] [--date=datetime] [--record-type=TYPE] [--dont_export_items] [--deleted_barcodes] [--clean] [--id_list_file=PATH] --filename=outputfile

=head1 OPTIONS

=over

=item B<-h|--help>

Print a brief help message.

=item B<--format>

 --format=FORMAT        FORMAT is either 'xml', 'csv' (biblio records only) or 'marc' (default).

=item B<--date>

 --date=DATETIME        DATETIME should be entered as the 'dateformat' syspref is
                        set (dd/mm/yyyy[ hh:mm:ss] for metric, yyyy-mm-dd[ hh:mm:ss] for iso,
                        mm/dd/yyyy[ hh:mm:ss] for us) records exported are the ones that
                        have been modified since DATETIME.

=item B<--record-type>

 --record-type=TYPE     TYPE is 'bibs' or 'auths'.

=item B<--dont_export_items>

 --dont_export_items    If enabled, the item infos won't be exported.

=item B<--csv_profile_id>

 --csv_profile_id=ID    Generate a CSV file with the given CSV profile id (see tools/csv-profiles.pl)
                        This can only be used to export biblio records.

=item B<--deleted_barcodes>

 --deleted_barcodes     If used, a list of barcodes of items deleted since DATE
                        is produced (or from all deleted items if no date is
                        specified). Used only if TYPE is 'bibs'.

=item B<--clean>

 --clean                removes NSE/NSB.

=item B<--id_list_file>

 --id_list_file=PATH    PATH is a path to a file containing a list of
                        IDs (biblionumber or authid) with one ID per line.
                        This list works as a filter; it is compatible with
                        other parameters for selecting records.

=item B<--filename>

 --filename=FILENAME   FILENAME used to export the data.

=item B<--starting_authid>

 --starting_authid=ID  Export authorities with authid >= ID

=item B<--ending_authid>

 --ending_authid=ID    Export authorities with authid <= ID

=item B<--authtype>

 --authtype=AUTHTYPE   Export authorities from the given AUTHTYPE

=item B<--starting_biblionumber>

 --starting_biblionumber=ID  Export biblio with biblionumber >= ID

=item B<--ending_biblionumber>

 --ending_biblionumber=ID    Export biblio with biblionumber <= ID

=item B<--itemtype>

 --itemtype=ITEMTYPE         Export biblio from the given ITEMTYPE

=item B<--starting_callnumber>

 --starting_callnumber=CALLNUMBER Export biblio with callnumber >=CALLNUMBER

=item B<--ending_callnumber>

 --ending_callnumber=CALLNUMBER Export biblio with callnumber <=CALLNUMBER

=item B<--start_accession>

 --starting_accession=DATE      Export biblio with an item accessionned after DATE

=item B<--end_accession>

 --end_accession=DATE           Export biblio with an item accessionned after DATE

=back

=head1 AUTHOR

Koha Development Team

=head1 COPYRIGHT

Copyright Koha Team

=head1 LICENSE

This file is part of Koha.

Koha is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software
Foundation; either version 3 of the License, or (at your option) any later version.

You should have received a copy of the GNU General Public License along
with Koha; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

=cut
