#!/usr/bin/perl

# Finlay working on this file from 26-03-2002
# Reorganising this branches admin page.....


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

# Fixed variables
my $linecolor1='#ffffcc';
my $linecolor2='white';
my $backgroundimage="/images/background-mem.gif";
my $script_name="/cgi-bin/koha/admin/branches.pl";
my $pagesize=20;


#######################################################################################
# Main loop....

my $input = new CGI;
my $branchcode=$input->param('branchcode');
my $op = $input->param('op');

# header
print $input->header;

# start the page and read in includes
print startpage();
print startmenu('admin');

if ($op eq 'add') {
# If the user has pressed the "add new branch" button.
    print heading("Branches: Add Branch");
    print editbranchform();

} elsif ($op eq 'edit') {
# if the user has pressed the "edit branch settings" button.
    print heading("Branches: Edit Branch");
    print editbranchform($branchcode);

} elsif ($op eq 'add_validate') {
# confirm settings change...
    my $params = $input->Vars;
    unless ($params->{'branchcode'} && $params->{'branchname'}) {
	default ("Cannot change branch record: You must specify a Branchname and a Branchcode");
    } else {
	setbranchinfo($params);
	default ("Branch record changed for branch: $params->{'branchname'}");
    }

} elsif ($op eq 'delete') {
# if the user has pressed the "delete branch" button.
    my $message = checkdatabasefor($branchcode);
    if ($message) {
	default($message);
    } else {
	print deleteconfirm($branchcode);
    }

} elsif ($op eq 'delete_confirmed') {
# actually delete branch and return to the main screen....
    deletebranch($branchcode);
    default("The branch with code $branchcode has been deleted.");

} else {
# if no operation has been set...
    default();
}


print endmenu('admin');
print endpage();

######################################################################################################
#
# html output functions....

sub default {
    my ($message) = @_;
    print heading("Branches");
    print "<font color='red'>$message</font>";
    print "<form action='$script_name' method=post><input type='hidden' name='op' value='add'><input type=submit value='Add New Branch'></form>";
    print branchinfotable();
    print branchcategoriestable();
}

sub heading {
    my ($head) = @_;
    return "<FONT SIZE=6><em>$head</em></FONT><br>";
}

sub editbranchform {
# prepares the edit form...
    my ($branchcode) = @_;
    my $data;
    if ($branchcode) {
	$data = getbranchinfo($branchcode);
	$data = $data->[0];
    }
# make the checkboxs.....
    my $catinfo = getcategoryinfo();
    my $catcheckbox;
    foreach my $cat (@$catinfo) {
	my $checked = "";
	my $tmp = $cat->{'categorycode'};
	if (grep {/^$tmp$/} @{$data->{'categories'}}) {
	    $checked = "CHECKED";
	}
	$catcheckbox .= <<EOF;
<tr><td>$cat->{'categoryname'}</td>
<td><INPUT TYPE="checkbox" NAME="$cat->{'categorycode'}" VALUE="1" $checked>$cat->{'codedescription'}</td></tr>
EOF
    }
    my $form = <<EOF;
<form action='$script_name' name=Aform method=post>
<input type=hidden name=op value='add_validate'>
<table>
<tr><td>Branch code</td><td><input type=text name=branchcode size=5 maxlength=5 value='$data->{'branchcode'}'></td></tr>
<tr><td>Name</td><td><input type=text name=branchname size=40 maxlength=80 value='$data->{'branchname'}'>&nbsp;</td></tr>
$catcheckbox
<tr><td>Address</td><td><input type=text name=branchaddress1 value='$data->{'branchaddress1'}'></td></tr>
<tr><td>&nbsp;</td><td><input type=text name=branchaddress2 value='$data->{'branchaddress2'}'></td></tr>
<tr><td>&nbsp;</td><td><input type=text name=branchaddress3 value='$data->{'branchaddress3'}'></td></tr>
<tr><td>Phone</td><td><input type=text name=branchphone value='$data->{'branchphone'}'></td></tr>
<tr><td>Fax</td><td><input type=text name=branchfax value='$data->{'branchfax'}'></td></tr>
<tr><td>E-mail</td><td><input type=text name=branchemail value='$data->{'branchemail'}'></td></tr>
<tr><td>&nbsp;</td><td><input type=submit value='Submit'></td></tr>
</table>
</form>
EOF
    return $form;
}

sub deleteconfirm {
# message to print if the
    my ($branchcode) = @_;
    my $output = <<EOF;
Confirm delete:
<form action='$script_name' method=post><input type='hidden' name='op' value='delete_confirmed'>
<input type='hidden' name='branchcode' value=$branchcode>
<input type=submit value=YES></form>
<form action='$script_name' method=post><input type='hidden' name='op' value=''>
<input type=submit value=NO></form>
EOF
    return $output;
}


sub branchinfotable {
# makes the html for a table of branch info from reference to an array of hashs.

    my ($branchcode) = @_;
    my $branchinfo;
    if ($branchcode) {
	$branchinfo = getbranchinfo($branchcode);
    } else {
	$branchinfo = getbranchinfo();
    }
    my $table = <<EOF;
<table border='1' cellpadding='5' cellspacing='0' width='550'>
<tr> <th colspan='5' align='left' bgcolor='#99cc33' background=$backgroundimage>
<font size='5'><b>Branches</b></font></th> </tr>
<tr bgcolor='#889999'>
<td width='175'><b>Name</b></td>
<td width='25'><b>Code</b></td>
<td width='175'><b>Address</b></td>
<td width='175'><b>Categories</b></td>
<td width='50'><b>&nbsp;</b></td>
</tr>
EOF

    my $color;
    foreach my $branch (@$branchinfo) {
	($color eq $linecolor1) ? ($color=$linecolor2) : ($color=$linecolor1);
	my $address = '';
	$address .= $branch->{'branchaddress1'}          if ($branch->{'branchaddress1'});
	$address .= '<br>'.$branch->{'branchaddress2'}   if ($branch->{'branchaddress2'});
	$address .= '<br>'.$branch->{'branchaddress3'}   if ($branch->{'branchaddress3'});
	$address .= '<br>ph: '.$branch->{'branchphone'}   if ($branch->{'branchphone'});
	$address .= '<br>fax: '.$branch->{'branchfax'}    if ($branch->{'branchfax'});
	$address .= '<br>email: '.$branch->{'branchemail'} if ($branch->{'branchemail'});
	$address = '(nothing entered)' unless ($address);
	my $categories = '';
	foreach my $cat (@{$branch->{'categories'}}) {
	    my ($catinfo) = @{getcategoryinfo($cat)};
	    $categories .= $catinfo->{'categoryname'}."<br>";
	}
	$categories = '(no categories set)' unless ($categories);
	$table .= <<EOF;
<tr bgcolor='$color'>
    <td align='left' valign='top'>$branch->{'branchname'}</td>
    <td align='left' valign='top'>$branch->{'branchcode'}</td>
    <td align='left' valign='top'>$address</td>
    <td align='left' valign='top'>$categories</td>
    <td align='left' valign='top'>
<form action='$script_name' method=post>
<input type='hidden' name='op' value='edit'>
<input type='hidden' name='branchcode' value='$branch->{'branchcode'}'>
<input type=submit value=Edit>
</form>
<form action='$script_name' method=post>
<input type='hidden' name='branchcode' value='$branch->{'branchcode'}'>
<input type='hidden' name='op' value='delete'><input type=submit value=Delete>
</form></td>
</tr>
EOF
    }
    $table .= "</table><br>";
    return $table;
}

sub branchcategoriestable {
#Needs to be implemented...

    my $categoryinfo = getcategoryinfo();
    my $table = <<EOF;
<table border='1' cellpadding='5' cellspacing='0'>
<tr> <th colspan='5' align='left' bgcolor='#99cc33' background=$backgroundimage>
<font size='5'><b>Branches Categories</b></font></th> </tr>
<tr bgcolor='#889999'>
<td width='175'><b>Name</b></td>
<td width='25'><b>Code</b></td>
<td width='200'><b>Description</b></td>
</tr>
EOF
my $color;
    foreach my $cat (@$categoryinfo) {
	($color eq $linecolor1) ? ($color=$linecolor2) : ($color=$linecolor1);
	$table .= <<EOF;
<tr bgcolor='$color'>
    <td align='left' valign='top'>$cat->{'categoryname'}</td>
    <td align='left' valign='top'>$cat->{'categorycode'}</td>
    <td align='left' valign='top'>$cat->{'codedescription'}</td>
</tr>
EOF
    }
    $table .= "</table>";
    return $table;
}

######################################################################################################
#
# Database functions....

sub getbranchinfo {
# returns a reference to an array of hashes containing branches,

    my ($branchcode) = @_;
    my $dbh = C4::Context->dbh;
    my $query;
    if ($branchcode) {
	my $bc = $dbh->quote($branchcode);
	$query = "Select * from branches where branchcode = $bc";
    }
    else {$query = "Select * from branches";}
    my $sth = $dbh->prepare($query);
    $sth->execute;
    my @results;
    while (my $data = $sth->fetchrow_hashref) {
	my $tmp = $data->{'branchcode'}; my $brc = $dbh->quote($tmp);
	$query = "select categorycode from branchrelations where branchcode = $brc";
	my $nsth = $dbh->prepare($query);
	$nsth->execute;
	my @cats = ();
	while (my ($cat) = $nsth->fetchrow_array) {
	    push(@cats, $cat);
	}
	$nsth->finish;
	$data->{'categories'} = \@cats;
	push(@results, $data);
    }
    $sth->finish;
    return \@results;
}

sub getcategoryinfo {
# returns a reference to an array of hashes containing branches,
    my ($catcode) = @_;
    my $dbh = C4::Context->dbh;
    my $query;
    if ($catcode) {
	my $cc = $dbh->quote($catcode);
	$query = "select * from branchcategories where categorycode = $cc";
    } else {
	$query = "Select * from branchcategories";
    }
    my $sth = $dbh->prepare($query);
    $sth->execute;
    my @results;
    while (my $data = $sth->fetchrow_hashref) {
	push(@results, $data);
    }
    $sth->finish;
    return \@results;
}

sub setbranchinfo {
# sets the data from the editbranch form, and writes to the database...
    my ($data) = @_;
    my $dbh = C4::Context->dbh;
    my $query = "replace branches (branchcode,branchname,branchaddress1,branchaddress2,branchaddress3,branchphone,branchfax,branchemail) values (";
    my $tmp;
    $tmp = $data->{'branchcode'}; $query.= $dbh->quote($tmp).",";
    $tmp = $data->{'branchname'}; $query.= $dbh->quote($tmp).",";
    $tmp = $data->{'branchaddress1'}; $query.= $dbh->quote($tmp).",";
    $tmp = $data->{'branchaddress2'}; $query.= $dbh->quote($tmp).",";
    $tmp = $data->{'branchaddress3'}; $query.= $dbh->quote($tmp).",";
    $tmp = $data->{'branchphone'}; $query.= $dbh->quote($tmp).",";
    $tmp = $data->{'branchfax'}; $query.= $dbh->quote($tmp).",";
    $tmp = $data->{'branchemail'}; $query.= $dbh->quote($tmp).")";
    my $sth=$dbh->prepare($query);
    $sth->execute;
    $sth->finish;
# sort out the categories....
    my @checkedcats;
    my $cats = getcategoryinfo();
    foreach my $cat (@$cats) {
	my $code = $cat->{'categorycode'};
	if ($data->{$code}) {
	    push(@checkedcats, $code);
	}
    }
    my $branchcode = $data->{'branchcode'};
    my $branch = getbranchinfo($branchcode);
    $branch = $branch->[0];
    my $branchcats = $branch->{'categories'};
    my @addcats;
    my @removecats;
    foreach my $bcat (@$branchcats) {
	unless (grep {/^$bcat$/} @checkedcats) {
	    push(@removecats, $bcat);
	}
    }
    foreach my $ccat (@checkedcats){
	unless (grep {/^$ccat$/} @$branchcats) {
	    push(@addcats, $ccat);
	}
    }
    # FIXME - There's already a $dbh in this scope.
    my $dbh = C4::Context->dbh;
    foreach my $cat (@addcats) {
	my $query = "insert into branchrelations (branchcode, categorycode) values('$branchcode', '$cat')";
	my $sth = $dbh->prepare($query);
	$sth->execute;
	$sth->finish;
    }
    foreach my $cat (@removecats) {
	my $query = "delete from branchrelations where branchcode='$branchcode' and categorycode='$cat'";
	my $sth = $dbh->prepare($query);
	$sth->execute;
	$sth->finish;
    }
}

sub deletebranch {
# delete branch...
    my ($branchcode) = @_;
    my $query = "delete from branches where branchcode = '$branchcode'";
    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare($query);
    $sth->execute;
    $sth->finish;
}

sub checkdatabasefor {
# check to see if the branchcode is being used in the database somewhere....
    my ($branchcode) = @_;
    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare("select count(*) from items where holdingbranch='$branchcode' or homebranch='$branchcode'");
    $sth->execute;
    my ($total) = $sth->fetchrow_array;
    $sth->finish;
    my $message;
    if ($total) {
	$message = "Branch cannot be deleted because there are $total items using that branch.";
    }
    return $message;
}


