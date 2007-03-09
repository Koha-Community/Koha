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

# $Id$

use C4::Branch; # GetBranches
use strict;
require Exporter;

use C4::Auth;
use C4::Interface::CGI::Output;
use C4::Output;  # contains gettemplate
use C4::Biblio;
use CGI;
use C4::Koha;

my $query = new CGI;
my $op=$query->param("op");
my $dbh=C4::Context->dbh;

if ($op eq "export") {
    print $query->header(    -type => 'application/octet-stream',
                -attachment=>'koha.mrc');
    my $StartingBiblionumber = $query->param("StartingBiblionumber");
    my $EndingBiblionumber = $query->param("EndingBiblionumber");
    my $format = $query->param("format");
    my $branch = $query->param("branch");
    my $start_callnumber = $query->param("start_callnumber");
    my $end_callnumber = $query->param("end_callnumber");
    my $limit = $query->param("limit");
    my $strsth;
    $strsth="select bibid from marc_biblio ";
    if ($StartingBiblionumber && $EndingBiblionumber) {
        $strsth.=" where biblionumber>=$StartingBiblionumber and biblionumber<=$EndingBiblionumber ";
    }elsif ($format) {
        if ($strsth=~/ where/){
            $strsth=~s/ where (.*)/,biblioitems where biblioitems.biblionumber=marc_biblio.biblionumber and biblioitems.itemtype=\'$format\' and $1/;
        }else {
            $strsth.=",biblioitems where biblioitems.biblionumber=marc_biblio.biblionumber and biblioitems.itemtype=\'$format\'";
        }
    } elsif ($branch) {
        if ($strsth=~/ where/){
            $strsth=~s/ where (.*)/,items where items.biblionumber=marc_biblio.biblionumber and items.homebranch=\'$branch\' and $1/;
        }else {
            $strsth.=",items where items.biblionumber=marc_biblio.biblionumber and items.homebranch=\'$branch\'";
        }
    } elsif ($start_callnumber && $end_callnumber) {
        $start_callnumber=~s/\*/\%/g;
        $start_callnumber=~s/\?/\_/g;
        $end_callnumber=~s/\*/\%/g;
        $end_callnumber=~s/\?/\_/g;
        if ($strsth=~/,items/){
            $strsth.=" and items.itemcallnumber between \'$start_callnumber\' and \'$end_callnumber\'";
        } else {
            if ($strsth=~/ where/){
                $strsth=~s/ where (.*)/,items where items.biblionumber=marc_biblio.biblionumber and items.itemcallnumber between \'$start_callnumber\' and \'$end_callnumber\' and $1/;
            }else {
                $strsth=~",items where items.biblionumber=marc_biblio.biblionumber and items.itemcallnumber between \'$start_callnumber\' and \'$end_callnumber\' ";
            }
        }
    }
    $strsth.=" order by marc_biblio.biblionumber ";
    $strsth.= "LIMIT 0,$limit " if ($limit);
    warn "requete marc.pl : ".$strsth;
    my $req=$dbh->prepare($strsth);
    $req->execute;
    while (my ($bibid) = $req->fetchrow) {
        my $record = GetMarcBiblio($bibid);

        print $record->as_usmarc();
    }
} else {
    my $sth=$dbh->prepare("Select itemtype,description from itemtypes order by description");
    $sth->execute;
    my  @itemtype;
    my %itemtypes;
    push @itemtype, "";
    $itemtypes{''} = "";
    while (my ($value,$lib) = $sth->fetchrow_array) {
            push @itemtype, $value;
            $itemtypes{$value}=$lib;
    }
    
    my $CGIitemtype=CGI::scrolling_list( -name     => 'format',
                            -values   => \@itemtype,
                            -default  => '',
                            -labels   => \%itemtypes,
                            -size     => 1,
                             -tabindex=>'',
                            -multiple => 0 );
    $sth->finish;
    
    my $branches = GetBranches;
    my @branchloop;
    foreach my $thisbranch (keys %$branches) {
#             my $selected = 1 if $thisbranch eq $branch;
            my %row =(value => $thisbranch,
#                                     selected => $selected,
                                    branchname => $branches->{$thisbranch}->{'branchname'},
                            );
            push @branchloop, \%row;
    }
    
    my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "export/marc.tmpl",
                    query => $query,
                    type => "intranet",
                    authnotrequired => 0,
                    flagsrequired => {tools => 1},
                    debug => 1,
                    });
    $template->param(branchloop=>\@branchloop,
            CGIitemtype=>$CGIitemtype,
            intranetcolorstylesheet => C4::Context->preference("intranetcolorstylesheet"),
        intranetstylesheet => C4::Context->preference("intranetstylesheet"),
        IntranetNav => C4::Context->preference("IntranetNav"),
            );
    output_html_with_http_headers $query, $cookie, $template->output;
}

