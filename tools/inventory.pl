#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
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
use CGI;
use C4::Auth;
use C4::Context;
use C4::Output;
use C4::Biblio;
use C4::Items;
use C4::Dates qw/format_date format_date_in_iso/;
use C4::Koha;
use C4::Branch; # GetBranches

my $input = new CGI;
my $minlocation=$input->param('minlocation') || '';
my $maxlocation=$input->param('maxlocation');
$maxlocation=$minlocation.'Z' unless ( $maxlocation || ! $minlocation );
my $location=$input->param('location');
my $itemtype=$input->param('itemtype');
my $datelastseen = $input->param('datelastseen');
my $offset = $input->param('offset');
my $markseen = $input->param('markseen');
$offset=0 unless $offset;
my $pagesize = $input->param('pagesize');
$pagesize=50 unless $pagesize;
my $uploadbarcodes = $input->param('uploadbarcodes');
my $branchcode = $input->param('branchcode');
my $op = $input->param('op');
# warn "uploadbarcodes : ".$uploadbarcodes;
# use Data::Dumper; warn Dumper($input);
my ($template, $borrowernumber, $cookie)
    = get_template_and_user({template_name => "tools/inventory.tmpl",
                query => $input,
                type => "intranet",
                authnotrequired => 0,
                flagsrequired => {tools => 'inventory'},
                debug => 1,
                });

my $branches = GetBranches();
my @branch_loop;
push @branch_loop, {value => "", branchname => "All Locations", };
for my $branch_hash (keys %$branches) {
	push @branch_loop, {value => "$branch_hash",
	                   branchname => $branches->{$branch_hash}->{'branchname'}, 
	                   selected => ($branch_hash eq $branchcode?1:0)};	
}
 

my $itemtypes = GetItemTypes;
my @itemtypesloop;
foreach my $thisitemtype (sort keys %$itemtypes) {
    my $selected = 1 if $thisitemtype eq $itemtype;
    my %row =(value => $thisitemtype,
                selected => $selected,
                description => $itemtypes->{$thisitemtype}->{'description'},
            );
    push @itemtypesloop, \%row;
}
$template->param(itemtypeloop => \@itemtypesloop);

my @authorised_value_list;
my $authorisedvalue_categories;

my $dbh=C4::Context->dbh;
my $rqauthcategorie=$dbh->prepare("SELECT authorised_value FROM marc_subfield_structure WHERE frameworkcode=? AND kohafield='items.location'");
my $rq=$dbh->prepare("SELECT frameworkcode FROM biblio_framework");
$rq->execute;
while (my ($fwkcode)=$rq->fetchrow){
  $rqauthcategorie->execute($fwkcode);
  while (my ($authcat)=$rqauthcategorie->fetchrow){
    if ($authcat && $authorisedvalue_categories!~/\b$authcat\W/){
      $authorisedvalue_categories.="$authcat ";
      my $data=GetAuthorisedValues($authcat);
      foreach my $value (@$data){
        $value->{selected}=1 if ($value->{authorised_value} eq ($location));
      }      
      push @authorised_value_list,@$data;
    }  
  }
}


 
$template->param(branchloop => \@branch_loop,
                authorised_values=>\@authorised_value_list,   
                DHTMLcalendar_dateformat => C4::Dates->DHTMLcalendar(),
                minlocation => $minlocation,
                maxlocation => $maxlocation,
                location=>$location,
                branchcode=>$branchcode,      
                offset => $offset,
                pagesize => $pagesize,
                datelastseen => $datelastseen,
                );
if ($uploadbarcodes && length($uploadbarcodes)>0){
    my $dbh=C4::Context->dbh;
    my $date = format_date_in_iso($input->param('setdate')) || C4::Dates->today('iso');
# 	warn "$date";
    my $strsth="select * from issues, items where items.itemnumber=issues.itemnumber and items.barcode =?";
    my $qonloan = $dbh->prepare($strsth);
    $strsth="select * from items where items.barcode =? and issues.wthdrawn=1";
    my $qwthdrawn = $dbh->prepare($strsth);
    my @errorloop;
    my $count=0;
    while (my $barcode=<$uploadbarcodes>){
        chomp $barcode;
# 		warn "$barcode";
        if ($qwthdrawn->execute($barcode) &&$qwthdrawn->rows){
            push @errorloop, {'barcode'=>$barcode,'ERR_WTHDRAWN'=>1};
        }else{
            my $item = GetItem('', $barcode);
            if (defined $item){
                ModItem({ datelastseen => $date }, undef, $item->{'itemnumber'});
                $count++;
                $qonloan->execute($barcode);
                if ($qonloan->rows){
                    my $data = $qonloan->fetchrow_hashref;
                    my ($doreturn, $messages, $iteminformation, $borrower) =AddReturn($barcode, $data->{homebranch});
                    if ($doreturn){push @errorloop, {'barcode'=>$barcode,'ERR_ONLOAN_RET'=>1}}
                    else {push @errorloop, {'barcode'=>$barcode,'ERR_ONLOAN_NOT_RET'=>1}}
                }
            } else {
                push @errorloop, {'barcode'=>$barcode,'ERR_BARCODE'=>1};
            }
        }
    }
    $qonloan->finish;
    $qwthdrawn->finish;
    $template->param(date=>format_date($date),Number=>$count);
# 	$template->param(errorfile=>$errorfile) if ($errorfile);
    $template->param(errorloop=>\@errorloop) if (@errorloop);
}else{
    if ($markseen) {
        foreach ($input->param) {
            /SEEN-(.+)/ and &ModDateLastSeen($1);
        }
    }
    if ($markseen or $op) {
        my $res = GetItemsForInventory($minlocation,$maxlocation,$location,$itemtype,$datelastseen,$branchcode,$offset,$pagesize);
        $template->param(loop =>$res,
                        nextoffset => ($offset+$pagesize),
                        prevoffset => ($offset?$offset-$pagesize:0),
                        );
    }
}
output_html_with_http_headers $input, $cookie, $template->output;

# Local Variables:
# tab-width: 8
# End:
