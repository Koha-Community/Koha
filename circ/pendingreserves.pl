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
use List::MoreUtils qw( uniq );

use C4::Context;
use C4::Output;
use CGI qw ( -utf8 );
use C4::Auth;
use C4::Debug;
use C4::Items qw( ModItemTransfer );
use C4::Reserves qw( ModReserveCancelAll );
use Koha::Biblios;
use Koha::DateUtils;
use Koha::Holds;
use DateTime::Duration;

my $input = CGI->new;
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
        flagsrequired   => { circulate => "circulate_remaining_permissions" },
        debug           => 1,
    }
);

my @messages;
if ( $op eq 'cancel_reserve' and $reserve_id ) {
    my $hold = Koha::Holds->find( $reserve_id );
    if ( $hold ) {
        my $cancellation_reason = $input->param('cancellation-reason');
        $hold->cancel({ cancellation_reason => $cancellation_reason });
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
                branchcode => $patron->branchcode,
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
            C4::Items::ModItemTransfer( $item->itemnumber, $item->holdingbranch, $item->homebranch, 'LostReserve' );
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
                    while ( my ( $f, $v ) = each( %$assignments ) ) {
                        $item->$f($v);
                    }
                    $item->store;
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

# building query parameters
my %where = (
    'reserve.found' => undef,
    'reserve.suspend' => 0,
    'itembib.itemlost' => 0,
    'itembib.withdrawn' => 0,
    'itembib.notforloan' => 0,
    'itembib.itemnumber' => { -not_in => \'SELECT itemnumber FROM branchtransfers WHERE datearrived IS NULL' }
);

# date boundaries
my $startdate_iso = output_pref({ dt => $startdate, dateformat => 'iso', dateonly => 1 });
my $enddate_iso   = output_pref({ dt => $enddate, dateformat => 'iso', dateonly => 1 });
if ( $startdate_iso && $enddate_iso ){
    $where{'reserve.reservedate'} = [ -and => { '>=', $startdate_iso }, { '<=', $enddate_iso } ];
} elsif ( $startdate_iso ){
    $where{'reserve.reservedate'} = { '>=', $startdate_iso };
} elsif ( $enddate_iso ){
    $where{'reserve.reservedate'} = { '<=', $enddate_iso };
}

# Bug 21320
if ( !C4::Context->preference('AllowHoldsOnDamagedItems') ){
    $where{'itembib.damaged'} = 0;
}

if ( C4::Context->preference('IndependentBranches') ){
    $where{'itembib.holdingbranch'} = C4::Context->userenv->{'branch'};
}

# get all distinct unfulfilled reserves
my $distinct_holds = Koha::Holds->search(
    { %where },
    { join => 'itembib', alias => 'reserve' }
);
my @biblionumbers = uniq $distinct_holds->get_column('biblionumber');

# make final reserves hash and fill with info
my $reserves;
foreach my $bibnum ( @biblionumbers ){

    my @items = Koha::Items->search({ biblionumber => $bibnum });
    foreach my $i ( @items ){
        if ( $i->checkout ){
            next;
        }
    }

    my @branchtransfers = map { $_->itemnumber } Koha::Item::Transfers->search({ datearrived => undef }, { columns => [ 'itemnumber' ], collapse => 1 });
    my @issues = map { $_->itemnumber } Koha::Checkouts->search({}, { columns => [ 'itemnumber' ], collapse => 1 });

    # get available item types for each biblio
    my $res_itemtypes;
    if ( C4::Context->preference('item-level_itypes') ){
        $res_itemtypes = Koha::Items->search(
            { biblionumber => $bibnum,
              itype => { '!=', undef },
              itemlost => 0,
              withdrawn => 0,
              notforloan => 0,
              itemnumber => { -not_in => [ @branchtransfers, @issues ] },
            },
            { columns => 'itype',
              distinct => 1,
            }
        );
    } else {
        my $res_itemtypes = Koha::Biblioitems->search(
            { biblionumber => $bibnum, itemtype => { '!=', undef }  },
            { columns => 'itemtype',
              distinct => 1,
            }
        );
    }
    $reserves->{$bibnum}->{itemtypes} = $res_itemtypes;

    # get available locations for each biblio
    my $res_locations = Koha::Items->search(
        { biblionumber => $bibnum,
          location => { '!=', undef },
          itemlost => 0,
          withdrawn => 0,
          notforloan => 0,
          itemnumber => { -not_in => [ @branchtransfers, @issues ] },
        },
        { columns => 'location',
          distinct => 1,
        }
    );
    $reserves->{$bibnum}->{locations} = $res_locations;

    # get available callnumbers for each biblio
    my $res_callnumbers = Koha::Items->search(
        { biblionumber => $bibnum,
          itemcallnumber => { '!=', undef },
          itemlost => 0,
          withdrawn => 0,
          notforloan => 0,
          itemnumber => { -not_in => [ @branchtransfers, @issues ] },
        },
        { columns => 'itemcallnumber',
          distinct => 1,
        }
    );
    $reserves->{$bibnum}->{callnumbers} = $res_callnumbers;

    # get available enumchrons for each biblio
    my $res_enumchrons = Koha::Items->search(
        { biblionumber => $bibnum,
          enumchron => { '!=', undef },
          itemlost => 0,
          withdrawn => 0,
          notforloan => 0,
          itemnumber => { -not_in => [ @branchtransfers, @issues ] },
        },
        { columns => 'enumchron',
          distinct => 1,
        }
    );
    $reserves->{$bibnum}->{enumchrons} = $res_enumchrons;

    # get available copynumbers for each biblio
    my $res_copynumbers = Koha::Items->search(
        { biblionumber => $bibnum,
          copynumber => { '!=', undef },
          itemlost => 0,
          withdrawn => 0,
          notforloan => 0,
          itemnumber => { -not_in => [ @branchtransfers, @issues ] },
        },
        { columns => 'copynumber',
          distinct => 1,
        }
    );
    $reserves->{$bibnum}->{copynumbers} = $res_copynumbers;

    # get available barcodes for each biblio
    my $res_barcodes = Koha::Items->search(
        { biblionumber => $bibnum,
          barcode => { '!=', undef },
          itemlost => 0,
          withdrawn => 0,
          notforloan => 0,
          itemnumber => { -not_in => [ @branchtransfers, @issues ] },
        },
        { columns => 'barcode',
          distinct => 1,
        }
    );
    $reserves->{$bibnum}->{barcodes} = $res_barcodes;

    # get available holding branches for each biblio
    my $res_holdingbranches = Koha::Items->search(
        { biblionumber => $bibnum,
          holdingbranch => { '!=', undef },
          itemlost => 0,
          withdrawn => 0,
          notforloan => 0,
          itemnumber => { -not_in => [ @branchtransfers, @issues ] },
        },
        { columns => 'holdingbranch',
          distinct => 1,
        }
    );
    $reserves->{$bibnum}->{holdingbranches} = $res_holdingbranches;

    # items available
    my $items_count = Koha::Items->search(
        { biblionumber => $bibnum,
          itemlost => 0,
          withdrawn => 0,
          notforloan => 0,
          itemnumber => { -not_in => [ @branchtransfers, @issues ] },
        },
        { select => [ { distinct => 'itemnumber' } ] }
    )->count;
    $reserves->{$bibnum}->{items_count} = $items_count;

    # patrons with holds
    my $patrons_count = Koha::Holds->search(
        { biblionumber => $bibnum },
        { select => [ { distinct => 'borrowernumber' } ] }
    )->count;
    $reserves->{$bibnum}->{patrons_count} = $patrons_count;

    my $pull_count = $items_count <= $patrons_count ? $items_count : $patrons_count;
    if ( $pull_count == 0 ) {
        delete($reserves->{$bibnum});
        next;
    }
    $reserves->{$bibnum}->{pull_count} = $pull_count;

    # get other relevant information
    my $res_info = Koha::Holds->search(
        { 'reserve.biblionumber' => $bibnum, %where },
        { prefetch => [ 'borrowernumber', 'itembib', 'biblio' ],
          order_by => 'priority',
          alias => 'reserve'
        }
    )->next; # get first item in results
    $reserves->{$bibnum}->{borrower} = $res_info->borrower;
    $reserves->{$bibnum}->{item} = $res_info->item;
    $reserves->{$bibnum}->{biblio} = $res_info->biblio;
    $reserves->{$bibnum}->{reserve} = $res_info;
}

$template->param(
    todaysdate          => $today,
    from                => $startdate,
    to                  => $enddate,
    reserves            => $reserves,
    "BiblioDefaultView".C4::Context->preference("BiblioDefaultView") => 1,
    HoldsToPullStartDate => C4::Context->preference('HoldsToPullStartDate') || PULL_INTERVAL,
    HoldsToPullEndDate  => C4::Context->preference('ConfirmFutureHolds') || 0,
    messages            => \@messages,
);

output_html_with_http_headers $input, $cookie, $template->output;
