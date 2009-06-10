#!/usr/bin/perl
# NOTE: 4-character tabs

#written 20/02/2002 by paul.poulain@free.fr
# This software is placed under the gnu General Public License, v2 (http://www.gnu.org/licenses/gpl.html)

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
use warnings;
use CGI;
use C4::Context;
use C4::Auth;
use C4::Output;

sub StringSearch  {
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("Select * from biblio_framework where (frameworkcode like ?) order by frameworktext");
	$sth->execute((shift || '') . '%');
    return $sth->fetchall_arrayref({});
}

my $input = new CGI;
my $script_name   = "/cgi-bin/koha/admin/biblio_framework.pl";
my $frameworkcode = $input->param('frameworkcode') || '';
my $offset        = $input->param('offset') || 0;
my $op            = $input->param('op') || '';
my $pagesize      = 20;

my ($template, $borrowernumber, $cookie)
    = get_template_and_user({template_name => "admin/biblio_framework.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {parameters => 1},
			     debug => 1,
			     });

$template->param( script_name  => $script_name);
$template->param(($op||'else') => 1);

my $dbh = C4::Context->dbh;
################## ADD_FORM ##################################
# called by default. Used to create form to add or  modify a record
if ($op eq 'add_form') {
	#start the page and read in includes
	#---- if primkey exists, it's a modify action, so read values to modify...
	my $data;
	if ($frameworkcode) {
		my $sth=$dbh->prepare("select * from biblio_framework where frameworkcode=?");
		$sth->execute($frameworkcode);
		$data=$sth->fetchrow_hashref;
	}
	$template->param(
        frameworkcode => $frameworkcode,
        frameworktext => $data->{'frameworktext'},
    );
													# END $OP eq ADD_FORM
################## ADD_VALIDATE ##################################
# called by add_form, used to insert/modify data in DB
} elsif ($op eq 'add_validate') {
    if ($input->param('modif')) {
        my $sth=$dbh->prepare("UPDATE biblio_framework SET frameworktext=? WHERE frameworkcode=?");
        $sth->execute($input->param('frameworktext'),$input->param('frameworkcode'));
    } else {
        my $sth=$dbh->prepare("INSERT into biblio_framework (frameworkcode,frameworktext) values (?,?)");
        $sth->execute($input->param('frameworkcode'),$input->param('frameworktext'));
    }
	print $input->redirect($script_name);   # FIXME: unnecessary redirect
	exit;
													# END $OP eq ADD_VALIDATE
################## DELETE_CONFIRM ##################################
# called by default form, used to confirm deletion of data in DB
} elsif ($op eq 'delete_confirm') {
	# Check both categoryitem and biblioitems, see Bug 199
    my $sth = $dbh->prepare("select count(*) as total from marc_tag_structure where frameworkcode=?");
    $sth->execute($frameworkcode);
    my $total = $sth->fetchrow_hashref->{total};

	$sth = $dbh->prepare("select * from biblio_framework where frameworkcode=?");
	$sth->execute($frameworkcode);
	my $data = $sth->fetchrow_hashref;

	$template->param(
        frameworkcode => $frameworkcode,
        frameworktext => $data->{'frameworktext'},
        total => $total
    );
													# END $OP eq DELETE_CONFIRM
################## DELETE_CONFIRMED ##################################
# called by delete_confirm, used to effectively confirm deletion of data in DB
} elsif ($op eq 'delete_confirmed') {
    if ($frameworkcode) { 
		my $sth=$dbh->prepare("delete from marc_tag_structure where frameworkcode=?");
		$sth->execute($frameworkcode);
		$sth=$dbh->prepare("delete from marc_subfield_structure where frameworkcode=?");
		$sth->execute($frameworkcode);
		$sth=$dbh->prepare("delete from biblio_framework where frameworkcode=?");
		$sth->execute($frameworkcode);
	}
	print $input->redirect($script_name);   # FIXME: unnecessary redirect
	exit;
													# END $OP eq DELETE_CONFIRMED
################## DEFAULT ##################################
} else { # DEFAULT
	my $results = StringSearch($frameworkcode);
    my $count = scalar(@$results);
	my @loop_data;
	for (my $i=$offset; $i < ($offset+$pagesize<$count?$offset+$pagesize:$count); $i++){
		push @loop_data, {
            frameworkcode => $results->[$i]{'frameworkcode'},
            frameworktext => $results->[$i]{'frameworktext'},
        };
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

