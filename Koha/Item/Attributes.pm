package Koha::Item::Attributes;

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
use MARC::Record;
use MARC::Field;
use List::MoreUtils qw( uniq );

use C4::Biblio;
use C4::Charset qw( StripNonXmlChars );

=head1 NAME

Koha::Item::Attributes - Class to represent the additional attributes of items.

Additional attributes are 'more subfields xml'

=head1 API

=head2 Class methods

=cut

=head3 new_from_marcxml

    my $attributes = Koha::Item::Attributes->new_from_marcxml( $item->more_subfield_xml );

Constructor that takes a MARCXML.

=cut

# FIXME maybe this needs to care about repeatable but don't from batchMod - To implement later?
sub new_from_marcxml {
    my ( $class, $more_subfields_xml ) = @_;

    my $self = {};
    if ($more_subfields_xml) {

        # FIXME MARC::Record->new_from_xml (vs MARC::Record::new_from_xml) does not return the correctly encoded subfield code (??)
        my $marc_more = MARC::Record::new_from_xml( C4::Charset::StripNonXmlChars($more_subfields_xml), 'UTF-8' );

        # use of tag 999 is arbitrary, and doesn't need to match the item tag
        # used in the framework
        my $field          = $marc_more->field('999');
        my $more_subfields = [ uniq map { $_->[0] } $field->subfields ];
        for my $more_subfield (@$more_subfields) {
            my @s = $field->subfield($more_subfield);
            $self->{$more_subfield} = join ' | ', @s;
        }
    }
    return bless $self, $class;
}

=head3 new

Constructor

=cut

# FIXME maybe this needs to care about repeatable but don't from batchMod - To implement later?
sub new {
    my ( $class, $attributes ) = @_;

    my $self = $attributes;
    return bless $self, $class;
}

=head3 to_marcxml

    $attributes->to_marcxml;

    $item->more_subfields_xml( $attributes->to_marcxml );

Return the MARCXML representation of the attributes.

=cut

sub to_marcxml {
    my ( $self, $frameworkcode ) = @_;

    return unless keys %$self;

    my $tagslib = C4::Biblio::GetMarcStructure( 1, $frameworkcode, { unsafe => 1 } );

    my ( $itemtag, $itemtagsubfield ) = C4::Biblio::GetMarcFromKohaField("items.itemnumber");
    my @subfields;
    for my $tagsubfield (
        sort {
                   $tagslib->{$itemtag}->{$a}->{display_order} <=> $tagslib->{$itemtag}->{$b}->{display_order}
                || $tagslib->{$itemtag}->{$a}->{subfield} cmp $tagslib->{$itemtag}->{$b}->{subfield}
        } keys %$self
        )
    {
        next
            if not defined $self->{$tagsubfield}
            or $self->{$tagsubfield} eq "";

        if ( $tagslib->{$itemtag}->{$tagsubfield}->{repeatable} ) {
            my @values = split ' \| ', $self->{$tagsubfield};
            push @subfields, ( $tagsubfield => $_ ) for @values;
        } else {
            push @subfields, ( $tagsubfield => $self->{$tagsubfield} );
        }
    }

    return unless @subfields;

    my $marc_more = MARC::Record->new();

    # use of tag 999 is arbitrary, and doesn't need to match the item tag
    # used in the framework
    $marc_more->append_fields( MARC::Field->new( '999', ' ', ' ', @subfields ) );
    $marc_more->encoding("UTF-8");
    return $marc_more->as_xml("USMARC");
}

=head3 to_hashref

    $attributes->to_hashref;

Returns the hashref representation of the attributes.

=cut

sub to_hashref {
    my ($self) = @_;
    return { map { $_ => $self->{$_} } keys %$self };
}

1;
