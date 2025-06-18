package Koha::BiblioUtils;

# This contains functions to do with managing biblio records.

# Copyright 2014 Catalyst IT
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

=head1 NAME

Koha::BiblioUtils - contains fundamental biblio-related functions

=head1 DESCRIPTION

This contains functions for normal operations on biblio records.

=cut

use Koha::Biblios;
use Koha::MetadataIterator;
use Koha::Database;
use Modern::Perl;

use base qw(Koha::MetadataRecord);

__PACKAGE__->mk_accessors(qw( record schema id datatype ));

=head1 FUNCTIONS

=head2 new

    my $biblio = Koha::BiblioUtils->new($marc_record, [$biblionumber]);

Creates an instance of C<Koha::BiblioUtils> based on the marc record. If known,
the biblionumber can be provided too.

=cut

sub new {
    my $class        = shift;
    my $record       = shift;
    my $biblionumber = shift;

    my $self = $class->SUPER::new(
        {
            'record'   => $record,
            'schema'   => lc C4::Context->preference("marcflavour"),
            'id'       => $biblionumber,
            'datatype' => 'biblio',
        }
    );
    bless $self, $class;
    return $self;
}

=head2 get_from_biblionumber

    my $biblio = Koha::BiblioUtils->get_from_biblionumber($biblionumber, %options);

This will give you an instance of L<Koha::BiblioUtils> that is the biblio that
you requested.

Options are:

=over 4

=item C<$item_data>

If true, then the item data will be merged into the record when it's loaded.

=back

It will return C<undef> if the biblio doesn't exist.

=cut

sub get_from_biblionumber {
    my ( $class, $bibnum, %options ) = @_;

    my $marc = $class->get_marc_biblio( $bibnum, %options );
    return $class->new( $marc, $bibnum );
}

=head2 get_all_biblios_iterator

    my $it = Koha::BiblioUtils->get_all_biblios_iterator(%options);

This will provide an iterator object that will, one by one, provide the
Koha::BiblioUtils of each biblio. This will include the item data.

The iterator is a Koha::MetadataIterator object.

Possible options are:

=over 4

=item C<slice>

slice may be defined as a hash of two values: index and count. index
is the slice number to process and count is total number of slices.
With this information the iterator returns just the given slice of
records instead of all.

=back

=cut

sub get_all_biblios_iterator {
    my ( $class, %options ) = @_;

    my $search_terms = {};
    my ( $slice_modulo, $slice_count );
    if ( $options{slice} ) {
        $slice_count  = $options{slice}->{count};
        $slice_modulo = $options{slice}->{index};
        $search_terms = \[ 'mod(biblionumber, ?) = ?', $slice_count, $slice_modulo ];
    }

    my $search_options = { columns => [qw/ biblionumber /] };
    if ( $options{desc} ) {
        $search_options->{order_by} = { -desc => 'biblionumber' };
    }

    my $database = Koha::Database->new();
    my $schema   = $database->schema();
    my $rs       = Koha::Biblios->search(
        $search_terms,
        $search_options
    );

    if ( my $sql = $options{where} ) {
        $rs = $rs->search( \[$sql] );
    }

    my $next_func = sub {

        # Warn and skip bad records, otherwise we break the loop
        while (1) {
            my $row = $rs->next();
            return if !$row;
            my $next = eval {
                my $marc = $row->metadata_record( { embed_items => 1 } );
                $class->new( $marc, $row->biblionumber );
            };
            if ($@) {
                warn sprintf "Something went wrong reading record for biblio %s: %s\n", $row->biblionumber, $@;
                next;
            }
            return $next;
        }
    };
    return Koha::MetadataIterator->new($next_func);
}

=head2 get_marc_biblio

    my $marc = Koha::BiblioUtils->get_marc_biblio($bibnum, %options);

This non-class function fetches the MARC::Record for the given biblio number.
Nothing is returned if the biblionumber couldn't be found (or it somehow has no
MARC data.)

Options are:

=over 4

=item item_data

If set to true, item data is embedded in the record. Default is to not do this.

=back

=cut

sub get_marc_biblio {
    my ( $class, $bibnum, %options ) = @_;

    my $record = Koha::Biblios->find($bibnum)->metadata_record( { $options{item_data} ? ( embed_items => 1 ) : () } );
    return $record;
}

1;
