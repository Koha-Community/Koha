#!/usr/bin/perl

# Copyright 2020 Aleisha Amohia <aleisha@catalyst.net.nz>
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

BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/../kohalib.pl" };
}

# set overdue recalls as overdue. This includes:
# - recalls that have been requested and not fulfilled and have passed their expiration date
# - recalls that have been awaiting pickup for longer than the specified recall_shelf_time circulation rule, or the RecallsMaxPickUpDelay if circ rule is unset

use Koha::Script -cron;
use Koha::DateUtils qw( dt_from_string );
use Koha::Recalls;
use C4::Log;

my $command_line_options = join(" ",@ARGV);

cronlogaction({ info => $command_line_options });

my $recalls = Koha::Recalls->search({ completed => 0 });
my $today = dt_from_string()->truncate( to  => 'day' );
while( my $recall = $recalls->next ) {
    if ( ( $recall->requested or $recall->overdue or $recall->waiting ) and $recall->expiration_date ) {
        my $expiration_date = dt_from_string( $recall->expiration_date )->truncate( to  => 'day' );
        if ( $expiration_date < $today ){
            # recall is requested or overdue and has surpassed the specified expiration date
            $recall->set_expired({ interface => 'COMMANDLINE' });
        }
    }
    if ( $recall->waiting ) {
        my $recall_shelf_time = Koha::CirculationRules->get_effective_rule({
            categorycode => $recall->patron->categorycode,
            itemtype => $recall->item->effective_itemtype,
            branchcode => $recall->pickup_library_id,
            rule_name => 'recall_shelf_time',
        });
        my $waitingdate = dt_from_string( $recall->waiting_date )->truncate( to  => 'day' );
        my $days_waiting = $today->subtract_datetime( $waitingdate );
        if ( defined $recall_shelf_time and $recall_shelf_time->rule_value >= 0 ) {
            if ( $days_waiting->days > $recall_shelf_time->rule_value ) {
                # recall has been awaiting pickup for longer than the circ rules allow
                $recall->set_expired({ interface => 'COMMANDLINE' });
            }
        } else {
            if ( $days_waiting->days >= C4::Context->preference('RecallsMaxPickUpDelay') ) {
                # recall has been awaiting pickup for longer than the syspref allows
                $recall->set_expired({ interface => 'COMMANDLINE' });
            }
        }
    }
}

cronlogaction({ action => 'End', info => "COMPLETED" });
