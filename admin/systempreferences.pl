#!/usr/bin/perl

#script to administer the systempref table
#written 20/02/2002 by paul.poulain@free.fr
# This software is placed under the gnu General Public License, v2 (http://www.gnu.org/licenses/gpl.html)

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

use strict;
use C4::Output;
use CGI;
use C4::Search;
use C4::Database;

sub StringSearch  {
	my ($env,$searchstring,$type)=@_;
	my $dbh = &C4Connect;
	$searchstring=~ s/\'/\\\'/g;
	my @data=split(' ',$searchstring);
	my $count=@data;
	my $query="Select variable,value from systempreferences where (variable like \"$data[0]%\") order by variable";
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
	$dbh->disconnect;
	return ($cnt,\@results);
}

my $input = new CGI;
my $searchfield=$input->param('searchfield');
my $pkfield="variable";
my $reqsel="select variable,value from systempreferences where $pkfield='$searchfield'";
my $reqdel="delete from systempreferences where $pkfield='$searchfield'";
my $offset=$input->param('offset');
my $script_name="/cgi-bin/koha/admin/systempreferences.pl";

my $pagesize=20;
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
	if ($searchfield) {
		my $dbh = &C4Connect;
		my $sth=$dbh->prepare("select variable,value from systempreferences where variable='$searchfield'");
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
		if (f.variable.value.length==0) {
			_alertString += "- variable missing\\n";
		}
		if (f.value.value.length==0) {
			_alertString += "- value missing\\n";
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
	if ($searchfield) {
		print "<h1>Modify pref</h1>";
	} else {
		print "<h1>Add pref</h1>";
	}
	print "<form action='$script_name' name=Aform method=post>";
	print "<input type=hidden name=op value='add_validate'>";
	print "<table>";
	if ($searchfield) {
		print "<tr><td>Variable</td><td><input type=hidden name=variable value='$searchfield'>$searchfield</td></tr>";
	} else {
		print "<tr><td>Variable</td><td><input type=text name=variable size=255 maxlength=255></td></tr>";
	}
	print "<tr><td>Value</td><td><input type=text name=value value='$data->{'value'}'></td></tr>";
	print "<tr><td>&nbsp;</td><td><INPUT type=button value='OK' onClick='Check(this.form)'></td></tr>";
	print "</table>";
	print "</form>";
;
													# END $OP eq ADD_FORM
################## ADD_VALIDATE ##################################
# called by add_form, used to insert/modify data in DB
} elsif ($op eq 'add_validate') {
	my $dbh=C4Connect;
	my $query = "replace systempreferences (variable,value) values (";
	$query.= $dbh->quote($input->param('variable')).",";
	$query.= $dbh->quote($input->param('value')).")";
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
	my $dbh = &C4Connect;
	my $sth=$dbh->prepare($reqsel);
	$sth->execute;
	my $data=$sth->fetchrow_hashref;
	$sth->finish;
	print mktablehdr;
	print mktablerow(2,'#99cc33',bold('Variable'),bold("$searchfield"),'/images/background-mem.gif');
	print "<tr><td>Value</td><td>$data->{'value'}</td></tr>";
	print "<form action='$script_name' method=post><input type=hidden name=op value=delete_confirmed><input type=hidden name=searchfield value='$searchfield'>";
	print "<tr><td colspan=2 align=center>CONFIRM DELETION</td></tr>";
	print "<tr><td><INPUT type=submit value='YES'></form></td><td><form action='$script_name' method=post><input type=submit value=NO></form></td></tr>";
													# END $OP eq DELETE_CONFIRM
################## DELETE_CONFIRMED ##################################
# called by delete_confirm, used to effectively confirm deletion of data in DB
} elsif ($op eq 'delete_confirmed') {
	my $dbh=C4Connect;
#	my $searchfield=$input->param('branchcode');
	my $sth=$dbh->prepare($reqdel);
	$sth->execute;
	$sth->finish;
	print "data deleted";
	print "<form action='$script_name' method=post>";
	print "<input type=submit value=OK>";
	print "</form>";
													# END $OP eq DELETE_CONFIRMED
################## DEFAULT ##################################
} else { # DEFAULT
	my @inputs=(["text","searchfield",$searchfield],
		["reset","reset","clr"]);
	print mkheadr(2,'System preferences admin');
	print mkformnotable("$script_name",@inputs);
	print <<printend
<b>Hints :</b>
6 variables are useful in this table :
<li><i>acquisitions</i>, which value may be "simple" or "normal"</li>
<li><i>autoMemberNum</i> which may be 1 or 0</li>
<li><i>dateformat</i> which may be "US" for mm/dd/yy format, or "metric" for dd/mm/yy format.
<li><i>printcirculationslips</i> which may be 1 or 0</li> 
<li><i>printreserveslips</i> which may be 1 or 0</li> 
<li><i>KohaAdminEmailAddress</i> - currently used for patron's to request changes to their information.
<br><br>
printend
	;
	if  ($searchfield ne '') {
		print "You Searched for <b>$searchfield<b><p>";
	}
	print mktablehdr;
	print mktablerow(4,'#99cc33',bold('Variable'),bold('Value'),
	'&nbsp;','&nbsp;','/images/background-mem.gif');
	my $env;
	my ($count,$results)=StringSearch($env,$searchfield,'web');
	my $toggle="white";
	for (my $i=$offset; $i < ($offset+$pagesize<$count?$offset+$pagesize:$count); $i++){
	  	if ($toggle eq 'white'){
	    		$toggle="#ffffcc";
	  	} else {
	    		$toggle="white";
	  	}
		print mktablerow(4,$toggle,$results->[$i]{'variable'},$results->[$i]{'value'},
		mklink("$script_name?op=add_form&searchfield=".$results->[$i]{'variable'},'Edit'),
		mklink("$script_name?op=delete_confirm&searchfield=".$results->[$i]{'variable'},'Delete'));
	}
	print mktableft;
	print "<form action='$script_name' method=post>";
	print "<input type=hidden name=op value=add_form>";
	if ($offset>0) {
		my $prevpage = $offset-$pagesize;
		print mklink("$script_name?offset=".$prevpage,'&lt;&lt; Prev');
	}
	print "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
	if ($offset+$pagesize<$count) {
		my $nextpage =$offset+$pagesize;
		print mklink("$script_name?offset=".$nextpage,'Next &gt;&gt;');
	}
	print "<br><input type=image src=\"/images/button-add-new.gif\"  WIDTH=188  HEIGHT=44  ALT=\"Add parameter\" BORDER=0 ></a><br>";
	print "</form>";
} #---- END $OP eq DEFAULT
print endmenu('admin');
print endpage();
