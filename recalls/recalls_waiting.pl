#!/usr/bin/perl

# Copyright 2020 Aleisha Amohia <aleisha@catalyst.net.nz>
#
# This file is part of Koha.
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
use CGI qw ( -utf8 );
use C4::Auth qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use Koha::Recalls;
use Koha::BiblioFrameworks;
use Koha::DateUtils qw( dt_from_string );
use Koha::Patrons;

my $query = CGI->new;
my ( $template, $loggedinuser, $cookie, $flags ) = get_template_and_user(
    {
        template_name   => "recalls/recalls_waiting.tt",
        query           => $query,
        type            => "intranet",
        flagsrequired   => { recalls => "manage_recalls" },
        debug           => 1,
    }
);

my $op = $query->param('op') || 'list';

if ( $op eq 'modify' ) {
    my $expire = $query->param('expire') || '';
    my $revert = $query->param('revert') || '';
    my $recall_id = $query->param('recall_id');
    if ( $expire ) {
        Koha::Recalls->find( $recall_id )->set_expired({ interface => 'INTRANET' });
    } elsif ( $revert ) {
        Koha::Recalls->find( $recall_id )->revert_waiting;
    }
    $op = 'list';
}

if ( $op eq 'list' ) {
    my @recalls = Koha::Recalls->search({ status => 'waiting' })->as_list;
    my $borrower = Koha::Patrons->find( $loggedinuser );
    my @over;
    my $maxdelay = C4::Context->preference('RecallsMaxPickUpDelay') || 7;
    my $today = dt_from_string();
    foreach my $r ( @recalls ){
        my $lastwaitingday = dt_from_string( $r->waiting_date )->add( days => $maxdelay );
        if ( $today > $lastwaitingday ){
            push @over, $r;
        }
    }
    $template->param(
        recalls => \@recalls,
        recallscount =>  scalar @recalls,
        over => \@over,
        overcount => scalar @over,
    );
}

# Checking if there is a Fast Cataloging Framework
$template->param( fast_cataloging => 1 ) if Koha::BiblioFrameworks->find( 'FA' );

# writing the template
output_html_with_http_headers $query, $cookie, $template->output;
