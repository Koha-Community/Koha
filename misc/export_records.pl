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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;
use MARC::File::XML;
use List::MoreUtils qw( uniq );
use Getopt::Long    qw( GetOptions );
use Pod::Usage      qw( pod2usage );
use File::Basename  qw( fileparse );

use Koha::Script;
use C4::Auth;
use C4::Context;
use C4::Record;
use C4::Reports::Guided qw( execute_query );

use Koha::Biblioitems;
use Koha::Database;
use Koha::CsvProfiles;
use Koha::Exporter::Record;
use Koha::DateUtils qw( dt_from_string output_pref );
use Koha::Reports;
use Koha::File::Transports;

my (
    $output_format,
    $timestamp,
    $dont_export_items,
    $csv_profile_id,
    $deleted_barcodes,
    $clean,
    $filename,
    $record_type,
    $id_list_file,
    $starting_authid,
    $ending_authid,
    $authtype,
    $starting_biblionumber,
    $ending_biblionumber,
    $itemtype,
    $starting_callnumber,
    $ending_callnumber,
    $start_accession,
    $end_accession,
    $marc_conditions,
    $embed_see_from_headings,
    $report_id,
    @report_params,
    $report,
    $sql,
    $params_needed,
    $destination_server_id,
    $delete_local_after_run,
    $help,
);

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
    'marc_conditions=s'       => \$marc_conditions,
    'embed_see_from_headings' => \$embed_see_from_headings,
    'report_id=s'             => \$report_id,
    'report_param=s'          => \@report_params,
    'destination_server_id=s' => \$destination_server_id,
    'delete_local_after_run'  => \$delete_local_after_run,
    'h|help|?'                => \$help,
) || pod2usage(1);

if ($help) {
    pod2usage(1);
}

$filename      ||= 'koha.mrc';
$output_format ||= 'iso2709';
$record_type   ||= 'bibs';

# Retrocompatibility for the format parameter
$output_format = 'iso2709' if $output_format eq 'marc';

if ( $output_format eq 'csv' and $record_type eq 'auths' ) {
    pod2usage(q|CSV output is only available for biblio records|);
}

if ( $output_format eq 'csv' and not $csv_profile_id ) {
    pod2usage(q|Define a csv profile to export in CSV|);
}

if ( $record_type ne 'bibs' and $record_type ne 'auths' ) {
    pod2usage(q|--record_type is not valid|);
}

if ( $deleted_barcodes and $record_type ne 'bibs' ) {
    pod2usage(q|--deleted_barcodes can only be used with biblios|);
}

my $file_transport;
if ($destination_server_id) {
    $file_transport = Koha::File::Transports->find($destination_server_id);

    pod2usage( sprintf( "No file transport server (%s) found", $destination_server_id ) )
        unless $file_transport;
}

# Validate flag combinations
if ( $delete_local_after_run && !$destination_server_id ) {
    pod2usage("--delete_local_after_run requires --destination_server_id to be specified");
}

if ($report_id) {

    # Check report exists
    $report = Koha::Reports->find($report_id);
    unless ($report) {
        pod2usage( sprintf( "No saved report (%s) found", $report_id ) );
    }
    $sql = $report->savedsql;

    # Check defined report can be used to export the record_type
    if ( $sql !~ /biblionumber/ && $record_type eq 'bibs' ) {
        pod2usage(q|The --report_id you specified does not fetch a biblionumber|);
    } elsif ( $sql !~ /authid/ && $record_type eq 'auths' ) {
        pod2usage(q|The --report_id you specified does not fetch an authid|);
    }

    # convert SQL parameters to placeholders
    my $params_needed = ( $sql =~ s/(<<[^>]+>>)/\?/g );
    die( "You supplied " . scalar @report_params . " parameter(s) and $params_needed are required by the report" )
        if scalar @report_params != $params_needed;
}

$start_accession = dt_from_string($start_accession) if $start_accession;
$end_accession   = dt_from_string($end_accession)   if $end_accession;

# Parse marc conditions
my @marc_conditions;
if ($marc_conditions) {
    foreach my $condition ( split( /,\s*/, $marc_conditions ) ) {
        if ( $condition =~ /^(\d{3})([\w\d]?)(=|(?:!=)|>|<)([^,]+)$/ ) {
            push @marc_conditions, [ $1, $2, $3, $4 ];
        } elsif ( $condition =~ /^(exists|not_exists)\((\d{3})([\w\d]?)\)$/ ) {
            push @marc_conditions, [ $2, $3, $1 eq 'exists' ? '?' : '!?' ];
        } else {
            die("Invalid condititon: $condition");
        }
    }
}

my $dbh = C4::Context->dbh;

# Redirect stdout
open STDOUT, '>', $filename if $filename;

my @record_ids;

$timestamp =
    ($timestamp) ? output_pref( { dt => dt_from_string($timestamp), dateformat => 'iso', dateonly => 0, } ) : '';

if ( $record_type eq 'bibs' ) {
    if ($report) {

        # Run the report and fetch biblionumbers
        my ($sth) = execute_query(
            {
                sql        => $sql,
                sql_params => \@report_params,
                report_id  => $report_id,
            }
        );
        while ( my $row = $sth->fetchrow_hashref() ) {
            if ( $row->{biblionumber} ) {
                push @record_ids, $row->{biblionumber};
            } else {
                pod2usage(q|The --report_id you specified returned no biblionumbers|);
            }
        }
    } elsif ($timestamp) {
        if ( !$dont_export_items ) {
            push @record_ids, $_->{biblionumber} for @{
                $dbh->selectall_arrayref(
                    q| (
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
                ) |, { Slice => {} }, ($timestamp) x 4
                );
            };
        } else {
            push @record_ids, $_->{biblionumber} for @{
                $dbh->selectall_arrayref(
                    q| (
                    SELECT biblio_metadata.biblionumber
                    FROM biblio_metadata
                    WHERE biblio_metadata.timestamp >= ?
                ) |, { Slice => {} }, $timestamp
                );
            };
        }
    } else {
        my $conditions = {
            ( $starting_biblionumber or $ending_biblionumber )
            ? (
                "me.biblionumber" => {
                    ( $starting_biblionumber ? ( '>=' => $starting_biblionumber ) : () ),
                    ( $ending_biblionumber   ? ( '<=' => $ending_biblionumber )   : () ),
                }
                )
            : (),
            ( $starting_callnumber or $ending_callnumber )
            ? (
                callnumber => {
                    ( $starting_callnumber ? ( '>=' => $starting_callnumber ) : () ),
                    ( $ending_callnumber   ? ( '<=' => $ending_callnumber )   : () ),
                }
                )
            : (),
            ( $start_accession or $end_accession )
            ? (
                dateaccessioned => {
                    ( $start_accession ? ( '>=' => $start_accession ) : () ),
                    ( $end_accession   ? ( '<=' => $end_accession )   : () ),
                }
                )
            : (),
            (
                  $itemtype
                ? C4::Context->preference('item-level_itypes')
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
} elsif ( $record_type eq 'auths' ) {
    if ($report) {

        # Run the report and fetch authids
        my ($sth) = execute_query(
            {
                sql        => $sql,
                sql_params => \@report_params,
                report_id  => $report_id,
            }
        );
        while ( my $row = $sth->fetchrow_hashref() ) {
            if ( $row->{authid} ) {
                push @record_ids, $row->{authid};
            } else {
                pod2usage(q|The --report_id you specified returned no authids|);
            }
        }
    } elsif ($timestamp) {
        push @record_ids, $_->{authid} for @{
            $dbh->selectall_arrayref(
                q| (
                SELECT authid
                FROM auth_header
                WHERE modification_time >= ?
            ) |, { Slice => {} }, $timestamp
            );
        };
    } else {
        my $conditions = {
            ( $starting_authid or $ending_authid )
            ? (
                authid => {
                    ( $starting_authid ? ( '>=' => $starting_authid ) : () ),
                    ( $ending_authid   ? ( '<=' => $ending_authid )   : () ),
                }
                )
            : (),
            ( $authtype ? ( authtypecode => $authtype ) : () ),
        };

        # Koha::MetadataRecord::Authority is not a Koha::Object...
        my $authorities = Koha::Database->new->schema->resultset('AuthHeader')->search($conditions);
        @record_ids = map { $_->authid } $authorities->all;
    }
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
    for my $record_id (@record_ids) {
        my $barcode = $dbh->selectall_arrayref(
            q|
            SELECT DISTINCT barcode
            FROM deleteditems
            WHERE deleteditems.biblionumber = ?
            AND barcode IS NOT NULL AND barcode != ''
        |, { Slice => {} }, $record_id
        );
        say $_->{barcode} for @$barcode;
    }
} else {
    Koha::Exporter::Record::export(
        {
            record_type             => $record_type,
            record_ids              => \@record_ids,
            record_conditions       => @marc_conditions ? \@marc_conditions : undef,
            format                  => $output_format,
            csv_profile_id          => $csv_profile_id,
            export_items            => ( not $dont_export_items ),
            clean                   => $clean                   || 0,
            embed_see_from_headings => $embed_see_from_headings || 0,
        }
    );
}

if ($file_transport) {

    # Verify the file was created successfully before attempting upload
    unless ( -f $filename ) {
        die "Error: Output file '$filename' was not created successfully\n";
    }

    # Connect to the transport
    unless ( $file_transport->connect ) {
        die sprintf( "Error: Unable to connect to file transport server (ID: %s)\n", $destination_server_id );
    }

    # Change to upload directory if specified
    my $upload_dir = $file_transport->upload_directory;
    if ($upload_dir) {
        unless ( $file_transport->change_directory($upload_dir) ) {
            $file_transport->disconnect;
            die sprintf(
                "Error: Unable to change to upload directory '%s' on server (ID: %s)\n", $upload_dir,
                $destination_server_id
            );
        }
    }

    # Upload the file
    # Extract just the filename from the path for remote upload
    my ($remote_filename) = fileparse($filename);
    unless ( $file_transport->upload_file( $filename, $remote_filename ) ) {
        $file_transport->disconnect;
        die sprintf( "Error: Unable to upload file '%s' to server (ID: %s)\n", $filename, $destination_server_id );
    }

    # Always disconnect when done
    $file_transport->disconnect;

    print STDERR "Successfully uploaded '$filename' to file transport server (ID: $destination_server_id)\n";
}

if ($delete_local_after_run) {
    if ( -f $filename ) {
        unless ( unlink $filename ) {
            die sprintf( "Error: Unable to delete local file '%s': %s\n", $filename, $! );
        }
        print STDERR "Successfully deleted local file '$filename'\n";
    }
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

=item B<--marc_conditions>

 --marc_conditions=CONDITIONS   Only include biblios with MARC data matching CONDITIONS.
                                CONDITIONS is on the format: <marc_target><binary_operator><value>,
                                or <unary_operation>(<marc_target>).
                                with multiple conditions separated by commas (,).
                                For example: --marc_conditions="035a!=(EXAMPLE)123,041a=swe".
                                Multiple conditions are all required to match.
                                If <marc_target> has multiple values all values
                                are also required to match.
                                Valid operators are: = (equal to), != (not equal to),
                                > (great than) and < (less than).

                                Two unary operations are also supported:
                                exists(<marc_target>) and not_exists(<marc_target>).
                                For example: --marc_conditions="exists(035a)".

                                "exists(<marc_target)" will include marc records where
                                <marc_target> exists regardless of target value, and
                                "exists(<marc_target>)" will include marc records where
                                no <marc_target> exists.

=item B<--embed_see_from_headings>

 --embed_see_from_headings      Embed see from (non-preferred form) headings in bibliographic record.

=item B<--report_id>

--report_id=ID                  Export biblionumbers or authids from a given saved report output.
                                If you want to export authority records then your report must
                                select authid and you must define --record-type=auths when
                                running this script.

=item B<--report_param>

--report_param=PARAM            Repeatable, should provide one param per param requested for the
                                report.
                                Report params are not combined as on the staff side, so you may
                                need to repeat params.

=item B<--destination_server_id>

--destination_server_id=ID      Provide this option, along with the destination server ID, to
                                upload the resultant mrc file to the selected file transport server.
                                You can create file transport servers via the Koha Staff client, under
                                Koha Administration.

=item B<--delete_local_after_run>

--delete_local_after_run       Deletes the local file at the end of the script run. Can be
                                useful if, for example, you are uploading the file to a
                                file transport server.

=back

=head1 AUTHOR

Koha Development Team

=head1 COPYRIGHT

Copyright Koha Team

=head1 LICENSE

This file is part of Koha.

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

=cut
