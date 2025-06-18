package Koha::SearchEngine::Zebra::Indexer;

# Copyright 2020 ByWater Solutions
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

use Modern::Perl;
use C4::Biblio qw( ModZebra );        # FIXME This is terrible, we should move the indexation code outside of C4::Biblio
use base       qw(Class::Accessor);

=head1 NAME

Koha::SearchEngine::Elasticsearch::Indexer - handles adding new records to the index

=head1 SYNOPSIS

    my $indexer = Koha::SearchEngine::Zebra::Indexer->new();
    $indexer->index_records( $record_numbers, $op, $server, $records);


=head1 FUNCTIONS

=head2 new

    This is a dummy function to create the object. C4::Biblio->ModZebra is doing the real work
    now and needed variables are passed to index_records

=cut

sub new {
    my $class = shift @_;
    my $self  = $class->SUPER::new(@_);
}

=head2 index_records($record_numbers, $op, $server, $records)

    This is simply a wrapper to C4::Biblio::ModZebra that takes an array of records and
    passes them through individually

    The final parameter $records is not used in Zebra, it exists for parity with Elasticsearch calls

=cut

sub index_records {
    my ( $self, $record_numbers, $op, $server, $records ) = @_;
    $record_numbers = [$record_numbers] if ref $record_numbers ne 'ARRAY' && defined $record_numbers;
    foreach my $record_number (@$record_numbers) {
        ModZebra( $record_number, $op, $server );
    }
}

1;
