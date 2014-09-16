package Koha::BiblioUtils;

# This contains functions to do with managing biblio records.

# Copyright 2014 Catalyst IT
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

=head1 NAME

Koha::BiblioUtils - contains some handy biblio-related functions

=head1 DESCRIPTION

This contains functions for operations on biblio records.

Note: really, C4::Biblio does the main functions, but the Koha namespace is
the new thing that should be used.

=cut

use C4::Biblio; # EmbedItemsInMarcBiblio
use Koha::Biblio::Iterator;
use Koha::Database;
use Modern::Perl;

use base qw(Class::Accessor);

__PACKAGE__->mk_accessors(qw());

=head1 FUNCTIONS

=head2 get_all_biblios_iterator

    my $it = get_all_biblios_iterator();

This will provide an iterator object that will, one by one, provide the
MARC::Record of each biblio. This will include the item data.

The iterator is a Koha::Biblio::Iterator object.

=cut

sub get_all_biblios_iterator {
    my $database = Koha::Database->new();
    my $schema   = $database->schema();
    my $rs =
      $schema->resultset('Biblioitem')->search( { marc => { '!=', undef } },
        { columns => [qw/ biblionumber marc /] } );
    return Koha::Biblio::Iterator->new($rs, items => 1);
}

=head2 get_marc_biblio

    my $marc = get_marc_biblio($bibnum, %options);

This fetches the MARC::Record for the given biblio number. Nothing is returned
if the biblionumber couldn't be found (or it somehow has no MARC data.)

Options are:

=over 4

=item item_data

If set to true, item data is embedded in the record. Default is to not do this.

=back

=cut

sub get_marc_biblio {
    my ($class,$bibnum, %options) = @_;

    my $database = Koha::Database->new();
    my $schema   = $database->schema();
    my $rs =
      $schema->resultset('Biblioitem')
      ->search( { marc => { '!=', undef }, biblionumber => $bibnum },
        { columns => [qw/ marc /] } );

    my $row = $rs->next();
    return unless $row;
    my $marc = MARC::Record->new_from_usmarc($row->marc);

    # TODO implement this in this module
    C4::Biblio::EmbedItemsInMarcBiblio($marc, $bibnum) if $options{item_data};

    return $marc;
}

1;
