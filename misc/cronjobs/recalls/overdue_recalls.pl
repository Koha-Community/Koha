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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/../kohalib.pl" };
}

# set overdue recalls as overdue

use Koha::Script -cron;
use Koha::DateUtils;
use Koha::Checkouts;
use Koha::Recalls;
use C4::Log;

my $command_line_options = join( " ", @ARGV );

cronlogaction( { info => $command_line_options } );

my $recalls = Koha::Recalls->search( { status => 'requested' } );
while ( my $recall = $recalls->next ) {
    if ( $recall->should_be_overdue ) {
        $recall->set_overdue( { interface => 'COMMANDLINE' } );
    }
}

cronlogaction( { action => 'End', info => "COMPLETED" } );
