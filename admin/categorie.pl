#!/usr/bin/perl

#script to administer the categories table
#written 20/02/2002 by paul.poulain@free.fr

# ALGO :
# this script use an $op to know what to do.
# if $op is empty or none of the above values,
#	- the default screen is build (with all records, or filtered datas).
#	- the   user can clic on add, modify or delete record.
# if $op=add_form
#	- if primkey exists, this is a modification,so we read the $primkey record
#	- builds the add/modify form
# if $op=add_validate
#	- the user has just send datas, so we create/modify the record
# if $op=delete_form
#	- we show the record having primkey=$primkey and ask for deletion validation form
# if $op=delete_confirm
#	- we delete the record having primkey=$primkey


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
use C4::Search;

sub StringSearch  {
	my ($env,$searchstring,$type)=@_;
	my $dbh = C4::Context->dbh;
	$searchstring=~ s/\'/\\\'/g;
	my @data=split(' ',$searchstring);
	my $count=@data;
	my $query="Select * from categories where (description like \"$data[0]%\")";
	my $sth=$dbh->prepare($query);
	$sth->execute;
	my @results;
	my $cnt=0;
	while (my $data=$sth->fetchrow_hashref){
	push(@results,$data);
	$cnt ++;
	}
	#  $sth->execute;
	$sth->finish;
	return ($cnt,\@results);
}

my $input = new CGI;
my $searchfield=$input->param('description');
my $script_name="/cgi-bin/koha/admin/categorie.pl";
my $categorycode=$input->param('categorycode');
my $op = $input->param('op');
$searchfield=~ s/\,//g;
print $input->header;
#start the page and read in includes
print startpage();
print startmenu('admin');

################## ADD_FORM ##################################
# called by default. Used to create form to add or  modify a record
if ($op eq 'add_form') {
	#---- if primkey exists, it's a modify action, so read values to modify...
	my $data;
	if ($categorycode) {
		my $dbh = C4::Context->dbh;
		my $sth=$dbh->prepare("select categorycode,description,enrolmentperiod,upperagelimit,dateofbirthrequired,finetype,bulk,enrolmentfee,issuelimit,reservefee,overduenoticerequired from categories where categorycode='$categorycode'");
		$sth->execute;
		$data=$sth->fetchrow_hashref;
		$sth->finish;
	}
	print <<printend
	<script>
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	function isNotNull(f,noalert) {
		if (f.value.length ==0) {
   return false;
		}
		return true;
	}
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	function toUC(f) {
		var x=f.value.toUpperCase();
		f.value=x;
		return true;
	}
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	function isNum(v,maybenull) {
	var n = new Number(v.value);
	if (isNaN(n)) {
		return false;
		}
	if (maybenull==0 && v.value=='') {
		return false;
	}
	return true;
	}
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	function isDate(f) {
		var t = Date.parse(f.value);
		if (isNaN(t)) {
			return false;
		}
	}
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	function Check(f) {
		var ok=1;
		var _alertString="";
		var alertString2;
		if (f.categorycode.value.length==0) {
			_alertString += "- categorycode missing\\n";
		}
//		alert(window.document.Aform.description.value);
		if (!(isNotNull(window.document.Aform.description,1))) {
			_alertString += "- description missing\\n";
		}
		if (!isNum(f.upperagelimit,0)) {
			_alertString += "- upperagelimit is not a number\\n";
		}
		if (_alertString.length==0) {
			document.Aform.submit();
		} else {
			alertString2 = "Form not submitted because of the following problem(s)\\n";
			alertString2 += "------------------------------------------------------------------------------------\\n\\n";
			alertString2 += _alertString;
			alert(alertString2);
		}
	}
	</SCRIPT>
printend
;#/
	if ($categorycode) {
		print "<h1>Modify category</h1>";
	} else {
		print "<h1>Add category</h1>";
	}
	print "<form action='$script_name' name=Aform method=post>";
	print "<input type=hidden name=op value='add_validate'>";
	print "<input type=hidden name=checked value=0>";
	print "<table>";
	if ($categorycode) {
		print "<tr><td>Category code</td><td><input type=hidden name=categorycode value=$categorycode>$categorycode</td></tr>";
	} else {
		print "<tr><td>Category code</td><td><input type=text name=categorycode size=3 maxlength=2 onBlur=toUC(this)></td></tr>";
	}
	print "<tr><td>Description</td><td><input type=text name=description size=40 maxlength=80 value='$data->{'description'}'>&nbsp;</td></tr>";
	print "<tr><td>Enrolment period</td><td><input type=text name=enrolmentperiod value='$data->{'enrolmentperiod'}'></td></tr>";
	print "<tr><td>Upperage limit</td><td><input type=text name=upperagelimit value='$data->{'upperagelimit'}'></td></tr>";
	print "<tr><td>Age Required</td><td><input type=text name=dateofbirthrequired value='$data->{'dateofbirthrequired'}'></td></tr>";
	print "<tr><td>Fine type</td><td><input type=text name=finetype size=30 maxlength=30 value='$data->{'finetype'}'></td></tr>";
	print "<tr><td>Bulk</td><td><input type=text name=bulk value='$data->{'bulk'}'></td></tr>";
	print "<tr><td>Enrolment fee</td><td><input type=text name=enrolmentfee value='$data->{'enrolmentfee'}'></td></tr>";
	print "<tr><td>Overdue notice required</td><td><input type=text name=overduenoticerequired value='$data->{'overduenoticerequired'}'></td></tr>";
	print "<tr><td>Issue limit</td><td><input type=text name=issuelimit value='$data->{'issuelimit'}'></td></tr>";
	print "<tr><td>Reserve fee</td><td><input type=text name=reservefee value='$data->{'reservefee'}'></td></tr>";
	print "<tr><td>&nbsp;</td><td><INPUT type=button value='OK' onClick='Check(this.form)'></td></tr>";
print "</table>";
	print "</form>";
;
													# END $OP eq ADD_FORM
################## ADD_VALIDATE ##################################
# called by add_form, used to insert/modify data in DB
} elsif ($op eq 'add_validate') {
	my $dbh = C4::Context->dbh;
	my $query = "replace categories (categorycode,description,enrolmentperiod,upperagelimit,dateofbirthrequired,finetype,bulk,enrolmentfee,issuelimit,reservefee,overduenoticerequired) values (";
	$query.= $dbh->quote($input->param('categorycode')).",";
	$query.= $dbh->quote($input->param('description')).",";
	$query.= $dbh->quote($input->param('enrolmentperiod')).",";
	$query.= $dbh->quote($input->param('upperagelimit')).",";
	$query.= $dbh->quote($input->param('dateofbirthrequired')).",";
	$query.= $dbh->quote($input->param('finetype')).",";
	$query.= $dbh->quote($input->param('bulk')).",";
	$query.= $dbh->quote($input->param('enrolmentfee')).",";
	$query.= $dbh->quote($input->param('issuelimit')).",";
	$query.= $dbh->quote($input->param('reservefee')).",";
	$query.= $dbh->quote($input->param('overduenoticerequired')).")";
	my $sth=$dbh->prepare($query);
	$sth->execute;
	$sth->finish;
	print "data recorded";
	print "<form action='$script_name' method=post>";
	print "<input type=submit value=OK>";
	print "</form>";
													# END $OP eq ADD_VALIDATE
################## DELETE_CONFIRM ##################################
# called by default form, used to confirm deletion of data in DB
} elsif ($op eq 'delete_confirm') {
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("select count(*) as total from categoryitem where categorycode='$categorycode'");
	$sth->execute;
	my $total = $sth->fetchrow_hashref;
	print "TOTAL : $categorycode : $total->{'total'}<br>";
	$sth->finish;
	# FIXME - there's already a $sth in this scope.
	my $sth=$dbh->prepare("select categorycode,description,enrolmentperiod,upperagelimit,dateofbirthrequired,finetype,bulk,enrolmentfee,issuelimit,reservefee,overduenoticerequired from categories where categorycode='$categorycode'");
	$sth->execute;
	my $data=$sth->fetchrow_hashref;
	$sth->finish;
	print mktablehdr;
	print mktablerow(2,'#99cc33',bold('Category code'),bold("$categorycode"),'/images/background-mem.gif');
	print "<form action='$script_name' method=post><input type=hidden name=op value=delete_confirmed><input type=hidden name=categorycode value='$categorycode'>";
	print "<tr><td>Description</td><td>$data->{'description'}</td></tr>";
	print "<tr><td>Enrolment period</td><td>$data->{'enrolmentperiod'}</td></tr>";
	print "<tr><td>Upperage limit</td><td>$data->{'upperagelimit'}</td></tr>";
	print "<tr><td>Age Required</td><td>$data->{'dateofbirthrequired'}</td></tr>";
	print "<tr><td>Fine type</td><td>$data->{'finetype'}</td></tr>";
	print "<tr><td>Bulk</td><td>$data->{'bulk'}</td></tr>";
	print "<tr><td>Enrolment fee</td><td>$data->{'enrolmentfee'}</td></tr>";
	print "<tr><td>Overdue notice required</td><td>$data->{'overduenoticerequired'}</td></tr>";
	print "<tr><td>Issue limit</td><td>$data->{'issuelimit'}</td></tr>";
	print "<tr><td>Reserve fee</td><td>$data->{'reservefee'}</td></tr>";
	if ($total->{'total'} >0) {
		print "<tr><td colspan=2 align=center><b>This record is used $total->{'total'} times. Deletion not possible</b></td></tr>";
		print "<tr><td colspan=2></form><form action='$script_name' method=post><input type=submit value=OK></form></td></tr>";
	} else {
		print "<tr><td colspan=2 align=center>CONFIRM DELETION</td></tr>";
		print "<tr><td><INPUT type=submit value='YES'></form></td><td><form action='$script_name' method=post><input type=submit value=NO></form></td></tr>";
	}
													# END $OP eq DELETE_CONFIRM
################## DELETE_CONFIRMED ##################################
# called by delete_confirm, used to effectively confirm deletion of data in DB
} elsif ($op eq 'delete_confirmed') {
	my $dbh = C4::Context->dbh;
	my $categorycode=uc($input->param('categorycode'));
	my $query = "delete from categories where categorycode='$categorycode'";
	my $sth=$dbh->prepare($query);
	$sth->execute;
	$sth->finish;
	print "data deleted";
	print "<form action='$script_name' method=post>";
	print "<input type=submit value=OK>";
	print "</form>";
													# END $OP eq DELETE_CONFIRMED
} else { # DEFAULT
	my @inputs=(["text","description",$searchfield],
		["reset","reset","clr"]);
	print mkheadr(2,'Category admin');
	print mkformnotable("$script_name",@inputs);
	print <<printend

printend
	;
	if  ($searchfield ne '') {
		print "You Searched for $searchfield<p>";
	}
	print mktablehdr;
	print mktablerow(13,'#99cc33',bold('Category'),bold('Description'),bold('Enrolment'),bold('age max')
	,bold('birth needed'),bold('Fine'),bold('Bulk'),bold('fee'),bold('overdue'),bold('Issue limit'),bold('Reserve'),'&nbsp;','&nbsp;','/images/background-mem.gif');
	my $env;
	my ($count,$results)=StringSearch($env,$searchfield,'web');
	my $toggle="white";
	for (my $i=0; $i < $count; $i++){
		#find out stats
	#  	my ($od,$issue,$fines)=categdata2($env,$results->[$i]{'borrowernumber'});
	#  	$fines=$fines+0;
	  	if ($toggle eq 'white'){
	    		$toggle="#ffffcc";
	  	} else {
	    		$toggle="white";
	  	}
		print mktablerow(13,$toggle,$results->[$i]{'categorycode'},
		$results->[$i]{'description'},$results->[$i]{'enrolmentperiod'},
		$results->[$i]{'upperagelimit'},$results->[$i]{'dateofbirthrequired'},$results->[$i]{'finetype'},
		$results->[$i]{'bulk'},$results->[$i]{'enrolmentfee'},$results->[$i]{'overduenoticerequired'},$results->[$i]{'issuelimit'},$results->[$i]{'reservefee'},mklink("$script_name?op=add_form&categorycode=".$results->[$i]{'categorycode'},'Edit'),
		mklink("$script_name?op=delete_confirm&categorycode=".$results->[$i]{'categorycode'},'Delete'));
	}
	print mktableft;
print <<printend
	<form action='$script_name' method=post>
	<input type=hidden name=op value=add_form>
	<input type=image src="/images/button-add-new.gif"  WIDTH=188  HEIGHT=44  ALT="Add Category" BORDER=0 ></a><br>
	</form>
printend
	;
} #---- END $OP eq DEFAULT
print endmenu('categorie');
print endpage();
