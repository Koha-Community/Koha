#!/usr/bin/perl

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
	my $query="Select tagfield,liblibrarian,libopac,repeatable,mandatory from marc_tag_structure where (tagfield like \"$data[0]%\") order by tagfield";
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
my $pkfield="tagfield";
my $reqsel="select tagfield,liblibrarian,libopac,repeatable,mandatory from marc_tag_structure where $pkfield='$searchfield'";
my $reqdel="delete from marc_tag_structure where $pkfield='$searchfield'";
my $offset=$input->param('offset');
my $script_name="/cgi-bin/koha/admin/marctagstructure.pl";

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
		my $sth=$dbh->prepare("select tagfield,liblibrarian,libopac,repeatable,mandatory from marc_tag_structure where $pkfield='$searchfield'");
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
		if (f.tagfield.value.length==0) {
			_alertString += "- tagfield missing\\n";
		}
		if (f.repeatable.value!=0 && f.repeatable.value!=1) {
			_alertString += "- repeatable must be 0 or 1\\n";
		}
		if (f.mandatory.value!=0 && f.mandatory.value!=1) {
			_alertString += "- mandatory must be 0 or 1\\n";
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
		print "<h1>Modify tag</h1>";
	} else {
		print "<h1>Add tag</h1>";
	}
	print "<form action='$script_name' name=Aform method=post>";
	print "<input type=hidden name=op value='add_validate'>";
	print "<table>";
	if ($searchfield) {
		print "<tr><td>Tag</td><td><input type=hidden name=tagfield value='$searchfield'>$searchfield</td></tr>";
	} else {
		print "<tr><td>Tag</td><td><input type=text name=tagfield size=5 maxlength=3></td></tr>";
	}
	print "<tr><td>Value</td><td><input type=text name=liblibrarian size=80 maxlength=255 value='$data->{'liblibrarian'}'></td></tr>";
	print "<tr><td>Value</td><td><input type=text name=libopac size=80 maxlength=255 value='$data->{'libopac'}'></td></tr>";
	print "<tr><td>Value</td><td><input type=text name=repeatable value='$data->{'repeatable'}'></td></tr>";
	print "<tr><td>Value</td><td><input type=text name=mandatory value='$data->{'mandatory'}'></td></tr>";
	print "<tr><td>&nbsp;</td><td><INPUT type=button value='OK' onClick='Check(this.form)'></td></tr>";
	print "</table>";
	print "</form>";
;
													# END $OP eq ADD_FORM
################## ADD_VALIDATE ##################################
# called by add_form, used to insert/modify data in DB
} elsif ($op eq 'add_validate') {
	my $dbh=C4Connect;
	my $query = "replace marc_tag_structure (tagfield,liblibrarian,libopac,repeatable,mandatory) values (";
	$query.= $dbh->quote($input->param('tagfield')).",";
	$query.= $dbh->quote($input->param('liblibrarian')).",";
	$query.= $dbh->quote($input->param('libopac')).",";
	$query.= $dbh->quote($input->param('repeatable')).",";
	$query.= $dbh->quote($input->param('mandatory')).")";
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
	print mktablerow(2,'#99cc33',bold('Tag'),bold("$searchfield"),'/images/background-mem.gif');
	print "<tr><td>liblibrarian</td><td>$data->{'liblibrarian'}</td></tr>";
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
printend
	;
	if  ($searchfield ne '') {
		print "You Searched for <b>$searchfield<b><p>";
	}
	print mktablehdr;
	print mktablerow(5,'#99cc33',bold('Tag'),bold('Value'),
	'&nbsp;','&nbsp;','&nbsp;','/images/background-mem.gif');
	my $env;
	my ($count,$results)=StringSearch($env,$searchfield,'web');
	my $toggle="white";
	for (my $i=$offset; $i < ($offset+$pagesize<$count?$offset+$pagesize:$count); $i++){
	  	if ($toggle eq 'white'){
	    		$toggle="#ffffcc";
	  	} else {
	    		$toggle="white";
	  	}
		print mktablerow(5,$toggle,$results->[$i]{'tagfield'},$results->[$i]{'liblibrarian'},mklink('','subfields_not_done'),
		mklink("$script_name?op=add_form&searchfield=".$results->[$i]{'tagfield'},'Edit'),
		mklink("$script_name?op=delete_confirm&searchfield=".$results->[$i]{'tagfield'},'Delete'));
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
	print "<br><input type=image src=\"/images/button-add-variable.gif\"  WIDTH=188  HEIGHT=44  ALT=\"Add budget\" BORDER=0 ></a><br>";
	print "</form>";
} #---- END $OP eq DEFAULT
print endmenu('admin');
print endpage();
