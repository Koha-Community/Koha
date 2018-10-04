#!/usr/bin/perl

# Copyright 2016 PTFS-Europe Ltd
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

=head1 stockrotation.pl

 Script to manage item assignments to stock rotation rotas. Including their
 assiciated stages

=cut

use Modern::Perl;
use CGI;

use C4::Auth;
use C4::Output;
use C4::Search;
use C4::Serials;

use Koha::Biblio;
use Koha::Item;
use Koha::StockRotationRotas;
use Koha::StockRotationStages;
use Koha::Util::StockRotation qw(:ALL);

my $input = new CGI;

unless (C4::Context->preference('StockRotation')) {
    # redirect to Intranet home if self-check is not enabled
    print $input->redirect("/cgi-bin/koha/mainpage.pl");
    exit;
}

my %params = $input->Vars();

my $op = $params{op};

my $biblionumber = $input->param('biblionumber');

my ($template, $loggedinuser, $cookie) = get_template_and_user(
    {
        template_name   => 'catalogue/stockrotation.tt',
        query           => $input,
        type            => 'intranet',
        authnotrequired => 0,
        flagsrequired   => {
            catalogue => 1,
            stockrotation => 'manage_rota_items',
        },
    }
);

if (!defined $op) {

    # List all items along with their associated rotas
    my $biblio = Koha::Biblios->find($biblionumber);

    my $items = $biblio->items;

    # Get only rotas with stages
    my $rotas = Koha::StockRotationRotas->search(
        {
            'stockrotationstages.stage_id' => { '!=', undef }
        },
        {
            join     => 'stockrotationstages',
            collapse => 1,
            order_by => 'title'
        }
    );

    # Construct a model to pass to the view
    my @item_data = ();

    while (my $item = $items->next) {

        my $item_hashref = {
            bib_item   => $item
        };

        my $stockrotationitem = $item->stockrotationitem;

        # If this item is on a rota
        if ($stockrotationitem != 0) {

            # This item's rota
            my $rota = $stockrotationitem->stage->rota;

            # This rota's stages
            my $stages = get_stages($rota);

            $item_hashref->{rota} = $rota;

            $item_hashref->{stockrotationitem} = $stockrotationitem;

            $item_hashref->{stages} = $stages;

        }

        push @item_data, $item_hashref;

    }

    $template->param(
        no_op_set         => 1,
        rotas             => $rotas,
        items             => \@item_data,
        branches          => get_branches(),
        biblio            => $biblio,
        biblionumber      => $biblio->biblionumber,
        stockrotationview => 1,
        subscriptionsnumber => CountSubscriptionFromBiblionumber($biblionumber),
        C4::Search::enabled_staff_search_views
    );

} elsif ($op eq "toggle_in_demand") {

    # Toggle in demand
    toggle_indemand($params{item_id}, $params{stage_id});

    # Return to items list
    print $input->redirect("?biblionumber=$biblionumber");

} elsif ($op eq "remove_item_from_stage") {

    # Remove from the stage
    remove_from_stage($params{item_id}, $params{stage_id});

    # Return to items list
    print $input->redirect("?biblionumber=$biblionumber");

} elsif ($op eq "move_to_next_stage") {

    move_to_next_stage($params{item_id}, $params{stage_id});

    # Return to items list
    print $input->redirect("?biblionumber=" . $params{biblionumber});

} elsif ($op eq "add_item_to_rota") {

    my $item = Koha::Items->find($params{item_id});

    $item->add_to_rota($params{rota_id});

    print $input->redirect("?biblionumber=" . $params{biblionumber});

} elsif ($op eq "confirm_remove_from_rota") {

    $template->param(
        op                => $params{op},
        stage_id          => $params{stage_id},
        item_id           => $params{item_id},
        biblionumber      => $params{biblionumber},
        stockrotationview => 1,
        subscriptionsnumber => CountSubscriptionFromBiblionumber($biblionumber),
        C4::Search::enabled_staff_search_views
    );

}

output_html_with_http_headers $input, $cookie, $template->output;

=head1 AUTHOR

Andrew Isherwood <andrew.isherwood@ptfs-europe.com>

=cut
