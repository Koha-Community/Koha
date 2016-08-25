package Koha::BiblioUtils::Iterator;

# This contains an iterator over biblio records

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

Koha::BiblioUtils::Iterator - iterates over biblios provided by a DBIx::Class::ResultSet

=head1 DESCRIPTION

This provides an iterator that gives the MARC::Record of each biblio that's
returned by a L<DBIx::Class::ResultSet> that provides a C<biblionumber>, and
C<marcxml> column from the biblioitems table.

=head1 SYNOPSIS

  use Koha::BiblioUtils::Iterator;
  my $rs = $schema->resultset('biblioitems');
  my $iterator = Koha::BiblioUtils::Iterator->new($rs);
  while (my $record = $iterator->next()) {
      // do something with $record
  }

=head1 METHODS

=cut

use C4::Biblio;    # :( - for EmbedItemsInMarcBiblio

use Carp;
use MARC::Record;
use MARC::File::XML;
use Modern::Perl;

=head2 new

    my $it = new($sth, option => $value, ...);

Takes a ResultSet to iterate over, and gives you an iterator on it. Optional
options may be specified.

=head3 Options

=over 4

=item items

Set to true to include item data in the resulting MARC record.

=back

=cut

sub new {
    my ( $class, $rs, %options ) = @_;

    bless {
        rs => $rs,
        %options,
    }, $class;
}

=head2 next()

In a scalar context, provides the next MARC::Record from the ResultSet, or
C<undef> if there are no more.

In a list context it will provide ($biblionumber, $record).

=cut

sub next {
    my ($self) = @_;

    my $marc;
    my $row = $self->{rs}->next();
    return if !$row;
    if ( $row->marcxml ) {
        $marc = MARC::Record->new_from_xml( $row->marcxml );
    }
    else {
        confess "No marcxml column returned in the request.";
    }

    my $bibnum;
    if ( $self->{items} ) {
        $bibnum = $row->get_column('biblionumber');
        confess "No biblionumber column returned in the request."
          if ( !defined($bibnum) );

        # TODO this should really be in Koha::BiblioUtils or something similar.
        C4::Biblio::EmbedItemsInMarcBiblio( $marc, $bibnum );
    }

    if (wantarray) {
        $bibnum //= $row->get_column('biblionumber');
        confess "No biblionumber column returned in the request."
          if ( !defined($bibnum) );
        return ( $bibnum, $marc );
    }
    else {
        return $marc;
    }
}

1;
