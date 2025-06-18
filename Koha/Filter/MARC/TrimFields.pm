package Koha::Filter::MARC::TrimFields;

# Copyright 2023 Koha Development team

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

Koha::Filter::MARC::TrimFields - Trims MARC::Record object data fields.

=head1 SYNOPSIS

    my $p = Koha::RecordProcessor->new({ filters => ['TrimFields'] });

    my $metadata = Koha::Biblio::Metadatas->find($biblio_id);
    my $record   = $metadata->record;

    $p->process($record);

=head1 DESCRIPTION

Filter to trim MARC::Record object data fields.

=cut

use Modern::Perl;

use base qw(Koha::RecordProcessor::Base);
our $NAME = 'TrimFields';

=head2 filter

Trim MARC::Record object data fields.

=cut

sub filter {
    my ( $self, $record ) = @_;

    return
        unless $record and ref($record) eq 'MARC::Record';

    foreach my $field ( $record->fields ) {
        unless ( $field->is_control_field ) {
            foreach my $subfield ( $field->subfields ) {
                my $key   = $subfield->[0];
                my $value = $subfield->[1];
                $value =~ s/[\n\r]+/ /g;
                $value =~ s/^\s+|\s+$//g;
                $field->add_subfields( $key => $value )
                    if $value ne q{}
                    ; # add subfield to the end of the subfield list, but only if there is still a non empty value there
                $field->delete_subfield( pos => 0 );    # delete the subfield at the top of the subfield list
            }

            # if it happed that all existing subfields had whitespaces only,
            # the field would be empty now and should be removed from the record
            $record->delete_fields($field) unless scalar( $field->subfields );
        }
    }
    return $record;
}

1;
