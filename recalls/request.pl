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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;
use CGI        qw ( -utf8 );
use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use C4::Search;
use Koha::Recalls;
use Koha::Biblios;

my $input = CGI->new;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "recalls/request.tt",
        query         => $input,
        type          => "intranet",
        flagsrequired => { recalls => "manage_recalls" },
        debug         => 1,
    }
);

my $op             = $input->param('op') || 'list';
my @recall_ids     = $input->multi_param('recall_ids');
my $biblionumber   = $input->param('biblionumber');
my $biblio         = Koha::Biblios->find($biblionumber);
my $borrowernumber = $input->param('borrowernumber');
my $error          = $input->param('error');

if ( $op eq 'cud-cancel_multiple_recalls' ) {
    foreach my $id (@recall_ids) {
        Koha::Recalls->find($id)->set_cancelled;
    }
    print $input->redirect( '/cgi-bin/koha/recalls/request.pl?biblionumber=' . $biblionumber );

} elsif ( $op eq 'cud-request' ) {

    if ( C4::Context->preference('UseRecalls') =~ m/staff/
        and $borrowernumber )
    {
        my $patron = Koha::Patrons->find($borrowernumber);

        unless ( $biblio->can_be_recalled( { patron => $patron } ) ) { $error = 'unavailable'; }
        my $items = Koha::Items->search( { biblionumber => $biblionumber } )->as_list;

        # check if already recalled
        my $recalled = $biblio->recalls->filter_by_current->search( { patron_id => $borrowernumber } )->count;
        if ( defined $recalled and $recalled > 0 ) {
            my $recalls_per_record = Koha::CirculationRules->get_effective_rule(
                {
                    categorycode => $patron->categorycode,
                    branchcode   => undef,
                    itemtype     => undef,
                    rule_name    => 'recalls_per_record'
                }
            );
            if (    defined $recalls_per_record
                and $recalls_per_record->rule_value
                and $recalled >= $recalls_per_record->rule_value )
            {
                $error = 'duplicate';
            }
        }

        if ( !defined $error ) {
            my $pickuploc  = $input->param('pickup');
            my $expdate    = $input->param('expirationdate');
            my $level      = $input->param('type');
            my $itemnumber = $input->param('itemnumber');

            my ( $recall, $due_interval, $due_date );

            if ( defined $level and defined $itemnumber ) {
                my $item = Koha::Items->find($itemnumber);
                if ( $item->can_be_recalled( { patron => $patron } ) ) {
                    ( $recall, $due_interval, $due_date ) = Koha::Recalls->add_recall(
                        {
                            patron         => $patron,
                            biblio         => $biblio,
                            branchcode     => $pickuploc,
                            item           => $item,
                            expirationdate => $expdate,
                            interface      => 'staff',
                        }
                    );
                } else {
                    $error = 'cannot';
                }
            } else {
                if ( $biblio->can_be_recalled( { patron => $patron } ) ) {
                    ( $recall, $due_interval, $due_date ) = Koha::Recalls->add_recall(
                        {
                            patron         => $patron,
                            biblio         => $biblio,
                            branchcode     => $pickuploc,
                            expirationdate => $expdate,
                            interface      => 'staff',
                        }
                    );
                } else {
                    $error = 'cannot';
                }
            }
            if ( !defined $recall ) {
                $error = 'failed';
            } else {

                # successful recall, go back to Recalls tab
                print $input->redirect("/cgi-bin/koha/recalls/request.pl?biblionumber=$biblionumber");
            }
        }
    }
}

if ($borrowernumber) {
    my $patron = Koha::Patrons->find($borrowernumber);

    if (    C4::Context->preference('UseRecalls') =~ m/staff/
        and $patron
        and $patron->borrowernumber )
    {
        if ( !$biblio->can_be_recalled( { patron => $patron } ) ) {
            $error = 1;
        }

        my $patron_holds_count = Koha::Holds->search(
            { borrowernumber => $borrowernumber, biblionumber => $biblio->biblionumber, item_level_hold => 0 } )->count;

        $template->param(
            patron             => $patron,
            patron_holds_count => $patron_holds_count,
        );
    }
}

my $recalls  = Koha::Recalls->search( { biblio_id => $biblionumber, completed => 0 } );
my $branches = Koha::Libraries->search;

$template->param(
    recalls     => $recalls,
    recallsview => 1,
    biblio      => $biblio,
    checkboxes  => 1,
    C4::Search::enabled_staff_search_views,
    branches => $branches,
    error    => $error,
);

output_html_with_http_headers $input, $cookie, $template->output;
