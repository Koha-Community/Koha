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
use CGI qw ( -utf8 );
use MARC::File::XML;
use List::MoreUtils qw(uniq);
use C4::Auth;
use C4::Branch;             # GetBranches
use C4::Koha;               # GetItemTypes
use C4::Output;

use Koha::Authority::Types;
use Koha::Biblioitems;
use Koha::CsvProfiles;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string output_pref );
use Koha::Exporter::Record;

my $query = new CGI;

my $dont_export_items = $query->param("dont_export_item") || 0;
my $record_type       = $query->param("record_type");
my $op                = $query->param("op") || '';
my $output_format     = $query->param("format") || $query->param("output_format") || 'iso2709';
my $backupdir         = C4::Context->config('backupdir');
my $filename          = $query->param("filename") || 'koha.mrc';
$filename =~ s/(\r|\n)//;

my $dbh = C4::Context->dbh;

my @record_ids;
# biblionumbers is sent from circulation.pl only
if ( $query->param("biblionumbers") ) {
    $record_type = 'bibs';
    @record_ids = $query->multi_param("biblionumbers");
}

# Default value for output_format is 'iso2709'
$output_format ||= 'iso2709';
# Retrocompatibility for the format parameter
$output_format = 'iso2709' if $output_format eq 'marc';

my ( $template, $loggedinuser, $cookie, $flags ) = get_template_and_user(
    {
        template_name   => "tools/export.tt",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { tools => 'export_catalog' },
        debug           => 1,
    }
);

my @branch = $query->multi_param("branch");
my $only_my_branch;
# Limit to local branch if IndependentBranches and not superlibrarian
if (
    (
          C4::Context->preference('IndependentBranches')
        && C4::Context->userenv
        && !C4::Context->IsSuperLibrarian()
        && C4::Context->userenv->{branch}
    )
    # Limit result to local branch strip_nonlocal_items
    or $query->param('strip_nonlocal_items')
) {
    $only_my_branch = 1;
    @branch = ( C4::Context->userenv->{'branch'} );
}

my %branchmap = map { $_ => 1 } @branch; # for quick lookups

if ( $op eq "export" ) {

    my $export_remove_fields = $query->param("export_remove_fields") || q||;
    my @biblionumbers      = $query->multi_param("biblionumbers");
    my @itemnumbers        = $query->multi_param("itemnumbers");
    my @sql_params;
    my $sql_query;

    if ( $record_type eq 'bibs' or $record_type eq 'auths' ) {
        # No need to retrieve the record_ids if we already get them
        unless ( @record_ids ) {
            if ( $record_type eq 'bibs' ) {
                my $starting_biblionumber = $query->param("StartingBiblionumber");
                my $ending_biblionumber   = $query->param("EndingBiblionumber");
                my $itemtype             = $query->param("itemtype");
                my $start_callnumber     = $query->param("start_callnumber");
                my $end_callnumber       = $query->param("end_callnumber");
                my $start_accession =
                  ( $query->param("start_accession") )
                  ? dt_from_string( scalar $query->param("start_accession") )
                  : '';
                my $end_accession =
                  ( $query->param("end_accession") )
                  ? dt_from_string( scalar $query->param("end_accession") )
                  : '';


                my $conditions = {
                    ( $starting_biblionumber or $ending_biblionumber )
                        ? (
                            "me.biblionumber" => {
                                ( $starting_biblionumber ? ( '>=' => $starting_biblionumber ) : () ),
                                ( $ending_biblionumber   ? ( '<=' => $ending_biblionumber   ) : () ),
                            }
                        )
                        : (),

                    ( $start_callnumber or $end_callnumber )
                        ? (
                            'items.itemcallnumber' => {
                                ( $start_callnumber ? ( '>=' => $start_callnumber ) : () ),
                                ( $end_callnumber   ? ( '<=' => $end_callnumber   ) : () ),
                            }
                        )
                        : (),

                    ( $start_accession or $end_accession )
                        ? (
                            'items.dateaccessioned' => {
                                ( $start_accession ? ( '>=' => $start_accession ) : () ),
                                ( $end_accession   ? ( '<=' => $end_accession   ) : () ),
                            }
                        )
                        : (),
                    ( @branch ? ( 'items.homebranch' => { in => \@branch } ) : () ),
                    ( $itemtype
                        ?
                          C4::Context->preference('item-level_itypes')
                            ? ( 'items.itype' => $itemtype )
                            : ( 'biblioitems.itemtype' => $itemtype )
                        : ()
                    ),

                };
                my $biblioitems = Koha::Biblioitems->search( $conditions, { join => 'items', columns => 'biblionumber' } );
                while ( my $biblioitem = $biblioitems->next ) {
                    push @record_ids, $biblioitem->biblionumber;
                }
            }
            elsif ( $record_type eq 'auths' ) {
                my $starting_authid = $query->param('starting_authid');
                my $ending_authid   = $query->param('ending_authid');
                my $authtype        = $query->param('authtype');

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
        }

        @record_ids = uniq @record_ids;
        if ( @record_ids and my $filefh = $query->upload("id_list_file") ) {
            my @filter_record_ids = <$filefh>;
            @filter_record_ids = map { my $id = $_; $id =~ s/[\r\n]*$//; $id } @filter_record_ids;
            # intersection
            my %record_ids = map { $_ => 1 } @record_ids;
            @record_ids = grep $record_ids{$_}, @filter_record_ids;
        }

        print CGI->new->header(
            -type       => 'application/octet-stream',
            -charset    => 'utf-8',
            -attachment => $filename,
        );

        my $csv_profile_id = $query->param('csv_profile_id');
        unless ( $csv_profile_id ) {
            my $default_csv_profile = Koha::CsvProfiles->search({ profile => C4::Context->preference('ExportWithCsvProfile') });
            $csv_profile_id = $default_csv_profile ? $default_csv_profile->export_format_id : undef;
        }

        Koha::Exporter::Record::export(
            {   record_type        => $record_type,
                record_ids         => \@record_ids,
                format             => $output_format,
                filename           => $filename,
                itemnumbers        => \@itemnumbers,
                dont_export_fields => $export_remove_fields,
                csv_profile_id     => $csv_profile_id,
                export_items       => (not $dont_export_items),
            }
        );
    }
    elsif ( $record_type eq 'db' or $record_type eq 'conf' ) {
        my $successful_export;

        if ( $flags->{superlibrarian}
            and (
                    $record_type eq 'db' and C4::Context->config('backup_db_via_tools')
                 or
                    $record_type eq 'conf' and C4::Context->config('backup_conf_via_tools')
            )
        ) {
            binmode STDOUT, ':encoding(UTF-8)';

            my $charset  = 'utf-8';
            my $mimetype = 'application/octet-stream';
            if ( $filename =~ m/\.gz$/ ) {
                $mimetype = 'application/x-gzip';
                $charset  = '';
                binmode STDOUT;
            }
            elsif ( $filename =~ m/\.bz2$/ ) {
                $mimetype = 'application/x-bzip2';
                binmode STDOUT;
                $charset = '';
            }
            print $query->header(
                -type       => $mimetype,
                -charset    => $charset,
                -attachment => $filename,
            );

            my $extension = $record_type eq 'db' ? 'sql' : 'tar';

            $successful_export = download_backup(
                {
                    directory => $backupdir,
                    extension => $extension,
                    filename  => $filename,
                }
            );
            unless ($successful_export) {
                my $remotehost = $query->remote_host();
                $remotehost =~ s/(\n|\r)//;
                warn
    "A suspicious attempt was made to download the " . ( $record_type eq 'db' ? 'db' : 'configuration' ) . "at '$filename' by someone at "
                  . $remotehost . "\n";
            }
        }
    }

    exit;
}

else {

    my $itemtypes = GetItemTypes;
    my @itemtypesloop;
    foreach my $thisitemtype ( sort keys %$itemtypes ) {
        my %row = (
            value       => $thisitemtype,
            description => $itemtypes->{$thisitemtype}->{translated_description},
        );
        push @itemtypesloop, \%row;
    }
    my $branches = GetBranches($only_my_branch);
    my @branchloop;
    for my $thisbranch (
        sort { $branches->{$a}->{branchname} cmp $branches->{$b}->{branchname} }
        keys %{$branches}
      )
    {
        push @branchloop,
          {
            value      => $thisbranch,
            selected   => %branchmap ? $branchmap{$thisbranch} : 1,
            branchname => $branches->{$thisbranch}->{'branchname'},
          };
    }

    my $authority_types = Koha::Authority::Types->search( {}, { order_by => ['authtypecode'] } );

    if (   $flags->{superlibrarian}
        && C4::Context->config('backup_db_via_tools')
        && $backupdir
        && -d $backupdir )
    {
        $template->{VARS}->{'allow_db_export'} = 1;
        $template->{VARS}->{'dbfiles'}         = getbackupfilelist(
            { directory => "$backupdir", extension => 'sql' } );
    }

    if (   $flags->{superlibrarian}
        && C4::Context->config('backup_conf_via_tools')
        && $backupdir
        && -d $backupdir )
    {
        $template->{VARS}->{'allow_conf_export'} = 1;
        $template->{VARS}->{'conffiles'}         = getbackupfilelist(
            { directory => "$backupdir", extension => 'tar' } );
    }

    $template->param(
        branchloop               => \@branchloop,
        itemtypeloop             => \@itemtypesloop,
        authority_types          => $authority_types,
        export_remove_fields     => C4::Context->preference("ExportRemoveFields"),
        csv_profiles             => [ Koha::CsvProfiles->search({ type => 'marc' }) ],
    );

    output_html_with_http_headers $query, $cookie, $template->output;
}

sub getbackupfilelist {
    my $args      = shift;
    my $directory = $args->{directory};
    my $extension = $args->{extension};
    my @files;

    if ( opendir( my $dir, $directory ) ) {
        while ( my $file = readdir($dir) ) {
            next unless ( $file =~ m/\.$extension(\.(gz|bz2|xz))?/ );
            push @files, $file
              if ( -f "$directory/$file" && -r "$directory/$file" );
        }
        closedir($dir);
    }
    return \@files;
}

sub download_backup {
    my $args      = shift;
    my $directory = $args->{directory};
    my $extension = $args->{extension};
    my $filename  = $args->{filename};

    return unless ( $directory && -d $directory );
    return unless ( $filename =~ m/\.$extension(\.(gz|bz2|xz))?$/ );
    return if ( $filename =~ m#/# );
    $filename = "$directory/$filename";
    return unless ( -f $filename && -r $filename );
    return unless ( open( my $dump, '<', $filename ) );
    binmode $dump;

    while ( read( $dump, my $data, 64 * 1024 ) ) {
        print $data;
    }
    close($dump);
    return 1;
}
