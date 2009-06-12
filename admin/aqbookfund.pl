#!/usr/bin/perl

# written 20/02/2002 by paul.poulain@free.fr

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


=head1 NAME

aqbookfund.pl

=head1 DESCRIPTION

script to administer the aqbudget table.

=head1 CGI PARAMETERS

=over 4

=item op
this script use an C<$op> to know what to do.
C<op> can be equal to:
* empty or none of the above values, then
    - the default screen is build (with all records, or filtered datas).
	- the   user can clic on add, modify or delete record.
* add_form, then
	- if primkey exists, this is a modification,so we read the $primkey record
	- builds the add/modify form
* add_validate, then
	- the user has just send datas, so we create/modify the record
* delete_confirm, then
    - we delete the record having primkey=$primkey

=cut

use strict;
# use warnings; FIXME
use CGI;
use List::Util qw/min/;
use C4::Branch; # GetBranches
use C4::Auth;
use C4::Koha;
use C4::Context;
use C4::Bookfund;
use C4::Output;
use C4::Dates;
use C4::Debug;

my $input        = new CGI;
my $script_name  = "/cgi-bin/koha/admin/aqbookfund.pl";
my $bookfundid   = $input->param('bookfundid');
my $branchcodeid = $input->param('branchcode') || '';
my $op           = $input->param('op')         || '';
my $pagesize     = 10;

$bookfundid = uc $bookfundid if $bookfundid;

my ($template, $borrowernumber, $cookie) = get_template_and_user(
    {   template_name   => "admin/aqbookfund.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { parameters => 1 },
        debug           => 1,
    }
);

$template->param(
    action        => $script_name,
    script_name   => $script_name,
    ($op||'else') => 1,
);

my $branches = GetBranches;

#-----############# ADD_FORM ##################################
# called by default. Used to create form to add or  modify a record
if ($op eq 'add_form') {
	#---- if primkey exists, it's a modify action, so read values to modify...
	my $dataaqbookfund;
	if ($bookfundid) {
        $dataaqbookfund = GetBookFund($bookfundid, $branchcodeid);
	    $template->param('header-is-modify-p' => 1);
	    $template->param('current_branch' => $branchcodeid);
	} else {
	    $template->param('header-is-add-p' => 1);
	}
	$template->param(
        'use-header-flags-p' => 1,
        add_or_modify => $bookfundid ? 1 : 0,
        bookfundid    => $bookfundid,
        bookfundname  => $dataaqbookfund->{'bookfundname'}
    );

    my @branchloop;
    foreach my $branchcode (sort keys %{$branches}) {
        push @branchloop, {
            branchcode => $branchcode,
            branchname => $branches->{$branchcode}->{branchname},
            selected   => (defined $bookfundid and defined $dataaqbookfund->{branchcode}
                            and $dataaqbookfund->{branchcode} eq $branchcode) ? 1 : 0,
        };
    }

    $template->param(branches => \@branchloop);

} # END $OP eq ADD_FORM

#-----############# ADD_VALIDATE ##################################
# called by add_form, used to insert/modify data in DB
elsif ($op eq 'add_validate') {
    my $bookfundname = $input->param('bookfundname');
    my $branchcode   = $input->param('branchcode') || undef;
    my $number = Countbookfund($bookfundid,$branchcodeid);
    if ($number == 0 ) {
        NewBookFund(
            $bookfundid,
            $input->param('bookfundname'),
            $input->param('branchcode')||''
        );
    }
    print $input->redirect('aqbookfund.pl');    # FIXME: unnecessary redirect
    exit;
# END $OP eq ADD_VALIDATE
}

#-----############# MOD_VALIDATE ##################################
# called by add_form, used to insert/modify data in DB
elsif ($op eq 'mod_validate') {
	my $bookfundname   = $input->param('bookfundname');
	my $branchcode     = $input->param('branchcode'    ) || undef;
	my $current_branch = $input->param('current_branch') || undef;
	$debug and warn "$bookfundid, $bookfundname, $branchcode";

	my $number = Countbookfund($bookfundid,$branchcodeid);
    if ($number < 2)  {
        $debug and warn "name :$bookfundname branch:$branchcode";
        ModBookFund($bookfundname,$bookfundid,$current_branch, $branchcode);
    }
   print $input->redirect('aqbookfund.pl'); # FIXME: unnecessary redirect
   exit;
}

#-----############# DELETE_CONFIRM ##################################
# called by default form, used to confirm deletion of data in DB
elsif ($op eq 'delete_confirm') {
    my $data = GetBookFund($bookfundid,$branchcodeid);
	$template->param(bookfundid   => $bookfundid);
	$template->param(bookfundname => $data->{'bookfundname'});
	$template->param(branchcode   => $data->{'branchcode'});
}
# called by delete_confirm, used to effectively confirm deletion of data in DB
elsif ($op eq 'delete_confirmed') {
    DelBookFund($bookfundid, $branchcodeid);
}
else { # DEFAULT
    my ($sth);
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
    $sth = GetBookFundsId();

    while (my $row = $sth->fetchrow_hashref) {
        if (defined $input->param('filter_bookfundid') and $input->param('filter_bookfundid') eq $row->{bookfundid}){
            $row->{selected} = 1;
        }
        push @bookfundids_loop, $row;
    }

    $template->param(
        filter_bookfundids  => \@bookfundids_loop,
        filter_branches     => \@branchloop,
        filter_bookfundname => $input->param('filter_bookfundname') || undef,
    );

    # searching the bookfunds corresponding to our filtering rules
    my @results = SearchBookFund(
        $input->param('filter'),
        $input->param('filter_bookfundid'),
        $input->param('filter_bookfundname'),
        $input->param('filter_branchcode'),
    );

    # does the book funds have budgets?
    my @loop_id;
    $sth = GetBookFundsId();
    while (my $row = $sth->fetchrow){
        push @loop_id, $row;
    }

    my ($id,%nb_budgets_of);
    foreach $id (@loop_id){
        my $number = Countbookfund($id);
        $nb_budgets_of{$id} = $number;
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

    foreach my $result (@results[$first .. $last]) {
        push @loop, {
            %{$result},
            branchname  => $branches->{ $result->{branchcode} }->{branchname},
            has_budgets => defined $nb_budgets_of{ $result->{bookfundid} },
        };
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
}

output_html_with_http_headers $input, $cookie, $template->output;
