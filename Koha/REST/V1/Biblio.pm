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

use C4::Biblio qw( GetBiblioData AddBiblio ModBiblio DelBiblio );
use C4::Items qw ( AddItemBatchFromMarc );
use Koha::Biblios;
use MARC::Record;
use MARC::Batch;
use MARC::File::USMARC;
use MARC::File::XML;

use Data::Dumper;

sub get {
    my ($c, $args, $cb) = @_;

    my $biblio = &GetBiblioData($args->{biblionumber});
    unless ($biblio) {
        return $c->$cb({error => "Biblio not found"}, 404);
    }
    return $c->$cb($biblio, 200);
}

sub getitems {
    my ($c, $args, $cb) = @_;

    my $biblio = Koha::Biblios->find($args->{biblionumber});
    unless ($biblio) {
        return $c->$cb({error => "Biblio not found"}, 404);
    }
    return $c->$cb({ biblio => $biblio->unblessed, items => $biblio->items->unblessed }, 200);
}

sub getexpanded {
    my ($c, $args, $cb) = @_;

    my $biblio = Koha::Biblios->find($args->{biblionumber});
    unless ($biblio) {
        return $c->$cb({error => "Biblio not found"}, 404);
    }
    my $expanded = $biblio->items->unblessed;
    for my $item (@{$expanded}) {

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

    return $c->$cb({ biblio => $biblio->unblessed, items => $expanded }, 200);
}

sub add {
    my ($c, $args, $cb) = @_;

    my $biblionumber;
    my $biblioitemnumber;

    my $body = $c->req->body;
    unless ($body) {
        return $c->$cb({error => "Missing MARCXML body"}, 400);
    }

    my $record = eval {MARC::Record::new_from_xml( $body, "utf8", '')};
    if ($@) {
        return $c->$cb({error => $@}, 400);
    } else {
        ( $biblionumber, $biblioitemnumber ) = &AddBiblio($record, '');
    }
    if ($biblionumber) {
        $c->res->headers->location($c->url_for('/api/v1/biblios/')->to_abs . $biblionumber);
        my ( $itemnumbers, $errors ) = &AddItemBatchFromMarc( $record, $biblionumber, $biblioitemnumber, '' );
        unless (@{$errors}) {
            return $c->$cb({biblionumber => $biblionumber, items => join(",", @{$itemnumbers})}, 201);
        } else {
            warn Dumper($errors);
            return $c->$cb({error => "Error creating items, see Koha Logs for details.", biblionumber => $biblionumber, items => join(",", @{$itemnumbers})}, 400);
        }
    } else {
        return $c->$cb({error => "unable to create record"}, 400);
    }
}

# NB: This will not update any items, Items should be a separate API route
sub update {
    my ($c, $args, $cb) = @_;

    my $biblionumber = $args->{biblionumber};

    my $biblio = Koha::Biblios->find($biblionumber);
    unless ($biblio) {
        return $c->$cb({error => "Biblio not found"}, 404);
    }

    my $success;
    my $body = $c->req->body;
    my $record = eval {MARC::Record::new_from_xml( $body, "utf8", '')};
    if ($@) {
        return $c->$cb({error => $@}, 400);
    } else {
        $success = &ModBiblio($record, $biblionumber, '');
    }
    if ($success) {
        $c->res->headers->location($c->url_for('/api/v1/biblios/')->to_abs . $biblionumber);
        return $c->$cb({biblio => Koha::Biblios->find($biblionumber)->unblessed}, 200);
    } else {
        return $c->$cb({error => "unable to update record"}, 400);
    }
}

sub delete {
    my ($c, $args, $cb) = @_;

    my $biblio = Koha::Biblios->find($args->{biblionumber});
    unless ($biblio) {
        return $c->$cb({error => "Biblio not found"}, 404);
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
    my $res = $biblio->delete;
    if ($res eq '1') {
        return $c->$cb({}, 200);
    } elsif ($res eq '-1') {
        return $c->$cb({error => "Not found. Error code: " . $res, items => @item_errors}, 404);
    } else {
        return $c->$cb({error => "Error code: " . $res, items => @item_errors}, 400);
    }
}

1;
