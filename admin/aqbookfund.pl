#!/usr/bin/perl

#script to administer the aqbudget table
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
use HTML::Template;
use List::Util qw/min/;

use C4::Auth;
use C4::Koha;
use C4::Context;
use C4::Acquisition;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Search;
use C4::Date;

my $dbh = C4::Context->dbh;
my $input = new CGI;
my $script_name="/cgi-bin/koha/admin/aqbookfund.pl";
my $bookfundid=$input->param('bookfundid');
my $pagesize = 10;
my $op = $input->param('op') || '';

my ($template, $borrowernumber, $cookie)
    = get_template_and_user(
        {template_name => "admin/aqbookfund.tmpl",
         query => $input,
         type => "intranet",
         authnotrequired => 0,
         flagsrequired => {parameters => 1, management => 1},
         debug => 1,
     }
    );

if ($op) {
    $template->param(
        script_name => $script_name,
        $op => 1,
    ); # we show only the TMPL_VAR names $op
}
else {
    $template->param(script_name => $script_name,
		else              => 1); # we show only the TMPL_VAR names $op
}
$template->param(action => $script_name);

# my @branches;
# my @select_branch;
# my %select_branches;

my $branches = GetBranches;

################## ADD_FORM ##################################
# called by default. Used to create form to add or  modify a record
if ($op eq 'add_form') {
	#---- if primkey exists, it's a modify action, so read values to modify...
	my $dataaqbookfund;
	my $header;
	if ($bookfundid) {
                my $query = '
SELECT bookfundid,
       bookfundname,
       bookfundgroup,
       branchcode
  FROM aqbookfund
  WHERE bookfundid = ?
';
		my $sth=$dbh->prepare($query);
		$sth->execute($bookfundid);
		$dataaqbookfund = $sth->fetchrow_hashref;
		$sth->finish;
	    }
	if ($bookfundid) {
	    $header = "Modify book fund";
	    $template->param('header-is-modify-p' => 1);
	} else {
	    $header = "Add book fund";
	    $template->param('header-is-add-p' => 1);
	}
	$template->param('use-header-flags-p' => 1);
	$template->param(header => $header); # NOTE deprecated
	my $add_or_modify=0;
	if ($bookfundid) {
	    $add_or_modify=1;
	}
	$template->param(add_or_modify => $add_or_modify);
	$template->param(bookfundid =>$bookfundid);
	$template->param(bookfundname =>$dataaqbookfund->{'bookfundname'});

        my @branchloop;
        foreach my $branchcode (sort keys %{$branches}) {
            my $row = {
                branchcode => $branchcode,
                branchname => $branches->{$branchcode}->{branchname},
            };

            if (defined $bookfundid
                and defined $dataaqbookfund->{branchcode}
                and $dataaqbookfund->{branchcode} eq $branchcode) {
                $row->{selected} = 1;
            }

            push @branchloop, $row;
        }

        $template->param(branches => \@branchloop);

} # END $OP eq ADD_FORM

################## ADD_VALIDATE ##################################
# called by add_form, used to insert/modify data in DB
elsif ($op eq 'add_validate') {
	my $bookfundid = uc $input->param('bookfundid');

        my ($query, $sth);

        $query = '
SELECT COUNT(*) AS counter
  FROM aqbookfund
  WHERE bookfundid = ?
';
        $sth=$dbh->prepare($query);
	$sth->execute($bookfundid);
        my $data = $sth->fetchrow_hashref;
	$sth->finish;
        my $bookfund_already_exists = $data->{counter} > 0 ? 1 : 0;

        if ($bookfund_already_exists) {
            $query = '
UPDATE aqbookfund
  SET bookfundname = ?,
      branchcode = ?
  WHERE bookfundid = ?
';
            $sth=$dbh->prepare($query);
            $sth->execute(
                $input->param('bookfundname'),
                $input->param('branchcode') || undef,
                $bookfundid,
            );
            $sth->finish;

            # budgets depending on a bookfund must have the same branchcode
            # if the bookfund branchcode is set
            if (defined $input->param('branchcode')) {
                $query = '
UPDATE aqbudget
  SET branchcode = ?
';
                $sth=$dbh->prepare($query);
                $sth->execute($input->param('branchcode'));
                $sth->finish;
            }
        }
        else {
            $query = '
INSERT
  INTO aqbookfund
  (bookfundid, bookfundname, branchcode)
  VALUES
  (?, ?, ?)
';
            $sth=$dbh->prepare($query);
            $sth->execute(
                $bookfundid,
                $input->param('bookfundname'),
                $input->param('branchcode') || undef,
            );
            $sth->finish;
        }

        $input->redirect('aqbookfund.pl');
										# END $OP eq ADD_VALIDATE
################## DELETE_CONFIRM ##################################
# called by default form, used to confirm deletion of data in DB
} elsif ($op eq 'delete_confirm') {
	my $sth=$dbh->prepare("select bookfundid,bookfundname,bookfundgroup from aqbookfund where bookfundid=?");
	$sth->execute($bookfundid);
	my $data=$sth->fetchrow_hashref;
	$sth->finish;
	$template->param(bookfundid => $bookfundid);
	$template->param(bookfundname => $data->{'bookfundname'});
													# END $OP eq DELETE_CONFIRM
################## DELETE_CONFIRMED ##################################
# called by delete_confirm, used to effectively confirm deletion of data in DB
} elsif ($op eq 'delete_confirmed') {
	my $bookfundid=uc($input->param('bookfundid'));
	my $sth=$dbh->prepare("delete from aqbookfund where bookfundid=?");
	$sth->execute($bookfundid);
	$sth->finish;
	$sth=$dbh->prepare("delete from aqbudget where bookfundid=?");
	$sth->execute($bookfundid);
	$sth->finish;
													# END $OP eq DELETE_CONFIRMED
################## DEFAULT ##################################
} else { # DEFAULT
    my ($query, $sth);

    $template->param(scriptname => $script_name);

    # filters
    my @branchloop;
    foreach my $branchcode (sort keys %{$branches}) {
        my $row = {
            code => $branchcode,
            name => $branches->{$branchcode}->{branchname},
        };

        if (defined $input->param('filter_branchcode')
            and $input->param('filter_branchcode') eq $branchcode) {
            $row->{selected} = 1;
        }

        push @branchloop, $row;
    }

    my @bookfundids_loop;
    $query = '
SELECT bookfundid
  FROM aqbookfund
';
    $sth = $dbh->prepare($query);
    $sth->execute();
    while (my $row = $sth->fetchrow_hashref) {
        if (defined $input->param('filter_bookfundid')
            and $input->param('filter_bookfundid') eq $row->{bookfundid}) {
            $row->{selected} = 1;
        }

        push @bookfundids_loop, $row;
    }
    $sth->finish;

    $template->param(
        filter_bookfundids => \@bookfundids_loop,
        filter_branches => \@branchloop,
        filter_bookfundname => $input->param('filter_bookfundname') || undef,
    );

    # searching the bookfunds corresponding to our filtering rules
    my @bindings;

    $query = '
SELECT bookfundid,
       bookfundname,
       bookfundgroup,
       branchcode
  FROM aqbookfund
  WHERE 1 = 1';
    if ($input->param('filter')) {
        if ($input->param('filter_bookfundid')) {
            $query.= '
    AND bookfundid = ?
';
            push @bindings, $input->param('filter_bookfundid');
        }
        if ($input->param('filter_bookfundname')) {
            $query.= '
    AND bookfundname like ?
';
            push @bindings, '%'.$input->param('filter_bookfundname').'%';
        }
        if ($input->param('filter_branchcode')) {
            $query.= '
    AND branchcode = ?
';
            push @bindings, $input->param('filter_branchcode');
        }
    }
    $query.= '
  ORDER BY bookfundid
';

    $sth = $dbh->prepare($query);
    $sth->execute(@bindings);
    my @results;
    while (my $row = $sth->fetchrow_hashref) {
        push @results, $row;
    }

    # does the book funds have budgets?
    $query = '
SELECT bookfundid,
       COUNT(*) AS counter
  FROM aqbudget
  GROUP BY bookfundid
';
    $sth = $dbh->prepare($query);
    $sth->execute();
    my %nb_budgets_of;
    while (my $row = $sth->fetchrow_hashref) {
        $nb_budgets_of{ $row->{bookfundid} } = $row->{counter};
    }

    # pagination informations
    my $page = $input->param('page') || 1;
    my @loop;

    my $first = ($page - 1) * $pagesize;

    # if we are on the last page, the number of the last word to display
    # must not exceed the length of the results array
    my $last = min(
        $first + $pagesize - 1,
        scalar(@results) - 1,
    );

    my $toggle = 0;
    foreach my $result (@results[$first .. $last]) {
        push(
            @loop,
            {
                %{$result},
                toggle => $toggle++%2,
                branchname =>
                    $branches->{ $result->{branchcode} }->{branchname},
                has_budgets => defined $nb_budgets_of{ $result->{bookfundid} },
            }
        );
    }

    $template->param(
        bookfund => \@loop,
        pagination_bar => pagination_bar(
            $script_name,
            getnbpages(scalar @results, $pagesize),
            $page,
            'page'
        )
    );
} #---- END $OP eq DEFAULT
$template->param(intranetcolorstylesheet => C4::Context->preference("intranetcolorstylesheet"),
		intranetstylesheet => C4::Context->preference("intranetstylesheet"),
		IntranetNav => C4::Context->preference("IntranetNav"),
		);
output_html_with_http_headers $input, $cookie, $template->output;
