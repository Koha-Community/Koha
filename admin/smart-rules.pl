#!/usr/bin/perl
# vim: et ts=4 sw=4
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
use C4::Debug;
use C4::Branch; # GetBranches

my $input = new CGI;
my $dbh = C4::Context->dbh;

my $type=$input->param('type');
my $branch = $input->param('branch') || '*';
my $op = $input->param('op');

# my $flagsrequired;
# $flagsrequired->{circulation}=1;
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "admin/smart-rules.tmpl",
                            query => $input,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => {parameters => 1},
                            debug => 1,
                            });

if ($op =~ /delete-(.+)-(.+)/) {
    my $itemtype = $1;
    my $categorycode = $2;
    $debug and warn "deleting $1 $2 $branch";

    my $sth_Idelete = $dbh->prepare("delete from issuingrules where branchcode=? and categorycode=? and itemtype=?");
    $sth_Idelete->execute($branch, $categorycode, $itemtype);
}
# save the values entered
elsif ($op eq 'add') {
    my $sth_search = $dbh->prepare("SELECT COUNT(*) AS total FROM issuingrules WHERE branchcode=? AND categorycode=? AND itemtype=?");
    my $sth_insert = $dbh->prepare("INSERT INTO issuingrules (branchcode, categorycode, itemtype, maxissueqty, issuelength, fine, firstremind, chargeperiod) VALUES(?,?,?,?,?,?,?,?)");
    my $sth_update=$dbh->prepare("UPDATE issuingrules SET fine=?, firstremind=?, chargeperiod=?, maxissueqty=?, issuelength=? WHERE branchcode=? AND categorycode=? AND itemtype=?");
    
    my $br = $branch; # branch
    my $bor  = $input->param('categorycode'); # borrower category
    my $cat  = $input->param('itemtype');     # item type
    my $fine = $input->param('fine');
    my $firstremind  = $input->param('firstremind');
    my $chargeperiod = $input->param('chargeperiod');
    my $maxissueqty  = $input->param('maxissueqty');
    my $issuelength  = $input->param('issuelength');
    $debug and warn "Adding $br, $bor, $cat, $fine, $maxissueqty";

    $sth_search->execute($br,$bor,$cat);
    my $res = $sth_search->fetchrow_hashref();
    if ($res->{total}) {
        $sth_update->execute($fine, $firstremind, $chargeperiod, $maxissueqty,$issuelength,$br,$bor,$cat);
    } else {
        $sth_insert->execute($br,$bor,$cat,$maxissueqty,$issuelength,$fine,$firstremind,$chargeperiod);
    }
}
my $branches = GetBranches();
my @branchloop;
for my $thisbranch (sort { $branches->{$a}->{branchname} cmp $branches->{$b}->{branchname} } keys %$branches) {
    my $selected = 1 if $thisbranch eq $branch;
    my %row =(value => $thisbranch,
                selected => $selected,
                branchname => $branches->{$thisbranch}->{'branchname'},
            );
    push @branchloop, \%row;
}

my $sth=$dbh->prepare("SELECT description,categorycode FROM categories ORDER BY description");
$sth->execute;
my @category_loop;
while (my $data=$sth->fetchrow_hashref){
    push @category_loop,$data;
}

my %row = (categorycode => "*", description => 'Any');
push @category_loop, \%row;

$sth->finish;
$sth=$dbh->prepare("SELECT description,itemtype FROM itemtypes ORDER BY description");
$sth->execute;
# $i=0;
my $toggle= 1;
my @row_loop;
my @itemtypes;
while (my $row=$sth->fetchrow_hashref){
    push @itemtypes,$row;
}
my %row = (itemtype => '*', description => 'Any');
push @itemtypes,\%row;

my $sth2 = $dbh->prepare("
    SELECT issuingrules.*, itemtypes.description AS humanitemtype, categories.description AS humancategorycode
    FROM issuingrules
    LEFT JOIN itemtypes
        ON (itemtypes.itemtype = issuingrules.itemtype)
    LEFT JOIN categories
        ON (categories.categorycode = issuingrules.categorycode)
    WHERE issuingrules.branchcode = ?
");
$sth2->execute($branch);

while (my $row = $sth2->fetchrow_hashref) {
    $row->{'humanitemtype'} ||= $row->{'itemtype'};
    $row->{'humanitemtype'} = 'Any' if $row->{'humanitemtype'} eq '*';
    $row->{'humancategorycode'} ||= $row->{'categorycode'};
    $row->{'humancategorycode'} = 'Any' if $row->{'humancategorycode'} eq '*';
    $row->{'fine'} = sprintf('%.2f', $row->{'fine'});
    push @row_loop, $row;
}
$sth->finish;
$template->param(categoryloop => \@category_loop,
                        itemtypeloop => \@itemtypes,
                        rules => \@row_loop,
                        branchloop => \@branchloop,
                        humanbranch => ($branch ne '*' ? $branches->{$branch}->{branchname} : ''),
                        branch => $branch
                        );
output_html_with_http_headers $input, $cookie, $template->output;
