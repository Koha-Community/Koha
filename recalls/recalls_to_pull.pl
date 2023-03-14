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
use List::MoreUtils qw( uniq );

use C4::Auth qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use Koha::BiblioFrameworks;

my $query = CGI->new;
my ( $template, $loggedinuser, $cookie, $flags ) = get_template_and_user(
    {
      template_name   => "recalls/recalls_to_pull.tt",
      query           => $query,
      type            => "intranet",
      flagsrequired   => { recalls => 'manage_recalls' },
      debug           => 1,
    }
);

my $op = $query->param('op') || 'list';
my $recall_id = $query->param('recall_id');
if ( $op eq 'cancel' ) {
    my $recall = Koha::Recalls->find( $recall_id );
    if ( $recall->in_transit ) {
        C4::Items::ModItemTransfer(
            $recall->item->itemnumber, $recall->item->holdingbranch,
            $recall->item->homebranch, 'RecallCancellation'
        );
    }
    $recall->set_cancelled;
    $op = 'list';
}

if ( $op eq 'list' ) {
    my @recalls = Koha::Recalls->search({ status => [ 'requested','overdue' ] })->as_list;
    my @pull_list;
    my %seen_bib;
    foreach my $recall ( @recalls ) {
        if ( $seen_bib{$recall->biblio_id} ){
            # we've already looked at the recalls on this biblio
            next;
        } else {
            # this is an unseen biblio
            $seen_bib{$recall->biblio_id}++;

            # get recall data about this biblio
            my $biblio = $recall->biblio;
            my @this_bib_recalls = $biblio->recalls->search(
                { status   => [ 'requested','overdue' ] },
                { order_by => { -asc => 'created_date' } }
            )->as_list;
            my $recalls_count = scalar @this_bib_recalls;
            my @unique_patrons = uniq @this_bib_recalls ;
            my $patrons_count = scalar @unique_patrons;
            my $first_recall = $this_bib_recalls[0];

            my $items_count = 0;
            my @callnumbers;
            my @copynumbers;
            my @enumchrons;
            my @itemtypes;
            my @locations;
            my @libraries;

            my @items = $biblio->items->as_list;
            foreach my $item ( @items ) {
                if ( $item->can_be_waiting_recall and !$item->checkout and Koha::Recalls->search({ item_id => $item->id, status => [ 'waiting','in_transit' ], completed => 0 })->count == 0 ) {
                    # if item can be pulled to fulfill recall, collect item data
                    $items_count++;
                    push( @callnumbers, $item->itemcallnumber ) if ( $item->itemcallnumber );
                    push( @copynumbers, $item->copynumber ) if ( $item->copynumber );
                    push( @enumchrons, $item->enumchron ) if ( $item->enumchron );
                    push( @itemtypes, $item->effective_itemtype ) if ( $item->effective_itemtype );
                    push( @locations, $item->location ) if ( $item->location );
                    push( @libraries, $item->holdingbranch ) if ( $item->holdingbranch );
                }
            }

            if ( $items_count > 0 ) {
            # don't push data if there are no items available for this recall

                # get unique values
                push( @pull_list, {
                    biblio => $biblio,
                    items_count => $items_count,
                    recalls_count => $recalls_count,
                    patrons_count => $patrons_count,
                    pull_count => $items_count <= $recalls_count ? $items_count : $recalls_count,
                    first_recall => $first_recall,
                    callnumbers   => [ uniq @callnumbers ],
                      copynumbers => [ uniq @copynumbers ],
                      enumchrons  => [ uniq @enumchrons ],
                      itemtypes   => [ uniq @itemtypes ],
                      locations   => [ uniq @locations ],
                      libraries   => [ uniq @libraries ],
                });
            }
        }
    }
    $template->param(
        recalls => \@pull_list,
    );
}

# Checking if there is a Fast Cataloging Framework
$template->param( fast_cataloging => 1 ) if Koha::BiblioFrameworks->find( 'FA' );

# writing the template
output_html_with_http_headers $query, $cookie, $template->output;
