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
use C4::Branch; # GetBranches
use List::Util qw/min/;
use C4::Dates qw/format_date format_date_in_iso/;
use C4::Auth;
use C4::Acquisition;
use C4::Context;
use C4::Output;
use C4::Koha;

my $input = new CGI;
my $script_name="/cgi-bin/koha/admin/aqbudget.pl";
my $bookfundid   = $input->param('bookfundid');
my $aqbudgetid   = $input->param('aqbudgetid');
my $branchcodeid = $input->param('branchcode');
my $pagesize = 20;
my $op = $input->param('op');

my ($template, $borrowernumber, $cookie)
    = get_template_and_user(
        {template_name => "admin/aqbudget.tmpl",
         query => $input,
         type => "intranet",
         authnotrequired => 0,
         flagsrequired => {parameters => 1},
         debug => 1,
     }
    );

$template->param(
    action => $script_name,
    DHTMLcalendar_dateformat => C4::Dates->DHTMLcalendar(),
    script_name => $script_name,
    $op || 'else' => 1,
);

my $dbh = C4::Context->dbh;
my $sthtemp = $dbh->prepare("Select flags, branchcode from borrowers where borrowernumber = ?");
$sthtemp->execute($borrowernumber);
my ($flags, $homebranch)=$sthtemp->fetchrow;

################## ADD_FORM ##################################
# called by default. Used to create form to add or  modify a record
if ($op eq 'add_form') {
    my ($query, $dataaqbudget, $dataaqbookfund, $sth);
    my $dbh = C4::Context->dbh;

    #---- if primkey exists, it's a modify action, so read values to modify...
    if ($aqbudgetid) {
        $query = '
SELECT aqbudgetid,
       bookfundname,
       aqbookfund.bookfundid,
       startdate,
       enddate,
       budgetamount,
       aqbudget.branchcode
  FROM aqbudget
    INNER JOIN aqbookfund ON (aqbudget.bookfundid = aqbookfund.bookfundid)
  WHERE aqbudgetid = ? AND 
       (aqbookfund.branchcode = aqbudget.branchcode  OR
        (aqbudget.branchcode IS NULL and aqbookfund.branchcode=""))   
';
        $sth=$dbh->prepare($query);
        $sth->execute($aqbudgetid);
        $dataaqbudget=$sth->fetchrow_hashref;
        $sth->finish;
    }

    $query = '
SELECT aqbookfund.branchcode,
       branches.branchname,
       aqbookfund.bookfundname
  FROM aqbookfund
    LEFT JOIN branches ON aqbookfund.branchcode = branches.branchcode
  WHERE bookfundid = ? AND aqbookfund.branchcode=?
';
    $sth=$dbh->prepare($query);
    $sth->execute(
        defined $aqbudgetid ? $dataaqbudget->{bookfundid} : $bookfundid,
        $branchcodeid
    );
    $dataaqbookfund=$sth->fetchrow_hashref;
    $sth->finish;

    if (defined $aqbudgetid) {
        $template->param(
            bookfundid => $dataaqbudget->{'bookfundid'},
            branchcode => $dataaqbudget->{'branchcode'},
            bookfundname => $dataaqbudget->{'bookfundname'}
        );
    }
    else {
        $template->param(
            bookfundid => $bookfundid,
            branchcode => $dataaqbookfund->{'branchcode'},
            bookfundname => $dataaqbookfund->{bookfundname},
        );
    }

    # Available branches
    my @branches = ();

    $query = '
SELECT branchcode,
       branchname
  FROM branches
  ORDER BY branchname
';
    $sth=$dbh->prepare($query);
    $sth->execute();
    while (my $row = $sth->fetchrow_hashref) {
        my $branch = $row;

        if (defined $dataaqbookfund->{branchcode}) {
            $branch->{selected} =
                $dataaqbookfund->{branchcode} eq $row->{branchcode} ? 1 : 0;
        }
        elsif (defined $aqbudgetid) {
            $branch->{selected} =
                $dataaqbudget->{branchcode} eq $row->{branchcode} ? 1 : 0;
        }

        push @branches, $branch;
    }
    $sth->finish;

    $template->param(
        dateformat => C4::Dates->new()->visual(),
        aqbudgetid => $dataaqbudget->{'aqbudgetid'},
        startdate => format_date($dataaqbudget->{'startdate'}),
          enddate => format_date($dataaqbudget->{'enddate'}),
        budgetamount => $dataaqbudget->{'budgetamount'},
        branches => \@branches,
    );

    if ( $dataaqbookfund->{branchcode}) {
        $template->param(
            disable_branchselection => 1,
            branch => $dataaqbookfund->{branchcode},
        );
    }
													# END $OP eq ADD_FORM
################## ADD_VALIDATE ##################################
# called by add_form, used to insert/modify data in DB
} elsif ($op eq 'add_validate') {
    my ($query, $sth);

    if (defined $aqbudgetid) {
        $query = '
UPDATE aqbudget
  SET bookfundid = ?,
      startdate = ?,
      enddate = ?,
      budgetamount = ?,
      branchcode = ?
  WHERE aqbudgetid = ?
';
        $sth=$dbh->prepare($query);
        $sth->execute(
            $input->param('bookfundid'),
            format_date_in_iso($input->param('startdate')),
            format_date_in_iso($input->param('enddate')),
            $input->param('budgetamount'),
            $input->param('branch') || '',
            $aqbudgetid,
        );
        $sth->finish;
    }
    else {
        $query = '
INSERT
  INTO aqbudget
  (bookfundid, startdate, enddate, budgetamount, branchcode)
  VALUES
  (?, ?, ?, ?, ?)
';
        $sth=$dbh->prepare($query);
        $sth->execute(
            $input->param('bookfundid'),
            format_date_in_iso($input->param('startdate')),
            format_date_in_iso($input->param('enddate')),
            $input->param('budgetamount'),
            $input->param('branch') || '',
        );
        $sth->finish;
    }

    $input->redirect("aqbudget.pl");

# END $OP eq ADD_VALIDATE
################## DELETE_CONFIRM ##################################
# called by default form, used to confirm deletion of data in DB
} elsif ($op eq 'delete_confirm') {
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("select aqbudgetid,bookfundid,startdate,enddate,budgetamount,branchcode from aqbudget where aqbudgetid=?");
	$sth->execute($aqbudgetid);
	my $data=$sth->fetchrow_hashref;
	$sth->finish;
	$template->param(bookfundid => $bookfundid);
	$template->param(aqbudgetid => $data->{'aqbudgetid'});
	$template->param(startdate => format_date($data->{'startdate'}));
	$template->param(enddate => format_date($data->{'enddate'}));
	$template->param(budgetamount => $data->{'budgetamount'});
													# END $OP eq DELETE_CONFIRM
################## DELETE_CONFIRMED ##################################
# called by delete_confirm, used to effectively confirm deletion of data in DB
} elsif ($op eq 'delete_confirmed') {
	my $dbh = C4::Context->dbh;
	my $aqbudgetid=uc($input->param('aqbudgetid'));
	my $sth=$dbh->prepare("delete from aqbudget where aqbudgetid=?");
	$sth->execute($aqbudgetid);
	$sth->finish;
	 print $input->redirect("aqbookfund.pl");
	 return;
													# END $OP eq DELETE_CONFIRMED
################## DEFAULT ##################################
} else { # DEFAULT
    my ($query, $sth);

    # create a look-up table for bookfund names from bookfund ids,
    # instead of having on query per budget
    my %bookfundname_of = ();
    $query = '
SELECT bookfundid, bookfundname
  FROM aqbookfund
';
    $sth=$dbh->prepare($query);
    $sth->execute;
    while (my $row = $sth->fetchrow_hashref) {
        $bookfundname_of{ $row->{bookfundid} } = $row->{bookfundname};
    }
    $sth->finish;

    # filters
    my $branches = GetBranches();
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
        filter_amount => $input->param('filter_amount') || undef,
        filter_startdate => $input->param('filter_startdate') || undef,
        filter_enddate => $input->param('filter_enddate') || undef,
    );

    my %sign_label_of = (
        '=' => 'equal',
        '>=' => 'superior',
        '<=' => 'inferior',
    );

    foreach my $field (qw/startdate enddate amount/) {
        my $param = 'filter_'.$field.'_sign';

        foreach my $sign (keys %sign_label_of) {
            if ($input->param($param) eq $sign) {
                $template->param(
                    $param.'_'.$sign_label_of{$sign}.'_selected' => 1,
                );
            }
        }
    }

    # Search all available budgets
    $query = '
SELECT aqbudgetid,
       bookfundid,
       startdate,
       enddate,
       budgetamount,
       branchcode
  FROM aqbudget
  WHERE 1 = 1';			# What's the point?

    my @bindings;

    if ($input->param('filter_bookfundid')) {
        $query.= '
    AND bookfundid = ?
';
        push @bindings, $input->param('filter_bookfundid');
    }
    if ($input->param('filter_branchcode')) {
        $query.= '
    AND branchcode = ?
';
        push @bindings, $input->param('filter_branchcode');
    }
    if ($input->param('filter_startdate')) {
        $query.= '
    AND startdate '.$input->param('filter_startdate_sign').' ?
';
        push @bindings, format_date_in_iso($input->param('filter_startdate'));
    }
    if ($input->param('filter_enddate')) {
        $query.= '
    AND enddate '.$input->param('filter_enddate_sign').' ?
';
        push @bindings, format_date_in_iso($input->param('filter_enddate'));
    }
    if ($input->param('filter_amount')) {
        $query.= '
    AND budgetamount '.$input->param('filter_amount_sign').' ?
';
        # the amount must be a quantity, with 2 digits after the decimal
        # separator
        $input->param('filter_amount') =~ m{(\d* (?:\.\d{,2})? )}xms;
        my ($amount) = $1;
        push @bindings, $amount;
    }

    $query.= '
  ORDER BY bookfundid, aqbudgetid
';
    $sth = $dbh->prepare($query);
    $sth->execute(@bindings);
    my @results;
    while (my $row = $sth->fetchrow_hashref){
        push @results, $row;
    }
    $sth->finish;

    # filter budgets depending on the pagination
    my $page = $input->param('page') || 1;
    my $first = ($page - 1) * $pagesize;

    # if we are on the last page, the number of the last word to display
    # must not exceed the length of the results array
    my $last = min(
        $first + $pagesize - 1,
        scalar @results - 1,
    );

    my $toggle = 0;
    my @loop;
    foreach my $result (@results[$first .. $last]) {
        push(
            @loop,
            {
                %{$result},
                toggle => $toggle++%2,
                bookfundname => $bookfundname_of{ $result->{'bookfundid'} },
                branchname => $branches->{ $result->{branchcode} }->{branchname},
                startdate => format_date($result->{startdate}),
                enddate => format_date($result->{enddate}),
            }
        );
    }

    $template->param(
        budget => \@loop,
        pagination_bar => pagination_bar(
            $script_name,
            getnbpages(scalar @results, $pagesize),
            $page,
            'page'
        )
    );
} #---- END $OP eq DEFAULT
output_html_with_http_headers $input, $cookie, $template->output;

