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
use List::MoreUtils qw( uniq );
use C4::Auth qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );

use Koha::Authority::Types;
use Koha::Biblioitems;
use Koha::CsvProfiles;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );
use Koha::Exporter::Record;
use Koha::ItemTypes;
use Koha::Libraries;

my $query = CGI->new;

my $dont_export_items = $query->param("dont_export_item") || 0;
my $record_type       = $query->param("record_type");
my $op                = $query->param("op") || '';
my $output_format     = $query->param("format") || $query->param("output_format") || 'iso2709';
my $backupdir         = C4::Context->config('backupdir');
my $filename;
if ( $record_type && $record_type eq 'auths' ) {
    $filename = $query->param("filename_auth") || ( $output_format eq 'xml' ? 'koha.xml' : 'koha.mrc' );
} else {
    $filename = $query->param("filename") || ( $output_format eq 'csv' ? 'koha.csv' : 'koha.mrc' );
}
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
        flagsrequired   => { tools => 'export_catalog' },
    }
);

my @branch = $query->multi_param("branch");

my @messages;
if ( $op eq 'export' ) {
    my $filename = $query->param('id_list_file');
    if ( $filename ) {
        my $mimetype = $query->uploadInfo($filename)->{'Content-Type'};
        my @valid_mimetypes = qw( application/octet-stream text/csv text/plain application/vnd.ms-excel );
        unless ( grep { $_ eq $mimetype } @valid_mimetypes ) {
            push @messages, { type => 'alert', code => 'invalid_mimetype' };
            $op = '';
        }
    }
}

if ( $op eq "export" ) {

    my $export_remove_fields = $query->param("export_remove_fields") || q||;
    my @biblionumbers      = $query->multi_param("biblionumbers");
    my @itemnumbers        = $query->multi_param("itemnumbers");
    my $strip_items_not_from_libraries =  $query->param('strip_items_not_from_libraries');

    my $libraries = Koha::Libraries->search_filtered->unblessed;
    my $only_export_items_for_branches = $strip_items_not_from_libraries ? \@branch : undef;
    my @branchcodes;
    for my $branchcode ( @branch ) {
        if ( grep { $_->{branchcode} eq $branchcode } @$libraries ) {
            push @branchcodes, $branchcode;
        }
    }

    if ( $record_type eq 'bibs' or $record_type eq 'auths' ) {
        # No need to retrieve the record_ids if we already get them
        unless ( @record_ids ) {
            if ( $record_type eq 'bibs' ) {

                my %it_map = map { $_->itemtype => 1 } Koha::ItemTypes->search->as_list;
                my @itemtypes = map { $it_map{$_} ? $_ : () } $query->multi_param('itemtype'); #Validate inputs against map

                my $starting_biblionumber = $query->param("StartingBiblionumber");
                my $ending_biblionumber   = $query->param("EndingBiblionumber");
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
                    ( @branchcodes ? ( 'items.homebranch' => { in => \@branchcodes } ) : () ),
                    ( @itemtypes
                        ?
                          C4::Context->preference('item-level_itypes')
                            ? ( 'items.itype' => { in => \@itemtypes } )
                            : ( 'me.itemtype' => { in => \@itemtypes } )
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

        my $export_items_bundle_contents = $query->param('export_items_bundle_contents');
        if ($export_items_bundle_contents and $record_type eq 'bibs') {
            my $schema = Koha::Database->new->schema;
            my $items_bundle_rs = $schema->resultset('ItemBundle');
            foreach my $itemnumber (@itemnumbers) {
                my @item_bundle_items = $items_bundle_rs->search({ host => $itemnumber });
                foreach my $item_bundle_item (@item_bundle_items) {
                    my $biblionumber = $item_bundle_item->item->get_column('biblionumber');
                    my $itemnumber = $item_bundle_item->get_column('item');
                    push @record_ids, $biblionumber;
                    push @itemnumbers, $itemnumber;
                }
            }
            @record_ids = uniq @record_ids;
        }

        print CGI->new->header(
            -type       => 'application/octet-stream',
            -charset    => 'utf-8',
            -attachment => $filename,
        );

        my $csv_profile_id = $query->param('csv_profile_id');
        Koha::Exporter::Record::export(
            {   record_type        => $record_type,
                record_ids         => \@record_ids,
                format             => $output_format,
                filename           => $filename,
                itemnumbers        => \@itemnumbers,
                dont_export_fields => $export_remove_fields,
                csv_profile_id     => $csv_profile_id,
                export_items       => (not $dont_export_items),
                only_export_items_for_branches => $only_export_items_for_branches,
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

    my $itemtypes = Koha::ItemTypes->search_with_localization;

    my $authority_types = Koha::Authority::Types->search( {}, { order_by => ['authtypecode'] } );

    my $libraries = Koha::Libraries->search_filtered({}, { order_by => ['branchname'] })->unblessed;
    for my $library ( @$libraries ) {
        $library->{selected} = 1 if grep { $library->{branchcode} eq $_ } @branch;
    }

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
        libraries                => $libraries,
        itemtypes                => $itemtypes,
        authority_types          => $authority_types,
        export_remove_fields     => C4::Context->preference("ExportRemoveFields"),
        csv_profiles             => [ Koha::CsvProfiles->search({ type => 'marc', used_for => 'export_records' })->as_list ],
        messages                 => \@messages,
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
