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
use C4::Auth;
use C4::Context;
use C4::Output;
use C4::Charset;
use HTML::Template;

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

my ($template, $borrowernumber, $cookie)
    = get_template_and_user({template_name => "parameters/branches.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {parameters => 1},
			     debug => 1,
			     });
if ($op) {
$template->param(script_name => $script_name,
						$op              => 1); # we show only the TMPL_VAR names $op
} else {
$template->param(script_name => $script_name,
						else              => 1); # we show only the TMPL_VAR names $op
}
$template->param(action => $script_name);

if ($op eq 'add') {
# If the user has pressed the "add new branch" button.
    heading("Branches: Add Branch");
    editbranchform();

} elsif ($op eq 'edit') {
# if the user has pressed the "edit branch settings" button.
    heading("Branches: Edit Branch");
    $template->param(add => 1);
    editbranchform($branchcode);

} elsif ($op eq 'add_validate') {
# confirm settings change...
    my $params = $input->Vars;
    unless ($params->{'branchcode'} && $params->{'branchname'}) {
	default ("Cannot change branch record: You must specify a Branchname and a Branchcode");
    } else {
	setbranchinfo($params);
	$template->param(else => 1);
	default ("Branch record changed for branch: $params->{'branchname'}");
    }

} elsif ($op eq 'delete') {
# if the user has pressed the "delete branch" button.
    my $message = checkdatabasefor($branchcode);
    if ($message) {
	$template->param(else => 1);
	default($message);
    } else {
	deleteconfirm($branchcode);
        $template->param(delete_confirm => 1);
	$template->param(branchcode => $branchcode);
    }

} elsif ($op eq 'delete_confirmed') {
# actually delete branch and return to the main screen....
    deletebranch($branchcode);
    $template->param(else => 1);
    default("The branch with code $branchcode has been deleted.");

} else {
# if no operation has been set...
    default();
}



######################################################################################################
#
# html output functions....

sub default {
    my ($message) = @_;
    heading("Branches");
    $template->param(message => $message);
    $template->param(action => $script_name);
    branchinfotable();
    
    
}

sub heading {
    my ($head) = @_;
    $template->param(head => $head);
}

sub editbranchform {
# prepares the edit form...
    my ($branchcode) = @_;
    my $data;
    if ($branchcode) {
	$data = getbranchinfo($branchcode);
	$data = $data->[0];
	$template->param(branchcode => $data->{'branchcode'});
        $template->param(branchname => $data->{'branchname'});
        $template->param(branchaddress1 => $data->{'branchaddress1'});
        $template->param(branchaddress2 => $data->{'branchaddress2'});
        $template->param(branchaddress3 => $data->{'branchaddress3'});
        $template->param(branchphone => $data->{'branchphone'});
        $template->param(branchfax => $data->{'branchfax'});
        $template->param(branchemail => $data->{'branchemail'});
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
    $template->param(categoryname => $cat->{'categoryname'});
    $template->param(categorycode => $cat->{'categorycode'});
    $template->param(codedescription => $checked>$cat->{'codedescription'});    
    }
   
}

sub deleteconfirm {
# message to print if the 
    my ($branchcode) = @_;
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
    my $color;
    my @loop_data =();
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
	my @colors = ();
	my @branch_name = ();
	my @branch_code = ();
	my @address = ();
	my @categories = ();
	my @value = ();
	my @action =();
	push(@colors,$color);
	push(@branch_name,$branch->{'branchname'});
	push(@branch_code,$branch->{'branchcode'});
	push(@address,$address);
	push(@categories,$categories);
	push(@value,$branch->{'branchcode'});
	push(@action,"/cgi-bin/koha/admin/branches.pl");
	while (@colors and @branch_name and @branch_code and @address and @categories and @value and @action) {
	my %row_data;
	$row_data{color} = shift @colors;
	$row_data{branch_name} = shift @branch_name;
	$row_data{branch_code} = shift @branch_code;
	$row_data{address} = shift @address;
	$row_data{categories} = shift @categories;
	$row_data{value} = shift @value;
	$row_data{action} = shift @action;
	push(@loop_data, \%row_data);
    }
    
    }
    $template->param(branches => \@loop_data);

}

sub branchcategoriestable {
#Needs to be implemented...

    my $categoryinfo = getcategoryinfo();
my $color;
    foreach my $cat (@$categoryinfo) {
	($color eq $linecolor1) ? ($color=$linecolor2) : ($color=$linecolor1);
$template->param(color => $color);
$template->param(categoryname => $cat->{'categoryname'});
$template->param(categorycode => $cat->{'categorycode'});
$template->param(codedescription => $cat->{'codedescription'});
    }
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

print $input->header(
    -type => guesstype($template->output),
    -cookie => $cookie
), $template->output;
