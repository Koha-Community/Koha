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
use HTML::Template;
use C4::Auth;
use C4::Interface::CGI::Output;

sub StringSearch  {
	my ($env,$searchstring,$type)=@_;
	my $dbh = C4::Context->dbh;
	$searchstring=~ s/\'/\\\'/g;
	my @data=split(' ',$searchstring);
	my $count=@data;
	my $query="Select host,port,db,userid,password,name,id,checked,rank from z3950servers where (name like \"$data[0]\%\") order by rank,name";
	my $sth=$dbh->prepare($query);
	$sth->execute;
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
my $reqsel="select host,port,db,userid,password,name,id,checked,rank from z3950servers where (name = '$searchfield') order by rank,name";
my $reqdel="delete from z3950servers where name='$searchfield'";
my $offset=$input->param('offset');
my $script_name="/cgi-bin/koha/admin/z3950servers.pl";

my $pagesize=20;
my $op = $input->param('op');
$searchfield=~ s/\,//g;

my ($template, $loggedinuser, $cookie) 
    = get_template_and_user({template_name => "parameters/z3950servers.tmpl",
                             query => $input,
                             type => "intranet",
                             authnotrequired => 0,
                             debug => 1,
                             });


$template->param(script_name => $script_name,
                 searchfield => $searchfield);


################## ADD_FORM ##################################
# called by default. Used to create form to add or  modify a record
if ($op eq 'add_form') {
	$template->param(add_form => 1);
	#---- if primkey exists, it's a modify action, so read values to modify...
	my $data;
	if ($searchfield) {
		my $dbh = C4::Context->dbh;
		my $sth=$dbh->prepare("select host,port,db,userid,password,name,id,checked,rank from z3950servers where (name = '$searchfield') order by rank,name");
		$sth->execute;
		$data=$sth->fetchrow_hashref;
		$sth->finish;
	}
	
	$template->param(host => $data->{'host'},
			 port => $data->{'port'},
			 db   => $data->{'db'},
			 userid => $data->{'userid'},
			 password => $data->{'password'},
			 checked => $data->{'checked'},
			 rank => $data->{'rank'});
													# END $OP eq ADD_FORM
################## ADD_VALIDATE ##################################
# called by add_form, used to insert/modify data in DB
} elsif ($op eq 'add_validate') {
	$template->param(add_validate => 1);
	my $dbh=C4::Context->dbh;
	my $sth=$dbh->prepare("select * from z3950servers where name=?");
	$sth->execute($input->param('searchfield'));
	if ($sth->rows) {
		$sth=$dbh->prepare("update z3950servers set host=?, port=?, db=?, userid=?, password=?, name=?, checked=?, rank=? where name=?");
		$sth->execute($input->param('host'),
		      $input->param('port'),
		      $input->param('db'),
		      $input->param('userid'),
		      $input->param('password'),
		      $input->param('searchfield'),
		      $input->param('checked'),
		      $input->param('rank'),
		      $input->param('searchfield')
		      );
	} else {
		$sth=$dbh->prepare("insert into z3950servers (host,port,db,userid,password,name,checked,rank) values (?, ?, ?, ?, ?, ?, ?, ?)");
		$sth->execute($input->param('host'),
		      $input->param('port'),
		      $input->param('db'),
		      $input->param('userid'),
		      $input->param('password'),
		      $input->param('searchfield'),
		      $input->param('checked'),
		      $input->param('rank'),
		      );
	}
	$sth->finish;
													# END $OP eq ADD_VALIDATE
################## DELETE_CONFIRM ##################################
# called by default form, used to confirm deletion of data in DB
} elsif ($op eq 'delete_confirm') {
	$template->param(delete_confirm => 1);
	my $dbh = C4::Context->dbh;

	my $sth2=$dbh->prepare($reqsel);
	$sth2->execute;
	my $data=$sth2->fetchrow_hashref;
	$sth2->finish;

        $template->param(host => $data->{'host'},
                         port => $data->{'port'},
                         db   => $data->{'db'},
                         userid => $data->{'userid'},
                         password => $data->{'password'},
                         checked => $data->{'checked'},
                         rank => $data->{'rank'});

													# END $OP eq DELETE_CONFIRM
################## DELETE_CONFIRMED ##################################
# called by delete_confirm, used to effectively confirm deletion of data in DB
} elsif ($op eq 'delete_confirmed') {
	$template->param(delete_confirmed => 1);
	my $dbh=C4::Context->dbh;
	my $sth=$dbh->prepare($reqdel);
	$sth->execute;
	$sth->finish;
													# END $OP eq DELETE_CONFIRMED
################## DEFAULT ##################################
} else { # DEFAULT
	$template->param(else => 1);

	my $env;
	my ($count,$results)=StringSearch($env,$searchfield,'web');
	my @loop;
	for (my $i=$offset; $i < ($offset+$pagesize<$count?$offset+$pagesize:$count); $i++){
			
		my $urlsearchfield=$results->[$i]{name};
		$urlsearchfield=~s/ /%20/g;
		my %row	= ( name => $results->[$i]{'name'},
			host => $results->[$i]{'host'},
			port => $results->[$i]{'port'},
			db => $results->[$i]{'db'},
			userid =>$results->[$i]{'userid'},
			password => ($results->[$i]{'password'}) ? ('#######') : ('&nbsp;'),
			checked => $results->[$i]{'checked'},
			rank => $results->[$i]{'rank'});
		push @loop, \%row;
	}
	$template->param(loop => \@loop);
	if ($offset>0) {
		$template->param(offsetgtzero => 1,
				prevpage => $offset-$pagesize);
	}
	if ($offset+$pagesize<$count) {
		$template->param(ltcount => 1,
				 nextpage => $offset+$pagesize);
	}
} #---- END $OP eq DEFAULT

output_html_with_http_headers $input, $cookie, $template->output;
