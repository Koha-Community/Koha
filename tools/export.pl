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
use Data::Dumper;

my $query = new CGI;
my $op=$query->param("op") || '';
my $filename=$query->param("filename");
$filename =~ s/(\r|\n)//;
my $dbh=C4::Context->dbh;
my $marcflavour = C4::Context->preference("marcflavour");

my ($template, $loggedinuser, $cookie, $flags)
    = get_template_and_user
    (
        {
            template_name => "tools/export.tmpl",
            query => $query,
            type => "intranet",
            authnotrequired => 0,
            flagsrequired => {tools => 'export_catalog'},
            debug => 1,
            }
    );

	my $limit_ind_branch=(C4::Context->preference('IndependantBranches') &&
              C4::Context->userenv &&
              !(C4::Context->userenv->{flags} & 1) &&
              C4::Context->userenv->{branch}?1:0);
	my $branches = GetBranches($limit_ind_branch);    
    my $branch                = $query->param("branch") || '';
	if ( C4::Context->preference("IndependantBranches") &&
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
    print $query->header(   -type => $mimetype,
                            -charset => $charset,
                            -attachment=>$filename);
     
    my $record_type        = $query->param("record_type");
    my $output_format      = $query->param("output_format");
    my $dont_export_fields = $query->param("dont_export_fields");
    my @sql_params;
    my $sql_query;

    my $StartingBiblionumber = $query->param("StartingBiblionumber");
    my $EndingBiblionumber   = $query->param("EndingBiblionumber");
    my $itemtype             = $query->param("itemtype");
    my $start_callnumber     = $query->param("start_callnumber");
    my $end_callnumber       = $query->param("end_callnumber");
    my $start_accession =
      ( $query->param("start_accession") )
      ? C4::Dates->new( $query->param("start_accession") )
      : '';
    my $end_accession =
      ( $query->param("end_accession") )
      ? C4::Dates->new( $query->param("end_accession") )
      : '';
    my $dont_export_items    = $query->param("dont_export_item");
    my $strip_nonlocal_items = $query->param("strip_nonlocal_items");

    my $starting_authid = $query->param('starting_authid');
    my $ending_authid   = $query->param('ending_authid');
    my $authtype        = $query->param('authtype');

    if ( $record_type eq 'bibs' ) {
        my $items_filter =
            $branch || $start_callnumber || $end_callnumber ||
            $start_accession || $end_accession ||
            ($itemtype && C4::Context->preference('item-level_itypes'));
        $sql_query = $items_filter ?
            "SELECT DISTINCT biblioitems.biblionumber
            FROM biblioitems JOIN items
            USING (biblionumber) WHERE 1"
            :
            "SELECT biblioitems.biblionumber FROM biblioitems WHERE biblionumber >0 ";

        if ( $StartingBiblionumber ) {
            $sql_query .= " AND biblioitems.biblionumber >= ? ";
            push @sql_params, $StartingBiblionumber;
        }

        if ( $EndingBiblionumber ) {
            $sql_query .= " AND biblioitems.biblionumber <= ? ";
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
        my $record;
        if ( $record_type eq 'bibs' ) {
            $record = eval { GetMarcBiblio($recordid); };

     # FIXME: decide how to handle records GetMarcBiblio can't parse or retrieve
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
            push @files, $file if ( -f "$backupdir/$file" && -r "$backupdir/$file" );
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
