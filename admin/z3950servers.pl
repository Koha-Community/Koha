#!/usr/bin/perl

#script to administer the branches table
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
use C4::Context;

sub StringSearch  {
	my ($env,$searchstring,$type)=@_;
	my $dbh = C4::Context->dbh;
	$searchstring=~ s/\'/\\\'/g;
	my @data=split(' ',$searchstring);
	my $count=@data;
	my $query="Select host,port,db,userid,password,name,id,checked,rank from 
z3950servers where (name like \"$data[0]\%\") order by rank,name";	my 
$sth=$dbh->prepare($query);	$sth->execute;
	my @results;
	my $cnt=0;
	while (my $data=$sth->fetchrow_hashref) {
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
my $reqsel="select host,port,db,userid,password,name,id,checked,rank from 
z3950servers where (name = '$searchfield') order by rank,name";my 
$reqdel="delete from z3950servers where name='$searchfield'";my 
$offset=$input->param('offset');my 
$script_name="/cgi-bin/koha/admin/z3950servers.pl";
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
		my $dbh = C4::Context->dbh;
		my $sth=$dbh->prepare("select 
host,port,db,userid,password,name,id,checked,rank from z3950servers where (name 
= '$searchfield') order by rank,name");		$sth->execute;		
$data=$sth->fetchrow_hashref;		$sth->finish;
	}
	print <<printend
	<script>
	///////////////////////////////////////////////////////////////////////////////
//////////////////////////////////	function isNotNull(f,noalert) {
		if (f.value.length ==0) {
		    return false;
		}
		return true;
	}
	///////////////////////////////////////////////////////////////////////////////
//////////////////////////////////	function toUC(f) {
		var x=f.value.toUpperCase();
		f.value=x;
		return true;
	}
	///////////////////////////////////////////////////////////////////////////////
//////////////////////////////////	function isNum(v,maybenull) {
	var n = new Number(v.value);
	if (isNaN(n)) {
		return false;
		}
	if (maybenull==0 && v.value=='') {
		return false;
	}
	return true;
	}
	///////////////////////////////////////////////////////////////////////////////
//////////////////////////////////	function isDate(f) {
		var t = Date.parse(f.value);
		if (isNaN(t)) {
			return false;
		}
	}
	///////////////////////////////////////////////////////////////////////////////
//////////////////////////////////	function Check(f) {
		var ok=1;
		var _alertString="";
		var alertString2;
		if (f.searchfield.value.length==0) {
			_alertString += "- site name missing\\n";
		}
		if (f.host.value.length==0) {
			_alertString += "- host missing\\n";
		}
		if (f.port.value.length==0) {
			_alertString += "- port missing\\n";
		}
		if (f.db.value.length==0) {
			_alertString += "- database missing\\n";
		}
		if (isNaN(f.port.value)) {
			_alertString += "- port must be a number\\n";
		}
		if (isNaN(f.rank.value)) {
			_alertString += "- rank must be a number\\n";
		}
		if (isNaN(f.checked.value) || f.checked.value<0 || f.checked.value>1) {
			_alertString += "- checked must be 0 or 1\\n";
		}
		if (_alertString.length==0) {
			document.Aform.submit();
		} else {
			alertString2 = "Form not submitted because of the following problem(s)\\n";
			alertString2 += 
"-------------------------------------------------------------------------------
-----\\n\\n";			alertString2 += _alertString;			alert(alertString2);
		}
	}
	</SCRIPT>
printend
;#/
	if ($searchfield) {
		print "<h1>Modify Z39.50 Server</h1>";
	} else {
		print "<h1>Add Z39.50 Server</h1>";
	}
	print "<form action='$script_name' name=Aform method=post>";
	print "<input type=hidden name=op value='add_validate'>";
	print "<table>";
	if ($searchfield) {
		print "<tr><td>Z39.50 Server</td><td><input type=hidden name=searchfield 
value=\"$searchfield\">$searchfield</td></tr>\n";	} else {
		print "<tr><td>Z39.50 Server</td><td><input type=text name=searchfield 
size=40></td></tr>\n";	}
	print "<tr><td>Hostname</td><td><input type=text name=host size=30 
value='$data->{'host'}'></td></tr>\n";	print "<tr><td>Port</td><td><input 
type=text name=port size=5 value='$data->{'port'}' 
onBlur=isNum(this)></td></tr>\n";	print "<tr><td>Database</td><td><input 
type=text name=db value='$data->{'db'}'></td></tr>\n";	print 
"<tr><td>Userid</td><td><input type=text name=userid 
value='$data->{'userid'}'></td></tr>\n";	print "<tr><td>Password</td><td><input 
type=text name=password value='$data->{'password'}'></td></tr>\n";	print 
"<tr><td>Checked (searched by default)</td><td><input type=text size=1 
name=checked value='$data->{'checked'}' onBlur=isNum(this)></td></tr>";	print 
"<tr><td>Rank (display order)</td><td><input type=text name=rank size=4 
value='$data->{'rank'}' onBlur=isNum(this)></td></tr>";	print 
"<tr><td>&nbsp;</td><td><INPUT type=button value='OK' 
onClick='Check(this.form)'></td></tr>";	print "</table>";	print "</form>";;						
							# END $OP eq ADD_FORM################## ADD_VALIDATE 
################################### called by add_form, used to insert/modify 
data in DB} elsif ($op eq 'add_validate') {	my $dbh=C4::Context->dbh;	my 
$sth=$dbh->prepare("select * from z3950servers where name=?");	
$sth->execute($input->param('searchfield'));	if ($sth->rows) {
		$sth=$dbh->prepare("update z3950servers set host=?, port=?, db=?, userid=?, 
password=?, name=?, checked=?, rank=? where name=?");		
$sth->execute($input->param('host'),		      $input->param('port'),
		      $input->param('db'),
		      $input->param('userid'),
		      $input->param('password'),
		      $input->param('searchfield'),
		      $input->param('checked'),
		      $input->param('rank'),
		      $input->param('searchfield')
		      );
	} else {
		$sth=$dbh->prepare("insert into z3950servers 
(host,port,db,userid,password,name,checked,rank) values (?, ?, ?, ?, ?, ?, ?, 
?)");		$sth->execute($input->param('host'),		      $input->param('port'),
		      $input->param('db'),
		      $input->param('userid'),
		      $input->param('password'),
		      $input->param('searchfield'),
		      $input->param('checked'),
		      $input->param('rank'),
		      );
	}
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
	my $sth=$dbh->prepare("select count(*) as total from borrowers where 
branchcode='$searchfield'");	$sth->execute;
	my $total = $sth->fetchrow_hashref;
	$sth->finish;
	print "$reqsel";
	my $sth=$dbh->prepare($reqsel);
	$sth->execute;
	my $data=$sth->fetchrow_hashref;
	$sth->finish;
	print mktablehdr;
	print mktablerow(2,'#99cc33',bold('Branch 
code'),bold("$searchfield"),'/images/background-mem.gif');	print "<form 
action='$script_name' method=post><input type=hidden name=op 
value=delete_confirmed><input type=hidden name=searchfield 
value='$searchfield'>";	print "<tr><td>Branch 
code</td><td>$data->{'branchcode'}</td></tr>";	print "<tr><td>&nbsp; 
name</td><td>$data->{'branchname'}</td></tr>";	print "<tr><td>&nbsp; 
adress</td><td>$data->{'branchaddress1'}</td></tr>";	print 
"<tr><td>&nbsp;</td><td>$data->{'branchaddress2'}</td></tr>";	print 
"<tr><td>&nbsp;</td><td>$data->{'branchaddress3'}</td></tr>";	print 
"<tr><td>&nbsp;phone</td><td>$data->{'branchphone'}</td></tr>";	print 
"<tr><td>&nbsp; fax</td><td>$data->{'branchfax'}</td></tr>";	print 
"<tr><td>&nbsp; e-mail</td><td>$data->{'branchemail'}</td></tr>";	print 
"<tr><td>&nbsp; issuing</td><td>$data->{'issuing'}</td></tr>";	if 
($total->{'total'} >0) {		print "<tr><td colspan=2 align=center><b>This record 
is used $total->{'total'} times. Deletion not possible</b></td></tr>";		print 
"<tr><td colspan=2></form><form action='$script_name' method=post><input 
type=submit value=OK></form></td></tr>";	} else {		print "<tr><td colspan=2 
align=center>CONFIRM DELETION</td></tr>";		print "<tr><td><INPUT type=submit 
value='YES'></form></td><td><form action='$script_name' method=post><input 
type=submit value=NO></form></td></tr>";	}													# END $OP eq 
DELETE_CONFIRM################## DELETE_CONFIRMED 
################################### called by delete_confirm, used to 
effectively confirm deletion of data in DB} elsif ($op eq 'delete_confirmed') {	
my $dbh=C4::Context->dbh;#	my $searchfield=$input->param('branchcode');	my 
$sth=$dbh->prepare($reqdel);	$sth->execute;
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
	print mkheadr(2,'branches admin');
	print mkformnotable("$script_name",@inputs);
	print <<printend

printend
	;
	if  ($searchfield ne '') {
		print "You Searched for <b>$searchfield<b><p>";
	}
	print mktablehdr;
	print mktablerow(10,'#99cc33',bold('Site'),bold('hostname'),bold('port'),
	bold('database'),bold('Userid'),bold('Password'),bold('Checked'),bold('Rank'),
	'&nbsp;','&nbsp;','/images/background-mem.gif');
	my $env;
	my ($count,$results)=StringSearch($env,$searchfield,'web');
	my $toggle="white";
	for (my $i=$offset; $i < ($offset+$pagesize<$count?$offset+$pagesize:$count); 
$i++){	  	if ($toggle eq 'white'){
	    		$toggle="#ffffcc";
	  	} else {
	    		$toggle="white";
	  	}
		
		my $urlsearchfield=$results->[$i]{name};
		$urlsearchfield=~s/ /%20/g;
		print mktablerow(10,$toggle,
			$results->[$i]{'name'},
			$results->[$i]{'host'},
			$results->[$i]{'port'},
			$results->[$i]{'db'},
			$results->[$i]{'userid'},
			($results->[$i]{'password'}) ? ('#######') : ('&nbsp;'),
			$results->[$i]{'checked'},
			$results->[$i]{'rank'},
		mklink("$script_name?op=add_form&searchfield=$urlsearchfield".'','Edit'),
		
mklink("$script_name?op=delete_confirm&searchfield=$urlsearchfield",'Delete'));	
}	print mktableft;
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
	print "<br><input type=image src=\"/images/button-add-new.gif\"  WIDTH=188  
HEIGHT=44  ALT=\"Add budget\" BORDER=0 ></a><br>";	print "</form>";
} #---- END $OP eq DEFAULT
print endmenu('admin');
print endpage();
