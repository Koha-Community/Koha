package Koha::Util::MARC;

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

use Modern::Perl;
use MARC::Record;

=head1 NAME

Koha::Util::MARC - utility class with routines for working with MARC records

=head1 METHODS

=head2 createMergeHash

Create a hash to use when merging MARC records

=cut

sub createMergeHash {
    my ( $record, $tagslib ) = @_;

    return unless $record;

    my @array;
    my @fields = $record->fields();

    foreach my $field (@fields) {
        my $fieldtag = $field->tag();
        if ( $fieldtag < 10 ) {
            if ( !defined($tagslib)
                || $tagslib->{$fieldtag}->{'@'}->{'tab'} >= 0 )
            {
                push @array,
                  {
                    field => [
                        {
                            tag   => $fieldtag,
                            key   => _createKey(),
                            value => $field->data(),
                        }
                    ]
                  };
            }
        }
        else {
            my @subfields = $field->subfields();
            my @subfield_array;
            foreach my $subfield (@subfields) {
                if ( !defined($tagslib)
                    || $tagslib->{$fieldtag}->{ @$subfield[0] }->{'tab'} >= 0 )
                {
                    push @subfield_array,
                      {
                        subtag => @$subfield[0],
                        subkey => _createKey(),
                        value  => @$subfield[1],
                      };
                }

            }

            if ( ( !defined($tagslib) || $tagslib->{$fieldtag}->{'tab'} >= 0 )
                && @subfield_array )
            {
                push @array,
                  {
                    field => [
                        {
                            tag        => $fieldtag,
                            key        => _createKey(),
                            indicator1 => $field->indicator(1),
                            indicator2 => $field->indicator(2),
                            subfield   => [@subfield_array],
                        }
                    ]
                  };
            }

        }
    }
    return [@array];
}

=head2 _createKey

Create a random value to set it into the input name

=cut

sub _createKey {
    return int(rand(1000000));
}

1;
