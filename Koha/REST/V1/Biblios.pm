package Koha::REST::V1::Biblios;

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

use Mojo::Base 'Mojolicious::Controller';

use Koha::Biblios;
use Koha::DateUtils;
use Koha::Ratings;
use C4::Biblio qw( DelBiblio AddBiblio ModBiblio );
use C4::Search qw( FindDuplicate );

use C4::Auth qw( haspermission );
use C4::Barcodes::ValueBuilder;
use C4::Context;

use Koha::Items;

use List::MoreUtils qw( any );
use MARC::Record::MiJ;

use Try::Tiny qw( catch try );
use JSON      qw( decode_json );

=head1 API

=head2 Methods

=head3 get

Controller function that handles retrieving a single biblio object

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    my $attributes;
    $attributes = { prefetch => ['metadata'] }    # don't prefetch metadata if not needed
        unless $c->req->headers->accept =~ m/application\/json/;

    my $biblio = Koha::Biblios->find( { biblionumber => $c->param('biblio_id') }, $attributes );

    return $c->render_resource_not_found("Bibliographic record")
        unless $biblio;

    return try {

        if ( $c->req->headers->accept =~ m/application\/json/ ) {
            return $c->render(
                status => 200,
                json   => $c->objects->to_api($biblio),
            );
        } else {
            my $metadata = $biblio->metadata;
            my $record   = $metadata->record;
            my $schema   = $metadata->schema // C4::Context->preference("marcflavour");

            $c->respond_to(
                marcxml => {
                    status => 200,
                    format => 'marcxml',
                    text   => $record->as_xml_record($schema),
                },
                mij => {
                    status => 200,
                    format => 'mij',
                    data   => $record->to_mij
                },
                marc => {
                    status => 200,
                    format => 'marc',
                    text   => $record->as_usmarc
                },
                txt => {
                    status => 200,
                    format => 'text/plain',
                    text   => $record->as_formatted
                },
                any => {
                    status  => 406,
                    openapi => [
                        "application/json",
                        "application/marcxml+xml",
                        "application/marc-in-json",
                        "application/marc",
                        "text/plain"
                    ]
                }
            );
        }
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 delete

Controller function that handles deleting a biblio object

=cut

sub delete {
    my $c = shift->openapi->valid_input or return;

    my $biblio = Koha::Biblios->find( $c->param('biblio_id') );

    return $c->render_resource_not_found("Bibliographic record")
        unless $biblio;

    return try {
        my $error = DelBiblio( $biblio->id );

        if ($error) {
            return $c->render(
                status  => 409,
                openapi => { error => $error }
            );
        } else {
            return $c->render_resource_deleted;
        }
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 get_public

Controller function that handles retrieving a single biblio object

=cut

sub get_public {
    my $c = shift->openapi->valid_input or return;

    my $biblio = Koha::Biblios->find(
        { biblionumber => $c->param('biblio_id') },
        { prefetch     => ['metadata'] }
    );

    return $c->render_resource_not_found("Bibliographic record")
        unless $biblio;

    return try {

        my $schema = $biblio->metadata->schema // C4::Context->preference("marcflavour");
        my $patron = $c->stash('koha.user');

        # Check if the bibliographic record should be hidden for unprivileged access
        # unless there's a logged in user, and there's an exception for it's category
        my $opachiddenitems_rules = C4::Context->yaml_preference('OpacHiddenItems');
        unless ( $patron and $patron->category->override_hidden_items ) {
            if ( $biblio->hidden_in_opac( { rules => $opachiddenitems_rules } ) ) {
                return $c->render_resource_not_found("Bibliographic record");
            }
        }

        my $record = $biblio->metadata_record( { interface => 'opac', patron => $patron } );

        $c->respond_to(
            marcxml => {
                status => 200,
                format => 'marcxml',
                text   => $record->as_xml_record($schema),
            },
            mij => {
                status => 200,
                format => 'mij',
                data   => $record->to_mij
            },
            marc => {
                status => 200,
                format => 'marc',
                text   => $record->as_usmarc
            },
            txt => {
                status => 200,
                format => 'text/plain',
                text   => $record->as_formatted
            },
            any => {
                status  => 406,
                openapi => [
                    "application/marcxml+xml",
                    "application/marc-in-json",
                    "application/marc",
                    "text/plain"
                ]
            }
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 get_bookings

Controller function that handles retrieving biblio's bookings

=cut

sub get_bookings {
    my $c = shift->openapi->valid_input or return;

    my $biblio = Koha::Biblios->find( { biblionumber => $c->param('biblio_id') }, { prefetch => ['bookings'] } );

    return $c->render_resource_not_found("Bibliographic record")
        unless $biblio;

    return try {

        my $bookings_rs = $biblio->bookings;
        my $bookings    = $c->objects->search($bookings_rs);
        return $c->render(
            status  => 200,
            openapi => $bookings
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 get_items

Controller function that handles retrieving biblio's items

=cut

sub get_items {
    my $c = shift->openapi->valid_input or return;

    my $biblio        = Koha::Biblios->find( { biblionumber => $c->param('biblio_id') }, { prefetch => ['items'] } );
    my $bookable_only = $c->param('bookable');

    # Deletion of parameter to avoid filtering on the items table in the case of bookings on 'itemtype'
    $c->req->params->remove('bookable');

    return $c->render_resource_not_found("Bibliographic record")
        unless $biblio;

    return try {

        # FIXME We need to order_by serial.publisheddate if we have _order_by=+me.serial_issue_number
        # FIXME Do we always need host_items => 1 or depending on a flag?
        # FIXME Should we prefetch => ['issue','branchtransfer']?
        my $items_rs = $biblio->items( { host_items => 1 } )->search_ordered( {}, { join => 'biblioitem' } );
        $items_rs = $items_rs->filter_by_bookable if $bookable_only;

        # FIXME We need to order_by serial.publisheddate if we have _order_by=+me.serial_issue_number
        my $items = $c->objects->search($items_rs);

        return $c->render(
            status  => 200,
            openapi => $items
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 add_item

Controller function that handles creating a biblio's item

=cut

sub add_item {
    my $c = shift->openapi->valid_input or return;

    try {
        my $biblio_id = $c->param('biblio_id');
        my $biblio    = Koha::Biblios->find($biblio_id);

        return $c->render_resource_not_found("Bibliographic record")
            unless $biblio;

        my $body = $c->req->json;

        $body->{biblio_id} = $biblio_id;

        # Don't save extended subfields yet. To be done in another bug.
        $body->{extended_subfields} = undef;

        my $item = Koha::Item->new_from_api($body);

        if ( !defined $item->barcode ) {

            # FIXME This should be moved to Koha::Item->store
            my $autoBarcode = C4::Context->preference('autoBarcode');
            my $barcode     = '';

            if ( !$autoBarcode || $autoBarcode eq 'OFF' ) {

                #We do nothing
            } elsif ( $autoBarcode eq 'incremental' ) {
                ($barcode) = C4::Barcodes::ValueBuilder::incremental::get_barcode;
            } elsif ( $autoBarcode eq 'annual' ) {
                my $year = Koha::DateUtils::dt_from_string()->year();
                ($barcode) = C4::Barcodes::ValueBuilder::annual::get_barcode( { year => $year } );
            } elsif ( $autoBarcode eq 'hbyymmincr' ) {

                # Generates a barcode where
                #  hb = home branch Code,
                #  yymm = year/month catalogued,
                #  incr = incremental number,
                #  reset yearly -fbcit
                my $now        = Koha::DateUtils::dt_from_string();
                my $year       = $now->year();
                my $month      = $now->month();
                my $homebranch = $item->homebranch // '';
                ($barcode) = C4::Barcodes::ValueBuilder::hbyymmincr::get_barcode( { year => $year, mon => $month } );
                $barcode = $homebranch . $barcode;
            } elsif ( $autoBarcode eq 'EAN13' ) {

                # not the best, two catalogers could add the same
                # barcode easily this way :/
                my $query = "select max(abs(barcode)) from items";
                my $dbh   = C4::Context->dbh;
                my $sth   = $dbh->prepare($query);
                $sth->execute();
                my $nextnum;
                while ( my ($last) = $sth->fetchrow_array ) {
                    $nextnum = $last;
                }
                my $ean = CheckDigits('ean');
                if ( $ean->is_valid($nextnum) ) {
                    my $next = $ean->basenumber($nextnum) + 1;
                    $nextnum = $ean->complete($next);
                    $nextnum = '0' x ( 13 - length($nextnum) ) . $nextnum;    # pad zeros
                } else {
                    warn "ERROR: invalid EAN-13 $nextnum, using increment";
                    $nextnum++;
                }
                $barcode = $nextnum;
            } else {
                warn "ERROR: unknown autoBarcode: $autoBarcode";
            }
            $item->barcode($barcode) if $barcode;
        }

        $item->store->discard_changes;

        my $base_url = $c->req->url->to_string;
        $base_url =~ s|/biblios/\d+||;
        $c->res->headers->location( $base_url . '/' . $item->id );

        $c->render(
            status  => 201,
            openapi => $c->objects->to_api($item),
        );
    } catch {
        if ( blessed $_ and $_->isa('Koha::Exceptions::Object::DuplicateID') ) {
            return $c->render(
                status  => 409,
                openapi => { error => 'Duplicate barcode.' }
            );
        }
        $c->unhandled_exception($_);
    }
}

=head3 update_item

Controller function that handles updating a biblio's item

=cut

sub update_item {
    my $c = shift->openapi->valid_input or return;

    try {
        my $biblio_id = $c->param('biblio_id');
        my $item_id   = $c->param('item_id');
        my $biblio    = Koha::Biblios->find( { biblionumber => $biblio_id } );

        return $c->render_resource_not_found("Bibliographic record")
            unless $biblio;

        my $item = $biblio->items->find( { itemnumber => $item_id } );

        return $c->render_resource_not_found("Item")
            unless $item;

        my $body = $c->req->json;

        $body->{biblio_id} = $biblio_id;

        # Don't save extended subfields yet. To be done in another bug.
        $body->{extended_subfields} = undef;

        $item->set_from_api($body);

        $item->store->discard_changes;

        $c->render(
            status  => 200,
            openapi => $c->objects->to_api($item),
        );
    } catch {
        if ( blessed $_ and $_->isa('Koha::Exceptions::Object::DuplicateID') ) {
            return $c->render(
                status  => 409,
                openapi => { error => 'Duplicate barcode.' }
            );
        }
        $c->unhandled_exception($_);
    }
}

=head3 get_checkouts

List Koha::Checkout objects

=cut

sub get_checkouts {
    my $c = shift->openapi->valid_input or return;

    my $checked_in = $c->param('checked_in');
    $c->req->params->remove('checked_in');

    try {
        my $biblio = Koha::Biblios->find( $c->param('biblio_id') );

        return $c->render_resource_not_found("Bibliographic record")
            unless $biblio;

        my $checkouts =
            ($checked_in)
            ? $c->objects->search( $biblio->old_checkouts )
            : $c->objects->search( $biblio->current_checkouts );

        return $c->render(
            status  => 200,
            openapi => $checkouts
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 pickup_locations

Method that returns the possible pickup_locations for a given biblio
used for building the dropdown selector

=cut

sub pickup_locations {
    my $c = shift->openapi->valid_input or return;

    my $biblio = Koha::Biblios->find( $c->param('biblio_id') );

    return $c->render_resource_not_found("Bibliographic record")
        unless $biblio;

    my $patron = Koha::Patrons->find( $c->param('patron_id') );
    $c->req->params->remove('patron_id');

    unless ($patron) {
        return $c->render(
            status  => 400,
            openapi => { error => "Patron not found" }
        );
    }

    return try {

        my $pl_set = $biblio->pickup_locations( { patron => $patron } );

        my @response = ();
        if ( C4::Context->preference('AllowHoldPolicyOverride') ) {

            my $libraries_rs = Koha::Libraries->search( { pickup_location => 1 } );
            my $libraries    = $c->objects->search($libraries_rs);

            @response = map {
                my $library = $_;
                $library->{needs_override} =
                    ( any { $_->branchcode eq $library->{library_id} } @{ $pl_set->as_list } )
                    ? Mojo::JSON->false
                    : Mojo::JSON->true;
                $library;
            } @{$libraries};
        } else {

            my $pickup_locations = $c->objects->search($pl_set);
            @response = map { $_->{needs_override} = Mojo::JSON->false; $_; } @{$pickup_locations};
        }
        @response = map {
            if ( exists $pl_set->{_pickup_location_items}->{ $_->{library_id} }
                && ref $pl_set->{_pickup_location_items}->{ $_->{library_id} } eq 'ARRAY' )
            {
                $_->{pickup_items} = $pl_set->{_pickup_location_items}->{ $_->{library_id} };
            } else {
                $_->{pickup_items} = [];
            }
            $_;
        } @response;

        return $c->render(
            status  => 200,
            openapi => \@response
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 get_items_public

Controller function that handles retrieving biblio's items, for unprivileged
access.

=cut

sub get_items_public {
    my $c = shift->openapi->valid_input or return;

    my $biblio = Koha::Biblios->find(
        $c->param('biblio_id'),
        { prefetch => ['items'] }
    );

    return $c->render_resource_not_found("Bibliographic record")
        unless $biblio;

    return try {

        my $patron = $c->stash('koha.user');

        my $items_rs = $biblio->items->filter_by_visible_in_opac( { patron => $patron } );
        my $items    = $c->objects->search($items_rs);
        return $c->render(
            status  => 200,
            openapi => $items
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 set_rating

Set rating for the logged in user

=cut

sub set_rating {
    my $c = shift->openapi->valid_input or return;

    my $biblio = Koha::Biblios->find( $c->param('biblio_id') );

    $c->render_resource_not_found("Bibliographic record")
        unless $biblio;

    my $patron = $c->stash('koha.user');
    unless ($patron) {
        return $c->render(
            status  => 403,
            openapi => { error => "Cannot rate. Reason: must be logged-in" }
        );
    }

    my $body         = $c->req->json;
    my $rating_value = $body->{rating};

    return try {

        my $rating = Koha::Ratings->find(
            {
                biblionumber   => $biblio->biblionumber,
                borrowernumber => $patron->borrowernumber,
            }
        );
        $rating->delete if $rating;

        if ($rating_value) {    # Cannot set to 0 from the UI
            $rating = Koha::Rating->new(
                {
                    biblionumber   => $biblio->biblionumber,
                    borrowernumber => $patron->borrowernumber,
                    rating_value   => $rating_value,
                }
            )->store;
        }
        my $ratings = Koha::Ratings->search( { biblionumber => $biblio->biblionumber } );
        my $average = $ratings->get_avg_rating;

        return $c->render(
            status  => 200,
            openapi => {
                rating  => $rating && $rating->in_storage ? $rating->rating_value : undef,
                average => $average,
                count   => $ratings->count
            },
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 add

Controller function that handles creating a biblio object

=cut

sub add {
    my $c = shift->openapi->valid_input or return;

    try {
        my $headers = $c->req->headers;

        my $flavour = $headers->header('x-record-schema');
        $flavour //= C4::Context->preference('marcflavour');

        my $record_source_id = $headers->header('x-record-source-id');

        if ($record_source_id) {

            # We've been passed a record source. Verify they are allowed to
            unless ( haspermission( $c->stash('koha.user')->userid, { editcatalogue => 'set_record_sources' } ) ) {
                return $c->render(
                    status  => 403,
                    openapi => { error => 'You do not have permission to set the record source' }
                );
            }
        }

        my $record;

        my $frameworkcode = $headers->header('x-framework-id');
        my $content_type  = $headers->content_type;

        if ( $content_type =~ m/application\/marcxml\+xml/ ) {
            $record = MARC::Record->new_from_xml( $c->req->body, 'UTF-8', $flavour );
        } elsif ( $content_type =~ m/application\/marc-in-json/ ) {
            $record = MARC::Record->new_from_mij_structure( $c->req->json );
        } elsif ( $content_type =~ m/application\/marc/ ) {
            $record = MARC::Record->new_from_usmarc( $c->req->body );
        } else {
            return $c->render(
                status  => 406,
                openapi => [
                    "application/marcxml+xml",
                    "application/marc-in-json",
                    "application/marc"
                ]
            );
        }

        my $confirm_not_duplicate = $headers->header('x-confirm-not-duplicate');

        if ( !$confirm_not_duplicate ) {
            my ( $duplicatebiblionumber, $duplicatetitle ) = FindDuplicate($record);

            return $c->render(
                status  => 400,
                openapi => {
                    error => "Duplicate biblio $duplicatebiblionumber",
                }
            ) if $duplicatebiblionumber;
        }

        my ($biblio_id) = C4::Biblio::AddBiblio( $record, $frameworkcode, { record_source_id => $record_source_id } );

        if ( !$biblio_id ) {

            # FIXME: AddBiblio wraps everything inside a transaction and a try/catch block
            # this will need a tweak if this behavior changes
            return $c->render(
                status  => 400,
                openapi => {
                    error      => 'Error creating record',
                    error_code => 'record_creation_failed',
                },
            );
        }

        $c->res->headers->location( $c->req->url->to_string . '/' . $biblio_id );

        return $c->render(
            status  => 200,
            openapi => { id => $biblio_id }
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 update

Controller function that handles modifying an biblio object

=cut

sub update {
    my $c = shift->openapi->valid_input or return;

    my $biblio = Koha::Biblios->find( $c->param('biblio_id') );

    $c->render_resource_not_found("Bibliographic record")
        unless $biblio;

    try {
        my $headers = $c->req->headers;

        my $flavour = $headers->header('x-record-schema');
        $flavour //= C4::Context->preference('marcflavour');

        my $frameworkcode = $headers->header('x-framework-id') || $biblio->frameworkcode;

        my $content_type = $headers->content_type;

        my $record;

        if ( $content_type =~ m/application\/marcxml\+xml/ ) {
            $record = MARC::Record->new_from_xml( $c->req->body, 'UTF-8', $flavour );
        } elsif ( $content_type =~ m/application\/marc-in-json/ ) {
            $record = MARC::Record->new_from_mij_structure( $c->req->json );
        } elsif ( $content_type =~ m/application\/marc/ ) {
            $record = MARC::Record->new_from_usmarc( $c->req->body );
        } else {
            return $c->render(
                status  => 406,
                openapi => [
                    "application/json",
                    "application/marcxml+xml",
                    "application/marc-in-json",
                    "application/marc"
                ]
            );
        }

        ModBiblio( $record, $biblio->id, $frameworkcode );

        $c->render(
            status  => 200,
            openapi => { id => $biblio->id }
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 list

Controller function that handles retrieving a single biblio object

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    my @prefetch = qw(biblioitem);
    push @prefetch, 'metadata'    # don't prefetch metadata if not needed
        unless $c->req->headers->accept =~ m/application\/json/;

    my $rs      = Koha::Biblios->search( undef, { prefetch => \@prefetch } );
    my $biblios = $c->objects->search_rs( $rs, [ ( sub { $rs->api_query_fixer( $_[0], '', $_[1] ) } ) ] );

    return try {

        if ( $c->req->headers->accept =~ m/application\/json(;.*)?$/ ) {
            return $c->render(
                status => 200,
                json   => $c->objects->to_api($biblios),
            );
        } elsif ( $c->req->headers->accept =~ m/application\/marcxml\+xml(;.*)?$/ ) {
            $c->res->headers->add( 'Content-Type', 'application/marcxml+xml' );
            return $c->render(
                status => 200,
                text   => $biblios->print_collection('marcxml')
            );
        } elsif ( $c->req->headers->accept =~ m/application\/marc-in-json(;.*)?$/ ) {
            $c->res->headers->add( 'Content-Type', 'application/marc-in-json' );
            return $c->render(
                status => 200,
                data   => $biblios->print_collection('mij')
            );
        } elsif ( $c->req->headers->accept =~ m/application\/marc(;.*)?$/ ) {
            $c->res->headers->add( 'Content-Type', 'application/marc' );
            return $c->render(
                status => 200,
                text   => $biblios->print_collection('marc')
            );
        } elsif ( $c->req->headers->accept =~ m/text\/plain(;.*)?$/ ) {
            return $c->render(
                status => 200,
                text   => $biblios->print_collection('txt')
            );
        } else {
            return $c->render(
                status  => 406,
                openapi => [
                    "application/json",         "application/marcxml+xml",
                    "application/marc-in-json", "application/marc",
                    "text/plain"
                ]
            );
        }
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 merge

Controller function that handles merging two biblios. If an optional
MARCXML is provided as the request body, this MARCXML replaces the
bibliodata of the merge target biblio. Syntax format inside the request body
must match with the Marc format used into Koha installation (MARC21 or UNIMARC)

=cut

sub merge {
    my $c                = shift->openapi->valid_input or return;
    my $ref_biblionumber = $c->param('biblio_id');
    my $json             = decode_json( $c->req->body );
    my $bn_merge         = $json->{'biblio_id_to_merge'};
    my $framework        = $json->{'framework_to_use'} // q{};
    my $rules            = $json->{'rules'} || q{override};
    my $override_rec     = $json->{'datarecord'} // q{};

    my $biblio = Koha::Biblios->find($ref_biblionumber);
    if ( not defined $biblio ) {
        return $c->render(
            status => 404,
            json   => { error => sprintf( "[%s] biblio to merge into not found", $ref_biblionumber ) }
        );
    }
    my $frombib = Koha::Biblios->find($bn_merge);
    if ( not defined $frombib ) {
        return $c->render(
            status => 404,
            json   => { error => sprintf( "[%s] from which to merge not found", $bn_merge ) }
        );
    }

    if ( ( $rules eq 'override_ext' ) && ( $override_rec eq '' ) ) {
        return $c->render(
            status => 404,
            json   => {
                error =>
                    "With the rule 'override_ext' you need to insert a bib record in marc-in-json format into 'record' field."
            }
        );
    }

    if ( ( $rules eq 'override' ) && ( $framework ne '' ) ) {
        return $c->render(
            status => 404,
            json   => { error => "With the rule 'override' you can not use the field 'framework_to_use'." }
        );
    }

    return try {
        if ( $rules eq 'override_ext' ) {
            my $record = MARC::Record::MiJ->new_from_mij_structure($override_rec);
            $record->encoding('UTF-8');
            $framework ||= $biblio->frameworkcode;
            my $chk = ModBiblio( $record, $ref_biblionumber, $framework );
            if ( $chk != 1 ) { die "Error on ModBiblio"; }    # ModBiblio returns 1 if everything as gone well
        }

        $biblio->merge_with( [$bn_merge] );

        $c->respond_to(
            mij => {
                status => 200,
                format => 'mij',
                data   => $biblio->metadata->record->to_mij
            }
        );
    } catch {
        $c->render( status => 400, json => { error => $@ } );
    };
}

1;
