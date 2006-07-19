#!/usr/bin/perl

# Copyright 2000-2003 Katipo Communications
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

# $Id$

=head1 NAME

subscription-add.pl

=head1 DESCRIPTION

this script add a subscription into the database.

=head1 PARAMETERS

=over 4

=item op
op use to know the operation to do on this template.
 * mod : to modify an existing subscription
 * addsubscription : to add a subscription

Note that if op = mod or addsubscription there are a lot of other params.


=back

=cut


use strict;
use CGI;
use C4::Koha;
use C4::Auth;
use C4::Date;
use C4::Output;
use C4::Serials;
use C4::Acquisition;
use C4::Interface::CGI::Output;
use C4::Context;
use HTML::Template;
use C4::Letters;
use C4::Members;

my $query = new CGI;
my $op = $query->param('op');
my $dbh = C4::Context->dbh;
my ($subscriptionid,$auser,$librarian,$cost,$aqbooksellerid, $aqbooksellername,$aqbudgetid, $bookfundid, $startdate, $periodicity,
    $dow, $numberlength, $weeklength, $monthlength,
    $add1,$every1,$whenmorethan1,$setto1,$lastvalue1,$innerloop1,
    $add2,$every2,$whenmorethan2,$setto2,$lastvalue2,$innerloop2,
    $add3,$every3,$whenmorethan3,$setto3,$lastvalue3,$innerloop3,
    $numberingmethod, $status, $biblionumber,
    $bibliotitle, $notes, $letter);

    my @budgets;
my ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "serials/subscription-add.tmpl",
                query => $query,
                type => "intranet",
                authnotrequired => 0,
                flagsrequired => {catalogue => 1},
                debug => 1,
                });


#FIXME : If Budgets are never used, then these lines are useless.
$dbh = C4::Context->dbh;
my $sthtemp = GetBranchCodeFromBorrowers();
$sthtemp->execute($loggedinuser);
my ($flags, $homebranch)=$sthtemp->fetchrow;
#FIXME : END added by hdl on July,14 2005

if ($op eq 'mod') {
    my $subscriptionid = $query->param('subscriptionid');
    my $subs = &GetSubscription($subscriptionid);
    $auser = $subs->{'user'};
    $librarian = $subs->{'librarian'};
    $cost = $subs->{'cost'};
    $aqbooksellerid = $subs->{'aqbooksellerid'};
    $aqbooksellername = $subs->{'aqbooksellername'};
    $bookfundid = $subs->{'bookfundid'};
    $aqbudgetid = $subs->{'aqbudgetid'};
    defined $aqbudgetid or $aqbudgetid='';
    $startdate = $subs->{'startdate'};
    $periodicity = $subs->{'periodicity'};
    $dow = $subs->{'dow'};
    $numberlength = $subs->{'numberlength'};
    $weeklength = $subs->{'weeklength'};
    $monthlength = $subs->{'monthlength'};
    $add1 = $subs->{'add1'};
    $every1 = $subs->{'every1'};
    $whenmorethan1 = $subs->{'whenmorethan1'};
    $setto1 = $subs->{'setto1'};
    $lastvalue1 = $subs->{'lastvalue1'};
    $innerloop1 = $subs->{'innerloop1'};
    $add2 = $subs->{'add2'};
    $every2 = $subs->{'every2'};
    $whenmorethan2 = $subs->{'whenmorethan2'};
    $setto2 = $subs->{'setto2'};
    $lastvalue2 = $subs->{'lastvalue2'};
    $innerloop2 = $subs->{'innerloop2'};
    $add3 = $subs->{'add3'};
    $every3 = $subs->{'every3'};
    $whenmorethan3 = $subs->{'whenmorethan3'};
    $setto3 = $subs->{'setto3'};
    $lastvalue3 = $subs->{'lastvalue3'};
    $innerloop3 = $subs->{'innerloop3'};
    $numberingmethod = $subs->{'numberingmethod'};
    $status = $subs->{status};
    $biblionumber = $subs->{'biblionumber'};
    $bibliotitle = $subs->{'bibliotitle'},
    $notes = $subs->{'notes'};
    $letter = $subs->{'letter'};
    defined $letter or $letter='';
    $template->param(
        $op => 1,
        user => $auser,
        librarian => $librarian,
        aqbooksellerid => $aqbooksellerid,
        aqbooksellername => $aqbooksellername,
        cost => $cost,
        aqbudgetid => $aqbudgetid,
        bookfundid => $bookfundid,
        startdate => format_date($startdate),
        periodicity => $periodicity,
        dow => $dow,
        numberlength => $numberlength,
        weeklength => $weeklength,
        monthlength => $monthlength,
        add1 => $add1,
        every1 => $every1,
        whenmorethan1 => $whenmorethan1,
        setto1 => $setto1,
        lastvalue1 => $lastvalue1,
        innerloop1 => $innerloop1,
        add2 => $add2,
        every2 => $every2,
        whenmorethan2 => $whenmorethan2,
        setto2 => $setto2,
        lastvalue2 => $lastvalue2,
        innerloop2 => $innerloop2,
        add3 => $add3,
        every3 => $every3,
        whenmorethan3 => $whenmorethan3,
        setto3 => $setto3,
        lastvalue3 => $lastvalue3,
        innerloop3 => $innerloop3,
        numberingmethod => $numberingmethod,
        status => $status,
        biblionumber => $biblionumber,
        bibliotitle => $bibliotitle,
        notes => $notes,
        letter => $letter,
        subscriptionid => $subscriptionid,
        "periodicity$periodicity" => 1,
        "dow$dow" => 1,
        );
}
@budgets = GetBookFunds($homebranch);
my $temp = scalar(@budgets);

# find default value & set it for the template
for (my $i=0;$i<$#budgets;$i++) {
    if ($budgets[$i]->{'aqbudgetid'} eq $aqbudgetid) {
        $budgets[$i]->{'selected'}=1;
    }
}
$template->param(budgets => \@budgets);
#FIXME : END Added by hdl on July, 14 2005

my @letterlist = GetLetterList('serial');
for (my $i=0;$i<=$#letterlist;$i++) {
    $letterlist[$i]->{'selected'} =1 if $letterlist[$i]->{'code'} eq $letter;
}
$template->param(letters => \@letterlist);

if ($op eq 'addsubscription') {
    my $auser = $query->param('user');
    my $aqbooksellerid = $query->param('aqbooksellerid');
    my $cost = $query->param('cost');
    my $aqbudgetid = $query->param('aqbudgetid');
    my $startdate = $query->param('startdate');
    my $periodicity = $query->param('periodicity');
    my $dow = $query->param('dow');
    my $numberlength = $query->param('numberlength');
    my $weeklength = $query->param('weeklength');
    my $monthlength = $query->param('monthlength');
    my $add1 = $query->param('add1');
    my $every1 = $query->param('every1');
    my $whenmorethan1 = $query->param('whenmorethan1');
    my $setto1 = $query->param('setto1');
    my $lastvalue1 = $query->param('lastvalue1');
    my $add2 = $query->param('add2');
    my $every2 = $query->param('every2');
    my $whenmorethan2 = $query->param('whenmorethan2');
    my $setto2 = $query->param('setto2');
    my $lastvalue2 = $query->param('lastvalue2');
    my $add3 = $query->param('add3');
    my $every3 = $query->param('every3');
    my $whenmorethan3 = $query->param('whenmorethan3');
    my $setto3 = $query->param('setto3');
    my $lastvalue3 = $query->param('lastvalue3');
    my $numberingmethod = $query->param('numberingmethod');
    my $status = 1;
    my $biblionumber = $query->param('biblionumber');
    my $notes = $query->param('notes');
    my $letter = $query->param('letter');
    my $subscriptionid = NewSubscription($auser,$aqbooksellerid,$cost,$aqbudgetid,$biblionumber,
                    $startdate,$periodicity,$dow,$numberlength,$weeklength,$monthlength,
                    $add1,$every1,$whenmorethan1,$setto1,$lastvalue1,
                    $add2,$every2,$whenmorethan2,$setto2,$lastvalue2,
                    $add3,$every3,$whenmorethan3,$setto3,$lastvalue3,
                    $numberingmethod, $status, $notes, $letter
                );
    print $query->redirect("/cgi-bin/koha/serials/subscription-detail.pl?subscriptionid=$subscriptionid");
} else {
    output_html_with_http_headers $query, $cookie, $template->output;
}
