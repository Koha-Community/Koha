#!/usr/bin/perl
# NOTE: 4-character tabs

#script to administer the mediatype table
#modified from the itemtype script written 20/02/2002 by paul.poulain@free.fr
#This script written by waylon@robertson.net.nz at 2nd June, 2005

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
use C4::Auth;
use C4::Output;


sub StringSearch  {
	my ($searchstring,$type)=@_;
	my $dbh = C4::Context->dbh;
	$searchstring=~ s/\'/\\\'/g;
	my @data=split(' ',$searchstring);
	my $count=@data;
	my $sth=$dbh->prepare("SELECT * FROM mediatypetable WHERE (description LIKE ?) ORDER BY mediatypecode");
	$sth->execute("$data[0]%");
	my @results;
	while (my $data=$sth->fetchrow_hashref){
	push(@results,$data);
	}
	#  $sth->execute;
	$sth->finish;
	return (scalar(@results),\@results);
}

my $input = new CGI;
my $searchfield=$input->param('description');
my $offset=$input->param('offset');
my $script_name="/cgi-bin/koha/admin/mediatype.pl";
my $mediatypecode=$input->param('mediatypecode');
my $pagesize=20;
my $op = $input->param('op');
$searchfield=~ s/\,//g;
my ($template, $borrowernumber, $cookie)
    = get_template_and_user({template_name => "admin/mediatype.tmpl",
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
################## ADD_FORM ##################################
# called by default. Used to create form to add or  modify a record
if ($op eq 'add_form') {
	#start the page and read in includes
	#---- if primkey exists, it's a modify action, so read values to modify...
	my $data;
    my $itemtypes;
    my $dbh = C4::Context->dbh;
    my @itemtypesselected;
	if ($mediatypecode) {
    	my $sth=$dbh->prepare("SELECT mediatypecode,description,itemtypecodes FROM mediatypetable WHERE mediatypecode=?");
		$sth->execute($mediatypecode);
		$data=$sth->fetchrow_hashref;
		$sth->finish;
        @itemtypesselected = split ( /\|/, $data->{'itemtypecodes'} );
	}

    my $sth=$dbh->prepare("SELECT description,itemtype FROM itemtypes ORDER BY description");
    $sth->execute;
    while (my ($description,$itemtype) = $sth->fetchrow) {
        $itemtypes .='<td><input type="checkbox" name="itemtypecodes" value="'.$itemtype.'"';
        if(grep /$itemtype/,@itemtypesselected){
            $itemtypes .=' checked';
        }
        $itemtypes .='>'.$description.'</td>';
    }

	$template->param(mediatypecode => $mediatypecode,
							description => $data->{'description'},
                            itemtypes => $itemtypes
							);
;
													# END $OP eq ADD_FORM
################## ADD_VALIDATE ##################################
# called by add_form, used to insert/modify data in DB
} elsif ($op eq 'add_validate') {
	my $dbh = C4::Context->dbh;
    my @itemtypecodesarray = $input->param('itemtypecodes');
    my $itemtypecodes=join('|',@itemtypecodesarray);
	my $sth = $dbh->prepaer("SELECT * FROM mediatypetable WHERE mediatypecode = ?");
	$sth->execute($input->param('mediatypecode'));
	if (my $data = $sth->fetchrow_hashref()){
		# row exists, so its a modify
		$sth->finish();
		$sth = $dbh->prepare("UPDATE mediatypetable SET description=?, itemtypecodes=? WHERE mediatypecode =? ");
		$sth->execute($input->param('description'),$itemtypecodes,$input->param('mediatypecode'));
		$sth->finish();
	}
	else {
		# its an add
		$sth->finish();
		$sth = $dbh->prepare("INSERT INTO mediattypetable (mediatypecode,description,itemtypecodes) VALUES (?,?,?)");
		$sth->execute(
		$input->param('mediatypecode'),$input->param('description'),
		$itemtypecodes
        );
		$sth->finish;
	}
	print "Content-Type: text/html\n\n<META HTTP-EQUIV=Refresh CONTENT=\"0; URL=mediatype.pl\"></html>";
	exit;
													# END $OP eq ADD_VALIDATE
################## DELETE_CONFIRM ##################################
# called by default form, used to confirm deletion of data in DB
} elsif ($op eq 'delete_confirm') {
	#start the page and read in includes
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("select mediatypecode,description,itemtypecodes from mediatypetable where mediatypecode=?");
	$sth->execute($mediatypecode);
	my $data=$sth->fetchrow_hashref;
	$sth->finish;

	$template->param(mediatypecode => $mediatypecode,
							description => $data->{'description'},
							itemtypecodes => $data->{'itemtypecodes'});
													# END $OP eq DELETE_CONFIRM
################## DELETE_CONFIRMED ##################################
# called by delete_confirm, used to effectively confirm deletion of data in DB
} elsif ($op eq 'delete_confirmed') {
	#start the page and read in includes
	my $dbh = C4::Context->dbh;
	my $mediatypecode=uc($input->param('mediatypecode'));
	my $sth=$dbh->prepare("delete from mediatypetable where mediatypecode=?");
	$sth->execute($mediatypecode);
	$sth->finish;
	print "Content-Type: text/html\n\n<META HTTP-EQUIV=Refresh CONTENT=\"0; URL=mediatype.pl\"></html>";
	exit;
													# END $OP eq DELETE_CONFIRMED
################## DEFAULT ##################################
} else { # DEFAULT
	my ($count,$results)=StringSearch($searchfield,'web');
	my $toggle=0;
	my @loop_data;
	for (my $i=$offset; $i < ($offset+$pagesize<$count?$offset+$pagesize:$count); $i++){
		my %row_data;
		if ($toggle eq 0){
			$toggle=1;
		} else {
			$toggle=0;
		}
		$row_data{toggle} = $toggle;
		$row_data{mediatypecode} = $results->[$i]{mediatypecode};
		$row_data{description} = $results->[$i]{description};
		$row_data{itemtypecodes} = $results->[$i]{itemtypecodes};
		push(@loop_data, \%row_data);
	}
	$template->param(loop => \@loop_data);
	if ($offset>0) {
		my $prevpage = $offset-$pagesize;
		$template->param(previous => "$script_name?offset=".$prevpage);
	}
	if ($offset+$pagesize<$count) {
		my $nextpage =$offset+$pagesize;
		$template->param(next => "$script_name?offset=".$nextpage);
	}
} #---- END $OP eq DEFAULT
output_html_with_http_headers $input, $cookie, $template->output;

# Local Variables:
# tab-width: 4
# End:
