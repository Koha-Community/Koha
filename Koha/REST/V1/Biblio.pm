package Koha::REST::V1::Biblio;

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

use Modern::Perl;

use Mojo::Base 'Mojolicious::Controller';

use C4::Biblio qw( GetBiblioData AddBiblio ModBiblio DelBiblio BiblioAutoLink GetFrameworkCode );
use C4::Items qw ( AddItemBatchFromMarc );
use Koha::Biblios;
use MARC::Record;
use MARC::Batch;
use MARC::File::USMARC;
use MARC::File::XML;

use Data::Dumper;

sub get {
    my $c = shift->openapi->valid_input or return;

    my $biblio = Koha::Biblios->find($c->validation->param('biblionumber'));

    unless ($biblio) {
        return $c->render(status => 404, openapi => {error => "Biblio not found"});
    }
    return $c->render(status => 200, openapi => $biblio);
}

sub getitems {
    my $c = shift->openapi->valid_input or return;

    my $biblio = Koha::Biblios->find($c->validation->param('biblionumber'));
    unless ($biblio) {
        return $c->render(status => 404, openapi => {error => "Biblio not found"});
    }
    return $c->render(status => 200, openapi => { biblio => $biblio, items => $biblio->items });
}

sub getexpanded {
    my $c = shift->openapi->valid_input or return;

    my $biblio = Koha::Biblios->find($c->validation->param('biblionumber'));
    unless ($biblio) {
        return $c->render(status => 404, openapi => {error => "Biblio not found"});
    }
    my @expanded = $biblio->items;
    foreach my $item (@expanded) {

        # we assume item is available by default
        $item->{status} = "available";

        if ($item->{onloan}) {
            $item->{status} = "onloan"
        }

        if ($item->{restricted}) {
            $item->{status} = "restricted";
        }

        # mark as unavailable if notforloan, damaged, lost, or withdrawn
        if ($item->{damaged} || $item->{itemlost} || $item->{withdrawn} || $item->{notforloan}) {
            $item->{status} = "unavailable";
        }

        my $holds = Koha::Holds->search({itemnumber => $item->{itemnumber}})->unblessed;

        # mark as onhold if item marked as hold
        if (scalar(@{$holds}) > 0) {
            $item->{status} = "onhold";
        }
    }
    my @holdings = $biblio->holdings;

    return $c->render(status => 200, openapi => { biblio => $biblio, holdings => \@holdings, items => \@expanded });
}

sub getholdings {
    my $c = shift->openapi->valid_input or return;
 
    my $biblio = Koha::Biblios->find($c->validation->param('biblionumber'));
    unless ($biblio) {
        return $c->render(status => 404, openapi => {error => "Biblio not found"});
    }
    return $c->render(status => 200, openapi => { biblio => $biblio, holdings => $biblio->holdings_full });
}

sub add {
    my $c = shift->openapi->valid_input or return;

    my $biblionumber;
    my $biblioitemnumber;

    my $body = $c->req->body;
    unless ($body) {
        return $c->render(status => 400, openapi => {error => "Missing MARCXML body"});
    }

    my $record = eval {MARC::Record::new_from_xml( $body, "utf8", '')};
    if ($@) {
        return $c->render(status => 400, openapi => {error => $@});
    } else {
        if (C4::Context->preference("BiblioAddsAuthorities")){
            BiblioAutoLink($record, '');
        }
        ( $biblionumber, $biblioitemnumber ) = &AddBiblio($record, '');
    }
    if ($biblionumber) {
        $c->res->headers->location($c->url_for('/api/v1/biblios/')->to_abs . $biblionumber);
        my ( $itemnumbers, $errors ) = &AddItemBatchFromMarc( $record, $biblionumber, $biblioitemnumber, '' );
        unless (@{$errors}) {
            return $c->render(status => 201, openapi => {biblionumber => 0+$biblionumber, items => join(",", @{$itemnumbers})});
        } else {
            warn Dumper($errors);
            return $c->render(status => 400, openapi => {error => "Error creating items, see Koha Logs for details.", biblionumber => $biblionumber, items => join(",", @{$itemnumbers})});
        }
    } else {
        return $c->render(status => 400, openapi => {error => "unable to create record"});
    }
}

# NB: This will not update any items, Items should be a separate API route
sub update {
    my $c = shift->openapi->valid_input or return;

    my $biblionumber = $c->validation->param('biblionumber');

    my $biblio = Koha::Biblios->find($biblionumber);
    unless ($biblio) {
        return $c->render(status => 404, openapi => {error => "Biblio not found"});
    }

    my $success;
    my $body = $c->req->body;
    my $record = eval {MARC::Record::new_from_xml( $body, "utf8", '')};
    if ($@) {
        return $c->render(status => 400, openapi => {error => $@});
    } else {
        my $frameworkcode = GetFrameworkCode( $biblionumber );
        if (C4::Context->preference("BiblioAddsAuthorities")){
            BiblioAutoLink($record, $frameworkcode);
        }
        $success = &ModBiblio($record, $biblionumber, $frameworkcode);
    }
    if ($success) {
        my $biblio = Koha::Biblios->find($c->validation->param('biblionumber'));
        return $c->render(status => 200, openapi => {biblio => $biblio});
    } else {
        return $c->render(status => 400, openapi => {error => "unable to update record"});
    }
}

sub delete {
    my $c = shift->openapi->valid_input or return;

    my $biblio = Koha::Biblios->find($c->validation->param('biblionumber'));
    unless ($biblio) {
        return $c->render(status => 404, openapi => {error => "Biblio not found"});
    }

    my @items = $biblio->items;
    # Delete items first
    my @item_errors = ();
    foreach my $item (@items) {
        my $res = $item->delete;
        unless ($res eq 1) {
            push @item_errors, $item->unblessed->{itemnumber};
        }
    }

    my $res = C4::Biblio::DelBiblio($biblio->biblionumber);

    unless ($res) {
        return $c->render(status => 200, openapi => {});
    } else {
        return $c->render(status => 400, openapi => {
            error => $res,
            items => @item_errors,
        });
    }
}

1;
