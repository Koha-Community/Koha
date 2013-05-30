package Koha::MetadataRecord;

# Copyright 2013 C & P Bibliography Services
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

Koha::MetadataRecord - base class for metadata records

=head1 SYNOPSIS

    my $record = new Koha::MetadataRecord({ 'record' => $marcrecord });

=head1 DESCRIPTION

Object-oriented class that encapsulates all metadata (i.e. bibliographic
and authority) records in Koha.

=cut

use strict;
use warnings;
use C4::Context;
use Koha::Util::MARC;

use base qw(Class::Accessor);

__PACKAGE__->mk_accessors(qw( record schema ));


=head2 createMergeHash

Create a hash for use when merging records. At the moment the only
metadata schema supported is MARC.

=cut

sub createMergeHash {
    my ($self, $tagslib) = @_;
    if ($self->schema =~ m/marc/) {
        return Koha::Util::MARC::createMergeHash($self->record, $tagslib);
    }
}

1;
