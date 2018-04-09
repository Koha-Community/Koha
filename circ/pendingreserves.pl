#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use constant PULL_INTERVAL => 2;

use C4::Context;
use C4::Output;
use CGI qw ( -utf8 );
use C4::Auth;
use C4::Debug;
use C4::Items qw( ModItem ModItemTransfer );
use C4::Reserves qw( ModReserveCancelAll );
use Koha::Biblios;
use Koha::DateUtils;
use Koha::Holds;
use DateTime::Duration;

my $input = new CGI;
my $startdate = $input->param('from');
my $enddate = $input->param('to');
my $theme = $input->param('theme');    # only used if allowthemeoverride is set
my $op         = $input->param('op') || '';
my $borrowernumber = $input->param('borrowernumber');
my $reserve_id = $input->param('reserve_id');

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "circ/pendingreserves.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { circulate => "circulate_remaining_permissions" },
        debug           => 1,
    }
);

my @messages;
if ( $op eq 'cancel_reserve' and $reserve_id ) {
    my $hold = Koha::Holds->find( $reserve_id );
    if ( $hold ) {
        $hold->cancel;
        push @messages, { type => 'message', code => 'hold_cancelled' };
    }
} elsif ( $op =~ m|^mark_as_lost| ) {
    my $hold = Koha::Holds->find( $reserve_id );
    die "wrong reserve_id" unless $hold; # This is a bit rude, but we are not supposed to get a wrong reserve_id
    my $item = $hold->item;
    if ( $item and C4::Context->preference('CanMarkHoldsToPullAsLost') =~ m|^allow| ) {
        my $patron = $hold->borrower;
        C4::Circulation::LostItem( $item->itemnumber, "pendingreserves" );
        if ( $op eq 'mark_as_lost_and_notify' and C4::Context->preference('CanMarkHoldsToPullAsLost') eq 'allow_and_notify' ) {
            my $library = $hold->branch;
            my $letter = C4::Letters::GetPreparedLetter(
                module => 'reserves',
                letter_code => 'CANCEL_HOLD_ON_LOST',
                branchcode => $patron->homebranch,
                lang => $patron->lang,
                tables => {
                    branches    => $library->branchcode,
                    borrowers   => $patron->borrowernumber,
                    items       => $item->itemnumber,
                    biblio      => $hold->biblionumber,
                    biblioitems => $hold->biblionumber,
                    reserves    => $hold->unblessed,
                },
            );
            if ( $letter ) {
                my $admin_email_address = $library->branchemail || C4::Context->preference('KohaAdminEmailAddress');

                C4::Letters::EnqueueLetter(
                    {   letter                 => $letter,
                        borrowernumber         => $patron->borrowernumber,
                        message_transport_type => 'email',
                        from_address           => $admin_email_address,
                    }
                );
                unless ( $patron->notice_email_address ) {
                    push @messages, {type => 'alert', code => 'no_email_address', };
                }
                push @messages, { type => 'message', code => 'letter_enqueued' };
            } else {
                push @messages, { type => 'error', code => 'no_template_notice' };
            }
        }
        $hold->cancel;
        if ( $item->homebranch ne $item->holdingbranch ) {
            C4::Items::ModItemTransfer( $item->itemnumber, $item->holdingbranch, $item->homebranch );
        }

        if ( my $yaml = C4::Context->preference('UpdateItemWhenLostFromHoldList') ) {
            $yaml = "$yaml\n\n";  # YAML is anal on ending \n. Surplus does not hurt
            my $assignments;
            eval { $assignments = YAML::Load($yaml); };
            if ($@) {
                warn "Unable to parse UpdateItemWhenLostFromHoldList syspref : $@" if $@;
            }
            else {
                eval {
                    C4::Items::ModItem( $assignments, undef, $item->itemnumber );
                };
                warn "Unable to modify item itemnumber=" . $item->itemnumber . ": $@" if $@;
            }
        }

    } elsif ( not $item ) {
        push @messages, { type => 'alert', code => 'hold_placed_at_biblio_level'};
    } # else the url parameters have been modified and the user is not allowed to continue
}


my $today = dt_from_string;

if ( $startdate ) {
    $startdate =~ s/^\s+//;
    $startdate =~ s/\s+$//;
    $startdate = eval{dt_from_string( $startdate )};
}
unless ( $startdate ){
    # changed from delivered range of 10 years-yesterday to 2 days ago-today
    # Find two days ago for the default shelf pull start date, unless HoldsToPullStartDate sys pref is set.
    $startdate = $today - DateTime::Duration->new( days => C4::Context->preference('HoldsToPullStartDate') || PULL_INTERVAL );
}

if ( $enddate ) {
    $enddate =~ s/^\s+//;
    $enddate =~ s/\s+$//;
    $enddate = eval{dt_from_string( $enddate )};
}
unless ( $enddate ) {
    #similarly: calculate end date with ConfirmFutureHolds (days)
    $enddate = $today + DateTime::Duration->new( days => C4::Context->preference('ConfirmFutureHolds') || 0 );
}

my @reservedata;
my $dbh = C4::Context->dbh;
my $sqldatewhere = "";
my $startdate_iso = output_pref({ dt => $startdate, dateformat => 'iso', dateonly => 1 });
my $enddate_iso   = output_pref({ dt => $enddate, dateformat => 'iso', dateonly => 1 });

$debug and warn $startdate_iso. "\n" . $enddate_iso;

my @query_params = ();

if ($startdate_iso) {
    $sqldatewhere .= " AND reservedate >= ?";
    push @query_params, $startdate_iso;
}
if ($enddate_iso) {
    $sqldatewhere .= " AND reservedate <= ?";
    push @query_params, $enddate_iso;
}

my $strsth =
    "SELECT min(reservedate) as l_reservedate,
            reserves.reserve_id,
            reserves.borrowernumber as borrowernumber,

            GROUP_CONCAT(DISTINCT items.holdingbranch 
                    ORDER BY items.itemnumber SEPARATOR '|') l_holdingbranch,
            reserves.biblionumber,
            reserves.branchcode as l_branch,
            reserves.itemnumber,
            items.holdingbranch,
            items.homebranch,
            GROUP_CONCAT(DISTINCT items.itype 
                    ORDER BY items.itemnumber SEPARATOR '|') l_itype,
            GROUP_CONCAT(DISTINCT items.location 
                    ORDER BY items.itemnumber SEPARATOR '|') l_location,
            GROUP_CONCAT(DISTINCT items.itemcallnumber 
                    ORDER BY items.itemnumber SEPARATOR '<br/>') l_itemcallnumber,
            GROUP_CONCAT(DISTINCT items.enumchron
                    ORDER BY items.itemnumber SEPARATOR '<br/>') l_enumchron,
            GROUP_CONCAT(DISTINCT items.copynumber
                    ORDER BY items.itemnumber SEPARATOR '<br/>') l_copynumber,
            biblio.title,
            biblio.author,
            count(DISTINCT items.itemnumber) as icount,
            count(DISTINCT reserves.borrowernumber) as rcount,
            borrowers.firstname,
            borrowers.surname
    FROM  reserves
        LEFT JOIN items ON items.biblionumber=reserves.biblionumber 
        LEFT JOIN biblio ON reserves.biblionumber=biblio.biblionumber
        LEFT JOIN branchtransfers ON items.itemnumber=branchtransfers.itemnumber
        LEFT JOIN issues ON items.itemnumber=issues.itemnumber
        LEFT JOIN borrowers ON reserves.borrowernumber=borrowers.borrowernumber
    WHERE
    reserves.found IS NULL
    $sqldatewhere
    AND (reserves.itemnumber IS NULL OR reserves.itemnumber = items.itemnumber)
    AND items.itemnumber NOT IN (SELECT itemnumber FROM branchtransfers where datearrived IS NULL)
    AND items.itemnumber NOT IN (select itemnumber FROM reserves where found IS NOT NULL)
    AND issues.itemnumber IS NULL
    AND reserves.priority <> 0 
    AND reserves.suspend = 0
    AND notforloan = 0 AND damaged = 0 AND itemlost = 0 AND withdrawn = 0
    ";
    # GROUP BY reserves.biblionumber allows only items that are not checked out, else multiples occur when 
    #    multiple patrons have a hold on an item


if (C4::Context->preference('IndependentBranches')){
    $strsth .= " AND items.holdingbranch=? ";
    push @query_params, C4::Context->userenv->{'branch'};
}
$strsth .= " GROUP BY reserves.biblionumber ORDER BY biblio.title ";

my $sth = $dbh->prepare($strsth);
$sth->execute(@query_params);

while ( my $data = $sth->fetchrow_hashref ) {
    my $record = Koha::Biblios->find($data->{biblionumber});
    if ($record){
        $data->{subtitle} = [ $record->subtitles ];
    }
    push(
        @reservedata, {
            reservedate     => $data->{l_reservedate},
            firstname       => $data->{firstname} || '',
            surname         => $data->{surname},
            title           => $data->{title},
            subtitle        => $data->{subtitle},
            author          => $data->{author},
            borrowernumber  => $data->{borrowernumber},
            biblionumber    => $data->{biblionumber},
            holdingbranches => [split('\|', $data->{l_holdingbranch})],
            branch          => $data->{l_branch},
            itemcallnumber  => $data->{l_itemcallnumber},
            enumchron       => $data->{l_enumchron},
            copyno          => $data->{l_copynumber},
            count           => $data->{icount},
            rcount          => $data->{rcount},
            pullcount       => $data->{icount} <= $data->{rcount} ? $data->{icount} : $data->{rcount},
            itypes          => [split('\|', $data->{l_itype})],
            locations       => [split('\|', $data->{l_location})],
            reserve_id      => $data->{reserve_id},
            holdingbranch   => $data->{holdingbranch},
            homebranch      => $data->{homebranch},
            itemnumber      => $data->{itemnumber},
        }
    );
}
$sth->finish;

$template->param(
    todaysdate          => $today,
    from                => $startdate,
    to                  => $enddate,
    reserveloop         => \@reservedata,
    "BiblioDefaultView".C4::Context->preference("BiblioDefaultView") => 1,
    HoldsToPullStartDate => C4::Context->preference('HoldsToPullStartDate') || PULL_INTERVAL,
    HoldsToPullEndDate  => C4::Context->preference('ConfirmFutureHolds') || 0,
    messages            => \@messages,
);

output_html_with_http_headers $input, $cookie, $template->output;
