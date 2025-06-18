#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright 2020 Aleisha Amohia <aleisha@catalyst.net.nz>
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
use CGI        qw ( -utf8 );
use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use C4::Context;

my $query = CGI->new;
my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name => "opac-recall.tt",
        query         => $query,
        type          => "opac",
    }
);

my $op           = $query->param('op') || '';
my $biblionumber = $query->param('biblionumber');
my $biblio       = Koha::Biblios->find($biblionumber);

if ( C4::Context->preference('UseRecalls') ) {

    my $patron = Koha::Patrons->find($borrowernumber);
    my $error;

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

    # submitting recall request
    if ( $op eq 'cud-request' ) {

        if ( defined $error and $error eq 'unavailable' ) {

            # no items available for recall
            print $query->redirect("/cgi-bin/koha/opac-recall.pl?biblionumber=$biblionumber&error=unavailable");

        } elsif ( !defined $error ) {

            # can recall

            my $level      = $query->param('type');
            my $pickuploc  = $query->param('pickup');
            my $expdate    = $query->param('expirationdate');
            my $itemnumber = $query->param('itemnumber');

            my ( $recall, $due_interval, $due_date );
            if ( $level eq 'itemlevel' and defined $itemnumber ) {
                my $item = Koha::Items->find($itemnumber);
                if ( $item->can_be_recalled( { patron => $patron } ) ) {
                    ( $recall, $due_interval, $due_date ) = Koha::Recalls->add_recall(
                        {
                            patron         => $patron,
                            biblio         => $biblio,
                            branchcode     => $pickuploc,
                            item           => $item,
                            expirationdate => $expdate,
                            interface      => 'OPAC',
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
                            interface      => 'OPAC',
                        }
                    );
                } else {
                    $error = 'cannot';
                }
            }
            if ( defined $recall ) {
                $template->param(
                    success      => 1,
                    due_interval => $due_interval,
                    due_date     => $due_date,
                );
            } else {
                $error = 'failed';
            }
        }
    } elsif ( $op eq 'cud-cancel' ) {
        my $recall_id = $query->param('recall_id');
        Koha::Recalls->find($recall_id)->set_cancelled;
        print $query->redirect('/cgi-bin/koha/opac-user.pl');
    }

    my $branches           = Koha::Libraries->search();
    my $single_branch_mode = $branches->count == 1;

    $template->param(
        biblio             => $biblio,
        error              => $error,
        items              => $items,
        single_branch_mode => $single_branch_mode,
        branches           => $branches,
    );

} else {

    # UseRecalls disabled
    $template->param(
        nosyspref => 1,
        biblio    => $biblio,
    );
}

$template->param( recallsview => 1 );

output_html_with_http_headers $query, $cookie, $template->output, undef, { force_no_caching => 1 };
