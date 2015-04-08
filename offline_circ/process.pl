#!/usr/bin/perl

# 2009 BibLibre <jeanandre.santoni@biblibre.com>

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
#

use strict;
use warnings;

use CGI;
use C4::Auth;
use C4::Circulation;

my $query = CGI->new;

my ($template, $loggedinuser, $cookie) = get_template_and_user({
    template_name => "offline_circ/list.tt",
    query => $query,
    type => "intranet",
    authnotrequired => 0,
    flagsrequired   => { circulate => "circulate_remaining_permissions" },
});

my $operationid = $query->param('operationid');
my $action = $query->param('action');
my $result;

if ( $action eq 'process' ) {
    my $operation = GetOfflineOperation( $operationid );
    $result = ProcessOfflineOperation( $operation );
} elsif ( $action eq 'delete' ) {
    $result = DeleteOfflineOperation( $operationid );
}

print CGI::header('-type'=>'text/plain', '-charset'=>'utf-8');
print $result;
