#!/usr/bin/perl

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
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA


use strict;
use warnings;
use C4::Auth;
use C4::Output;
use C4::Biblio;  # GetMarcBiblio GetXmlBiblio
use C4::AuthoritiesMarc; # GetAuthority
use CGI;
use C4::Koha;    # GetItemTypes
use C4::Branch;  # GetBranches
use C4::Record;
use Getopt::Long;

my $query = new CGI;

my $op;
my $filename;
my $dbh         = C4::Context->dbh;
my $marcflavour = C4::Context->preference("marcflavour");
my $clean;
my $output_format;
my $dont_export_items;
my $deleted_barcodes;
my $timestamp;
my $record_type;
my $help;

# Checks if the script is called from commandline
my $commandline = not defined $ENV{GATEWAY_INTERFACE};

if ( $commandline ) {

    # Getting parameters
    $op = 'export';
    GetOptions(
        'format=s' => \$output_format,
        'date=s' => \$timestamp,
        'dont_export_items' => \$dont_export_items,
        'deleted_barcodes' => \$deleted_barcodes,
        'clean' => \$clean,
        'filename=s' => \$filename,
        'record-type=s' => \$record_type,
        'help|?' => \$help
    );

    if ($help) {
        print <<_USAGE_;
export.pl [--format=format] [--date=date] [--record-type=TYPE] [--dont_export_items] [--deleted_barcodes] [--clean] --filename=outputfile


 --format=FORMAT        FORMAT is either 'xml' or 'marc' (default)

 --date=DATE            DATE should be entered as the 'dateformat' syspref is
                        set (dd/mm/yyyy for metric, yyyy-mm-dd for iso,
                        mm/dd/yyyy for us) records exported are the ones that
                        have been modified since DATE

 --record-type=TYPE     TYPE is 'bibs' or 'auths'

 --deleted_barcodes     If used, a list of barcodes of items deleted since DATE
                        is produced (or from all deleted items if no date is
                        specified). Used only if TYPE is 'bibs'

 --clean                removes NSE/NSB
_USAGE_
        exit;
    }

    # Default parameters values :
    $output_format     ||= 'marc';
    $timestamp         ||= '';
    $dont_export_items ||= 0;
    $deleted_barcodes  ||= 0;
    $clean             ||= 0;
    $record_type       ||= "bibs";

    # Redirect stdout
    open STDOUT, '>', $filename if $filename;

} else {

    $op          = $query->param("op") || '';
    $filename    = $query->param("filename") || 'koha.mrc';
    $filename =~ s/(\r|\n)//;

}

my ($template, $loggedinuser, $cookie, $flags) = get_template_and_user(
    {
        template_name => "tools/export.tmpl",
        query => $query,
        type => "intranet",
        authnotrequired => $commandline,
        flagsrequired => {tools => 'export_catalog'},
        debug => 1,
    }
);

my $limit_ind_branch = (
    C4::Context->preference('IndependantBranches') &&
    C4::Context->userenv &&
    !(C4::Context->userenv->{flags} & 1) &&
    C4::Context->userenv->{branch}
) ? 1 : 0;

my $branch = $query->param("branch") || '';
if ( C4::Context->preference("IndependantBranches") &&
     C4::Context->userenv &&
     !(C4::Context->userenv->{flags} & 1) ) {
    $branch = C4::Context->userenv->{'branch'};
}

my $backupdir = C4::Context->config('backupdir');

if ($op eq "export") {
    my $charset  = 'utf-8';
    my $mimetype = 'application/octet-stream';
    binmode STDOUT, ':encoding(UTF-8)';
    if ( $filename =~ m/\.gz$/ ) {
        $mimetype = 'application/x-gzip';
        $charset = '';
        binmode STDOUT;
    } elsif ( $filename =~ m/\.bz2$/ ) {
        $mimetype = 'application/x-bzip2';
        binmode STDOUT;
        $charset = '';
    }
    print $query->header(
        -type => $mimetype,
        -charset => $charset,
        -attachment => $filename
    ) unless ($commandline);

    $record_type           = $query->param("record_type") unless ($commandline);
    $output_format         = $query->param("output_format") || 'marc' unless ($commandline);
    my $dont_export_fields = $query->param("dont_export_fields");
    my @sql_params;
    my $sql_query;

    my $StartingBiblionumber = $query->param("StartingBiblionumber");
    my $EndingBiblionumber   = $query->param("EndingBiblionumber");
    my $itemtype             = $query->param("itemtype");
    my $start_callnumber     = $query->param("start_callnumber");
    my $end_callnumber       = $query->param("end_callnumber");
    $timestamp = ($timestamp) ? C4::Dates->new($timestamp) : '' if ($commandline);
    my $start_accession =
      ( $query->param("start_accession") )
      ? C4::Dates->new( $query->param("start_accession") )
      : '';
    my $end_accession =
      ( $query->param("end_accession") )
      ? C4::Dates->new( $query->param("end_accession") )
      : '';
    $dont_export_items    = $query->param("dont_export_item") unless ($commandline);
    my $strip_nonlocal_items = $query->param("strip_nonlocal_items");

    my $biblioitemstable = ($commandline and $deleted_barcodes)
                                ? 'deletedbiblioitems'
                                : 'biblioitems';
    my $itemstable = ($commandline and $deleted_barcodes)
                                ? 'deleteditems'
                                : 'items';

    my $starting_authid = $query->param('starting_authid');
    my $ending_authid   = $query->param('ending_authid');
    my $authtype        = $query->param('authtype');

    if ( $record_type eq 'bibs' ) {
        if ($timestamp) {
            # Specific query when timestamp is used
            # Actually it's used only with CLI and so all previous filters
            # are not used.
            # If one day timestamp is used via the web interface, this part will
            # certainly have to be rewrited
            $sql_query = " (
                SELECT biblionumber
                FROM $biblioitemstable
                  LEFT JOIN items USING(biblionumber)
                WHERE $biblioitemstable.timestamp >= ?
                  OR items.timestamp >= ?
            ) UNION (
                SELECT biblionumber
                FROM $biblioitemstable
                  LEFT JOIN deleteditems USING(biblionumber)
                WHERE $biblioitemstable.timestamp >= ?
                  OR deleteditems.timestamp >= ?
            ) ";
            my $ts = $timestamp->output('iso');
            @sql_params = ($ts, $ts, $ts, $ts);
        } else {
            my $items_filter =
                $branch || $start_callnumber || $end_callnumber ||
                $start_accession || $timestamp || $end_accession ||
                ($itemtype && C4::Context->preference('item-level_itypes'));
            $sql_query = $items_filter ?
                "SELECT DISTINCT $biblioitemstable.biblionumber
                FROM $biblioitemstable JOIN $itemstable
                USING (biblionumber) WHERE 1"
                :
                "SELECT $biblioitemstable.biblionumber FROM $biblioitemstable WHERE biblionumber >0 ";

            if ( $StartingBiblionumber ) {
                $sql_query .= " AND $biblioitemstable.biblionumber >= ? ";
                push @sql_params, $StartingBiblionumber;
            }

            if ( $EndingBiblionumber ) {
                $sql_query .= " AND $biblioitemstable.biblionumber <= ? ";
                push @sql_params, $EndingBiblionumber;
            }

            if ($branch) {
                $sql_query .= " AND homebranch = ? ";
                push @sql_params, $branch;
            }

            if ($start_callnumber) {
                $sql_query .= " AND itemcallnumber <= ? ";
                push @sql_params, $start_callnumber;
            }

            if ($end_callnumber) {
                $sql_query .= " AND itemcallnumber >= ? ";
                push @sql_params, $end_callnumber;
            }
            if ($start_accession) {
                $sql_query .= " AND dateaccessioned >= ? ";
                push @sql_params, $start_accession->output('iso');
            }

            if ($end_accession) {
                $sql_query .= " AND dateaccessioned <= ? ";
                push @sql_params, $end_accession->output('iso');
            }

            if ( $itemtype ) {
                $sql_query .= (C4::Context->preference('item-level_itypes')) ? " AND items.itype = ? " : " AND biblioitems.itemtype = ?";
                push @sql_params, $itemtype;
            }
        }
    }
    elsif ( $record_type eq 'auths' ) {
        $sql_query =
          "SELECT DISTINCT auth_header.authid FROM auth_header WHERE 1";

        if ($starting_authid) {
            $sql_query .= " AND auth_header.authid >= ? ";
            push @sql_params, $starting_authid;
        }

        if ($ending_authid) {
            $sql_query .= " AND auth_header.authid <= ? ";
            push @sql_params, $ending_authid;
        }

        if ($authtype) {
            $sql_query .= " AND auth_header.authtypecode = ? ";
            push @sql_params, $authtype;
        }
    }
    elsif ( $record_type eq 'db' ) {
        my $successful_export;
        if ( $flags->{superlibrarian} && C4::Context->config('backup_db_via_tools') ) {
            $successful_export = download_backup( { directory => "$backupdir", extension => 'sql', filename => "$filename" } )
        }
        unless ( $successful_export ) {
            my $remotehost = $query->remote_host();
            $remotehost =~ s/(\n|\r)//;
            warn "A suspicious attempt was made to download the db at '$filename' by someone at " . $remotehost . "\n";
        }
        exit;
    }
    elsif ( $record_type eq 'conf' ) {
        my $successful_export;
        if ( $flags->{superlibrarian} && C4::Context->config('backup_conf_via_tools') ) {
            $successful_export = download_backup( { directory => "$backupdir", extension => 'tar', filename => "$filename" } )
        }
        unless ( $successful_export ) {
            my $remotehost = $query->remote_host();
            $remotehost =~ s/(\n|\r)//;
            warn "A suspicious attempt was made to download the configuration at '$filename' by someone at " . $remotehost . "\n";
        }
        exit;
    }
    else {
        # Someone is trying to mess us up
        exit;
    }

    my $sth = $dbh->prepare($sql_query);
    $sth->execute(@sql_params);

    while ( my ($recordid) = $sth->fetchrow ) {
        if ( $deleted_barcodes ) {
            my $q = "
                SELECT DISTINCT barcode
                FROM deleteditems
                WHERE deleteditems.biblionumber = ?
            ";
            my $sth = $dbh->prepare($q);
            $sth->execute($recordid);
            while (my $row = $sth->fetchrow_array) {
                print "$row\n";
            }
        } else {
            my $record;
            if ( $record_type eq 'bibs' ) {
                $record = eval { GetMarcBiblio($recordid); };

                if ($@) {
                    next;
                }
                next if not defined $record;
                C4::Biblio::EmbedItemsInMarcBiblio( $record, $recordid )
                  unless $dont_export_items;
                if ( $strip_nonlocal_items || $limit_ind_branch ) {
                    my ( $homebranchfield, $homebranchsubfield ) =
                      GetMarcFromKohaField( 'items.homebranch', '' );
                    for my $itemfield ( $record->field($homebranchfield) ) {

    # if stripping nonlocal items, use loggedinuser's branch if they didn't select one
                        $branch = C4::Context->userenv->{'branch'} unless $branch;
                        $record->delete_field($itemfield)
                          if (
                            $itemfield->subfield($homebranchsubfield) ne $branch );
                    }
                }
            }
            elsif ( $record_type eq 'auths' ) {
                $record = C4::AuthoritiesMarc::GetAuthority($recordid);
                next if not defined $record;
            }

            if ( $dont_export_fields ) {
                my @fields = split " ", $dont_export_fields;
                foreach ( @fields ) {
                    /^(\d*)(\w)?$/;
                    my $field = $1;
                    my $subfield = $2;
                    # skip if this record doesn't have this field
                    next if not defined $record->field($field);
                    if( $subfield ) {
                        $record->field($field)->delete_subfields($subfield);
                    }
                    else {
                        $record->delete_field($record->field($field));
                    }
                }
            }
            RemoveAllNsb($record) if ($clean);
            if ( $output_format eq "xml" ) {
                if ($marcflavour eq 'UNIMARC' && $record_type eq 'auths') {
                    print $record->as_xml_record('UNIMARCAUTH');
                } else {
                    print $record->as_xml_record($marcflavour);
                }
            }
            else {
                print $record->as_usmarc();
            }
        }
    }
    exit;

}    # if export

else {

    my $itemtypes = GetItemTypes;
    my @itemtypesloop;
    foreach my $thisitemtype (sort keys %$itemtypes) {
        my %row =
            (
                value => $thisitemtype,
                description => $itemtypes->{$thisitemtype}->{'description'},
            );
       push @itemtypesloop, \%row;
    }
    my $branches = GetBranches($limit_ind_branch);
    my @branchloop;
    for my $thisbranch (
        sort { $branches->{$a}->{branchname} cmp $branches->{$b}->{branchname} }
        keys %{$branches}
      ) {
        push @branchloop,
          { value      => $thisbranch,
            selected   => $thisbranch eq $branch,
            branchname => $branches->{$thisbranch}->{'branchname'},
          };
    }

    my $authtypes = getauthtypes;
    my @authtypesloop;
    foreach my $thisauthtype ( sort keys %$authtypes ) {
        next unless $thisauthtype;
        my %row = (
            value       => $thisauthtype,
            description => $authtypes->{$thisauthtype}->{'authtypetext'},
        );
        push @authtypesloop, \%row;
    }

    if ( $flags->{superlibrarian} && C4::Context->config('backup_db_via_tools') && $backupdir && -d $backupdir ) {
        $template->{VARS}->{'allow_db_export'} = 1;
        $template->{VARS}->{'dbfiles'} = getbackupfilelist( { directory => "$backupdir", extension => 'sql' } );
    }

    if ( $flags->{superlibrarian} && C4::Context->config('backup_conf_via_tools') && $backupdir && -d $backupdir ) {
        $template->{VARS}->{'allow_conf_export'} = 1;
        $template->{VARS}->{'conffiles'} = getbackupfilelist( { directory => "$backupdir", extension => 'tar' } );
    }

    $template->param(
        branchloop               => \@branchloop,
        itemtypeloop             => \@itemtypesloop,
        DHTMLcalendar_dateformat => C4::Dates->DHTMLcalendar(),
        authtypeloop             => \@authtypesloop,
        dont_export_fields       => C4::Context->preference("DontExportFields"),
    );

    output_html_with_http_headers $query, $cookie, $template->output;
}

sub getbackupfilelist {
    my $args = shift;
    my $directory = $args->{directory};
    my $extension = $args->{extension};
    my @files;

    if ( opendir(my $dir, $directory) ) {
        while (my $file = readdir($dir)) {
            next unless ( $file =~ m/\.$extension(\.(gz|bz2|xz))?/ );
            push @files, $file if ( -f "$directory/$file" && -r "$directory/$file" );
        }
        closedir($dir);
    }
    return \@files;
}

sub download_backup {
    my $args = shift;
    my $directory = $args->{directory};
    my $extension = $args->{extension};
    my $filename  = $args->{filename};

    return unless ( $directory && -d $directory );
    return unless ( $filename =~ m/\.$extension(\.(gz|bz2|xz))?$/ );
    return if ( $filename =~ m#/# );
    $filename = "$directory/$filename";
    return unless ( -f $filename && -r $filename );
    return unless ( open(my $dump, '<', $filename) );
    binmode $dump;
    while (read($dump, my $data, 64 * 1024)) {
        print $data;
    }
    close ($dump);
    return 1;
}
