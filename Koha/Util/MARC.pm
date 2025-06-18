package Koha::Util::MARC;

# Copyright 2013 C & P Bibliography Services
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

use constant OCLC_REGEX => qr/OCoLC/i;    # made it case insensitive, includes the various oclc suffixes too

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
            if (
                !defined($tagslib)
                || ( defined( $tagslib->{$fieldtag} )
                    && $tagslib->{$fieldtag}->{'@'}->{'tab'} >= 0 )
                )
            {
                push @array, {
                    tag   => $fieldtag,
                    key   => _createKey(),
                    value => $field->data(),
                };
            }
        } else {
            my @subfields = $field->subfields();
            my @subfield_array;
            foreach my $subfield (@subfields) {
                if (
                    !defined($tagslib)
                    || (   defined $tagslib->{$fieldtag}
                        && defined $tagslib->{$fieldtag}->{ @$subfield[0] }
                        && defined $tagslib->{$fieldtag}->{ @$subfield[0] }->{'tab'}
                        && $tagslib->{$fieldtag}->{ @$subfield[0] }->{'tab'} >= 0 )
                    )
                {
                    push @subfield_array, {
                        subtag => @$subfield[0],
                        subkey => _createKey(),
                        value  => @$subfield[1],
                    };
                }

            }

            if (
                (
                    !defined($tagslib) || ( defined $tagslib->{$fieldtag}
                        && defined $tagslib->{$fieldtag}->{'tab'}
                        && ( $tagslib->{$fieldtag}->{'tab'} ? $tagslib->{$fieldtag}->{'tab'} : 0 ) >= 0 )
                )
                && @subfield_array
                )
            {
                push @array, {
                    tag        => $fieldtag,
                    key        => _createKey(),
                    indicator1 => $field->indicator(1),
                    indicator2 => $field->indicator(2),
                    subfield   => [@subfield_array],
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
    return int( rand(1000000) );
}

=head2 getAuthorityAuthorizedHeading

Retrieve the authorized heading from a MARC authority record

=cut

sub getAuthorityAuthorizedHeading {
    my ( $record, $schema ) = @_;
    return unless ( ref $record eq 'MARC::Record' );
    if ( $schema eq 'unimarc' ) {

        # construct UNIMARC summary, that is quite different from MARC21 one
        # accepted form
        foreach my $field ( $record->field('2..') ) {
            return $field->as_string('abcdefghijlmnopqrstuvwxyz');
        }
    } else {
        foreach my $field ( $record->field('1..') ) {
            my $tag = $field->tag();
            next if "152" eq $tag;

            # FIXME - 152 is not a good tag to use
            # in MARC21 -- purely local tags really ought to be
            # 9XX
            if ( $tag eq '100' ) {
                return $field->as_string('abcdefghjklmnopqrstvxyz68');
            } elsif ( $tag eq '110' ) {
                return $field->as_string('abcdefghklmnoprstvxyz68');
            } elsif ( $tag eq '111' ) {
                return $field->as_string('acdefghklnpqstvxyz68');
            } elsif ( $tag eq '130' ) {
                return $field->as_string('adfghklmnoprstvxyz68');
            } elsif ( $tag eq '148' ) {
                return $field->as_string('abvxyz68');
            } elsif ( $tag eq '150' ) {
                return $field->as_string('abvxyz68');
            } elsif ( $tag eq '151' ) {
                return $field->as_string('avxyz68');
            } elsif ( $tag eq '155' ) {
                return $field->as_string('abvxyz68');
            } elsif ( $tag eq '180' ) {
                return $field->as_string('vxyz68');
            } elsif ( $tag eq '181' ) {
                return $field->as_string('vxyz68');
            } elsif ( $tag eq '182' ) {
                return $field->as_string('vxyz68');
            } elsif ( $tag eq '185' ) {
                return $field->as_string('vxyz68');
            } else {
                return $field->as_string();
            }
        }
    }
    return;
}

=head2 set_marc_field

    set_marc_field($record, $marcField, $value);

Set the value of $marcField to $value in $record. If the field exists, it will
be updated. If not, it will be created.

=head3 Parameters

=over 4

=item C<$record>

MARC::Record object

=item C<$marcField>

the MARC field to modify, a string in the form of 'XXX$y'

=item C<$value>

the value

=back

=cut

sub set_marc_field {
    my ( $record, $marcField, $value ) = @_;

    if ($marcField) {
        my ( $fieldTag, $subfieldCode ) = split /\$/, $marcField;
        if ( !$subfieldCode ) {
            warn "set_marc_field: Invalid marcField format: $marcField\n";
            return;
        }
        my $field = $record->field($fieldTag);
        if ($field) {
            $field->update( $subfieldCode => $value );
        } else {
            $field = MARC::Field->new(
                $fieldTag, ' ', ' ',
                $subfieldCode => $value
            );
            $record->append_fields($field);
        }
    }
}

=head2 find_marc_info

    my $first = find_marc_info({ record => $marc, field => $field, subfield => $subfield, match => qr/regex/ });
    my @found = find_marc_info({ record => $marc, field => $field, subfield => $subfield, match => qr/regex/ });

    Returns first or all occurrences of field/subfield in record where regex matches.
    Subfield is not used for control fields.
    Match is optional.

=cut

sub find_marc_info {
    my ($params) = @_;
    my $record   = $params->{record} or return;
    my $field    = $params->{field}  or return;
    my $subfield = $params->{subfield};
    my $match    = $params->{match};

    my @rv;
    foreach my $f ( $record->field($field) ) {
        if ( $f->is_control_field ) {
            push @rv, $f->data if !$match || $f->data =~ /$match/;
            last if @rv && !wantarray;
        } else {
            foreach my $sub ( $f->subfield($subfield) ) {
                push @rv, $sub if !$match || $sub =~ /$match/;
                last if @rv && !wantarray;
            }
        }
    }
    return @rv    if wantarray;
    return $rv[0] if @rv;
}

=head2 strip_orgcode

    my $id = strip_orgcode( '(code) 123' ); # returns '123'

    Strips from starting left paren to first right paren and trailing whitespace.

=cut

sub strip_orgcode {
    my $arg = shift;
    $arg =~ s/^\([^)]*\)\s*// if $arg;
    return $arg;
}

=head2 oclc_number

    my $id = oclc_number( $record );

    Based on applying strip_orgcode on first occurrence of find_marc_info
    with orgcode matching regex in 035$a.

=cut;

sub oclc_number {
    my $record = shift;
    return strip_orgcode(
        scalar find_marc_info(
            {
                # Note: Field 035 same for MARC21 and UNIMARC
                record => $record, field => '035', subfield => 'a', match => OCLC_REGEX,
            }
        )
    );
}

1;
