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
use C4::Context;
use C4::Output;
use C4::Auth;
use C4::Koha;
use C4::Branch; # GetBranches

my $input = new CGI;
my $dbh = C4::Context->dbh;

my $type=$input->param('type');
my $branch = $input->param('branch');
$branch="*" unless $branch;
my $op = $input->param('op');

# my $flagsrequired;
# $flagsrequired->{circulation}=1;
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "admin/issuingrules.tmpl",
                            query => $input,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => {parameters => 1},
                            debug => 1,
                            });
# save the values entered
if ($op eq 'save') {
    my @names=$input->param();
    my $sth_search = $dbh->prepare("SELECT branchcode FROM issuingrules WHERE branchcode=? and categorycode=? and itemtype=?");

    my $sth_Iinsert = $dbh->prepare("INSERT INTO issuingrules (branchcode,categorycode,itemtype,maxissueqty,issuelength,rentaldiscount) VALUES (?,?,?,?,?,?)");
    my $sth_Iupdate=$dbh->prepare("UPDATE issuingrules SET maxissueqty=?, issuelength=?, rentaldiscount=? WHERE branchcode=? AND categorycode=? AND itemtype=?");
    my $sth_Idelete=$dbh->prepare("DELETE FROM issuingrules WHERE branchcode=? AND categorycode=? AND itemtype=?");
    foreach my $key (@names){
        # ISSUES
        if ($key =~ /I-(.*)-(.*)-(.*)/) {
            my $br = base64_to_str($1); # branch
            my $bor =  base64_to_str($2); # borrower category
            my $cat =  base64_to_str($3); # item type
            my $data=$input->param($key);
            my ($issuelength,$maxissueqty,$rentaldiscount)=split(',',$data);
            if ($maxissueqty) {
                $sth_search->execute($br,$bor,$cat);
                my $res = $sth_search->fetchrow_hashref();
                warn "$br / $bor / $cat = ".$res->{'total'};
                if ( $res->{'branchcode'} ne $br ) {
                    $sth_Iinsert->execute($br,$bor,$cat,$maxissueqty,$issuelength,$rentaldiscount);
                } else {
                    $sth_Iupdate->execute($maxissueqty,$issuelength,$rentaldiscount,$br,$bor,$cat);
                }
            } else {
                $sth_Idelete->execute($br,$bor,$cat);
            }
        }
    }
}
my $branches = GetBranches;
my @branchloop;
foreach my $thisbranch (keys %$branches) {
    my $selected = 1 if $thisbranch eq $branch;
    my %row =(value => $thisbranch,
                selected => $selected,
                branchname => $branches->{$thisbranch}->{'branchname'},
            );
    push @branchloop, \%row;
}

my $sth=$dbh->prepare("SELECT description,categorycode FROM categories ORDER BY description");
$sth->execute;
my @trow3;
my @title_loop;
while (my $data=$sth->fetchrow_hashref){
    my %row = (in_title => $data->{'description'});
    push @title_loop,\%row;
    push @trow3,$data->{'categorycode'};
}

my %row = (in_title => "*");
push @title_loop, \%row;
push @trow3,'*';

$sth->finish;
$sth=$dbh->prepare("Select description,itemtype from itemtypes order by description");
$sth->execute;
my $toggle= 1;
my @row_loop;
my @itemtypes;
while (my $row=$sth->fetchrow_hashref){
    push @itemtypes,\$row;
}
my $line;
$line->{itemtype} = "*";
$line->{description} = "*";
push @itemtypes,\$line;

foreach my $data (@itemtypes) {
    my @trow2;
    my @cell_loop;
    if ( $toggle eq 1 ) {
            $toggle = 0;
    } else {
            $toggle = 1;
    }
    for (my $i=0;$i<=$#trow3;$i++){
        my $sth2=$dbh->prepare("SELECT * FROM issuingrules WHERE branchcode=? AND categorycode=? AND itemtype=?");
        $sth2->execute($branch,$trow3[$i],$$data->{'itemtype'});
        my $dat=$sth2->fetchrow_hashref;
        $sth2->finish;
        my $fine=$dat->{'fine'};
        my $maxissueqty = $dat->{'maxissueqty'};
        my $issuelength = $dat->{'issuelength'};
        my $issuingvalue;
        $issuingvalue = "$issuelength,$maxissueqty" if $maxissueqty ne '';
        my $issuingname = join("-", "I", map { str_to_base64($_) } ($branch, $trow3[$i], $$data->{itemtype}) );
        my %row = (issuingname => $issuingname,
                    issuingvalue => $issuingvalue,
                    toggle => $toggle,
                    );
        push @cell_loop,\%row;
    }
    my %row = (categorycode => $$data->{description},
                total => ($$data->{itemtype} eq '*'?1:0),
                cell =>\@cell_loop
            );
    push @row_loop, \%row;
}

$sth->finish;
$template->param(title => \@title_loop,
                row => \@row_loop,
                branchloop => \@branchloop,
                branch => $branch,
                );
output_html_with_http_headers $input, $cookie, $template->output;
