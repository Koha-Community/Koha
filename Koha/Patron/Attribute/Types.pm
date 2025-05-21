package Koha::Patron::Attribute::Types;

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

use Koha::Patron::Attribute::Type;
use C4::Koha qw( GetAuthorisedValues );

use base qw(Koha::Objects Koha::Objects::Limit::Library);

=head1 NAME

Koha::Patron::Attribute::Types Object set class

=head1 API

=head2 Class Methods

=cut

=head3 patron_attributes_form

    $patron_attributes_form = Koha::Patron::Attribute::Types::patron_attributes_form($template, $attributes, $op);

Static method that prepares and populates the template with patron attribute types for rendering in a form. It organizes the attributes into a structure based on their class and type, taking into account repeatable and mandatory attributes, as well as those with authorized value categories. It also handles library-specific attribute type limitations and sets relevant template parameters for display.

Params:
    $template   - The template object to be populated with patron attributes.
    $attributes - Arrayref of hashrefs containing patron attribute data.
    $op         - Operation type, such as 'duplicate', used to handle unique attributes.

=cut

sub patron_attributes_form {
    my $template   = shift;
    my $attributes = shift;
    my $op         = shift;

    my $library_id      = C4::Context->userenv ? C4::Context->userenv->{'branch'} : undef;
    my $attribute_types = Koha::Patron::Attribute::Types->search_with_library_limits( {}, {}, $library_id );
    if ( $attribute_types->count == 0 ) {
        $template->param( no_patron_attribute_types => 1 );
        return;
    }

    # map patron's attributes into a more convenient structure
    my %attr_hash = ();
    foreach my $attr (@$attributes) {
        push @{ $attr_hash{ $attr->{code} } }, $attr;
    }

    my @attribute_loop = ();
    my $i              = 0;
    my %items_by_class;
    while ( my ($attr_type) = $attribute_types->next ) {
        my $entry = {
            class         => $attr_type->class(),
            code          => $attr_type->code(),
            description   => $attr_type->description(),
            repeatable    => $attr_type->repeatable(),
            category      => $attr_type->authorised_value_category(),
            category_code => $attr_type->category_code(),
            mandatory     => $attr_type->mandatory(),
            is_date       => $attr_type->is_date(),
        };
        if ( exists $attr_hash{ $attr_type->code() } ) {
            foreach my $attr ( @{ $attr_hash{ $attr_type->code() } } ) {
                my $newentry = {%$entry};
                $newentry->{value}        = $attr->{attribute};
                $newentry->{use_dropdown} = 0;
                if ( $attr_type->authorised_value_category() ) {
                    $newentry->{use_dropdown} = 1;
                    $newentry->{auth_val_loop} =
                        C4::Koha::GetAuthorisedValues( $attr_type->authorised_value_category(), $attr->{attribute} );
                }
                $i++;
                undef $newentry->{value} if ( $attr_type->unique_id() && $op eq 'duplicate' );
                $newentry->{form_id} = "patron_attr_$i";
                push @{ $items_by_class{ $attr_type->class() } }, $newentry;
            }
        } else {
            $i++;
            my $newentry = {%$entry};
            if ( $attr_type->authorised_value_category() ) {
                $newentry->{use_dropdown}  = 1;
                $newentry->{auth_val_loop} = C4::Koha::GetAuthorisedValues( $attr_type->authorised_value_category() );
            }
            $newentry->{form_id} = "patron_attr_$i";
            push @{ $items_by_class{ $attr_type->class() } }, $newentry;
        }
    }
    for my $class ( sort keys %items_by_class ) {
        my $av  = Koha::AuthorisedValues->search( { category => 'PA_CLASS', authorised_value => $class } );
        my $lib = $av->count ? $av->next->lib : $class;
        push @attribute_loop, {
            class => $class,
            items => $items_by_class{$class},
            lib   => $lib,
        };
    }

    $template->param( patron_attributes => \@attribute_loop );

}

=head2 Internal methods

=cut

=head3 _type

=cut

sub _type {
    return 'BorrowerAttributeType';
}

=head2 object_class

Missing POD for object_class.

=cut

sub object_class {
    return 'Koha::Patron::Attribute::Type';
}

1;
