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
require Exporter;
use C4::Auth;
use C4::Output;  # contains gettemplate
use C4::Biblio;  # GetMarcBiblio GetXmlBiblio
use CGI;
use C4::Koha;    # GetItemTypes
use C4::Branch;  # GetBranches

my $query = new CGI;
my $op=$query->param("op");
my $filename=$query->param("filename");
my $dbh=C4::Context->dbh;
my $marcflavour = C4::Context->preference("marcflavour");

my ($template, $loggedinuser, $cookie)
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
              C4::Context->userenv->{flags} !=1  &&
              C4::Context->userenv->{branch}?1:0);
	my $branches = GetBranches($limit_ind_branch);    
    my $branch                = $query->param("branch");
	if ( C4::Context->preference("IndependantBranches") ) {
    	$branch = C4::Context->userenv->{'branch'};
	}

if ($op eq "export") {
    binmode(STDOUT,":utf8");
	print $query->header(   -type => 'application/octet-stream', 
                            -charset => 'utf-8',
                            -attachment=>$filename);
     
    my $StartingBiblionumber  = $query->param("StartingBiblionumber");
    my $EndingBiblionumber    = $query->param("EndingBiblionumber");
    my $output_format         = $query->param("output_format");
    my $itemtype              = $query->param("itemtype");
    my $start_callnumber      = $query->param("start_callnumber");
    my $end_callnumber        = $query->param("end_callnumber");
    my $start_accession      = ($query->param("start_accession")) ? C4::Dates->new($query->param("start_accession")) : '' ;
    my $end_accession        = ($query->param("end_accession")) ? C4::Dates->new($query->param("end_accession")) : '' ;
    my $dont_export_items     = $query->param("dont_export_item");
    my $strip_nonlocal_items   = $query->param("strip_nonlocal_items");
    my $dont_export_fields    = $query->param("dont_export_fields");
    my @sql_params;
    
    my $items_filter =
        $branch || $start_callnumber || $end_callnumber ||  
        $start_accession || $end_accession || 
        ($itemtype && C4::Context->preference('item-level_itypes'));
    my $query = $items_filter ?
        "SELECT DISTINCT biblioitems.biblionumber
         FROM biblioitems,items
         WHERE biblioitems.biblionumber=items.biblionumber "
        :
        "SELECT biblioitems.biblionumber FROM biblioitems WHERE biblionumber >0 ";
                  
    if ( $StartingBiblionumber ) {
        $query .= " AND biblioitems.biblionumber >= ? ";
        push @sql_params, $StartingBiblionumber;
    }
    
    if ( $EndingBiblionumber ) {
        $query .= " AND biblioitems.biblionumber <= ? ";
        push @sql_params, $EndingBiblionumber;    
    }
    
    if ( $branch ) {
        $query .= " AND biblioitems.biblionumber = items.biblionumber AND homebranch = ? ";
        push @sql_params, $branch;
    }
    
    if ( $start_callnumber ) {
        $query .= " AND biblioitems.biblionumber = items.biblionumber AND itemcallnumber <= ? ";
        push @sql_params, $start_callnumber;
    }
    
    if ( $end_callnumber ) {
        $query .= " AND biblioitems.biblionumber = items.biblionumber AND itemcallnumber >= ? ";
        push @sql_params, $end_callnumber;
    }
    if ( $start_accession ) {
        $query .= " AND biblioitems.biblionumber = items.biblionumber AND dateaccessioned >= ? ";
        push @sql_params,$start_accession->output('iso');
    }
    
    if ( $end_accession ) {
        $query .= " AND biblioitems.biblionumber = items.biblionumber AND dateaccessioned <= ? ";
        push @sql_params, $end_accession->output('iso');
    }
    
    if ( $itemtype ) {
        $query .= (C4::Context->preference('item-level_itypes')) ? " AND items.itype = ? " : " AND biblioitems.itemtype = ?";
        push @sql_params, $itemtype;
    }
    my $sth = $dbh->prepare($query);
    $sth->execute(@sql_params);
    
    while (my ($biblionumber) = $sth->fetchrow) {
        my $record = GetMarcBiblio($biblionumber);

        if ( $dont_export_items || $strip_nonlocal_items || $limit_ind_branch) {
            my ( $homebranchfield, $homebranchsubfield ) =
                GetMarcFromKohaField( 'items.homebranch', '' );
			for my $itemfield ($record->field($homebranchfield)){
				# if stripping nonlocal items, use loggedinuser's branch if they didn't select one
				$branch = C4::Context->userenv->{'branch'} unless $branch;
                $record->delete_field($itemfield) if($dont_export_items || ($itemfield->subfield($homebranchsubfield) ne $branch) ) ;
            }
        }
        
        if ( $dont_export_fields ) {
            my @fields = split " ", $dont_export_fields;
            foreach ( @fields ) {
                /^(\d*)(\w)?$/;
                my $field = $1;
                my $subfield = $2;
                if( $subfield ) {
                    $record->field($field)->delete_subfields($subfield);
                }
                else {
                    $record->delete_field($record->field($field));
                }
            }
        }
        if ( $output_format eq "xml" ) {
            print $record->as_xml_record($marcflavour);
        }
        else {
            print $record->as_usmarc(); 
        }
    }
    exit;
    
} # if export

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
	for my $thisbranch (sort { $branches->{$a}->{branchname} cmp $branches->{$b}->{branchname} } keys %$branches) {
        my $selected = 1 if $thisbranch eq $branch;
        my %row = (
            value => $thisbranch,
            selected => $selected,
            branchname => $branches->{$thisbranch}->{'branchname'},
       );
       push @branchloop, \%row;
    }
    
    $template->param(
        branchloop   => \@branchloop,
        itemtypeloop => \@itemtypesloop,
		DHTMLcalendar_dateformat => C4::Dates->DHTMLcalendar(),
    );
    
    output_html_with_http_headers $query, $cookie, $template->output;
}
