package Koha::Patron::Attributes;

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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Koha::Patron::Attribute;
use Koha::Patron::Attribute::Types;

use base qw(Koha::Objects);

=head1 NAME

Koha::Patron::Attributes - Koha Patron Attributes Object set class

=head1 API

=head2 Class Methods

=cut

=head3 search

my $attributes = Koha::Patron::Attributes->search( $params );

=cut

sub search {
    my ( $self, $params, $attributes ) = @_;

    unless ( exists $attributes->{order_by} ) { $attributes->{order_by} = [ 'me.code', 'attribute' ] }

    return $self->SUPER::search( $params, $attributes );
}

=head3 filter_by_branch_limitations

my $attributes = Koha::Patron::Attributes->filter_by_branch_limitations([$branchcode]);

Search patron attributes filtered by a library

If $branchcode exists it will be used to filter the result set.

Otherwise it will be the library of the logged in user.

=cut

sub filter_by_branch_limitations {
    my ( $self, $branchcode ) = @_;

    # Maybe we should not limit if logged in user is superlibrarian?
    my $branch_limit = $branchcode
        ? $branchcode

        # Do we raise an exception if no userenv defined?
        : C4::Context->userenv ? C4::Context->userenv->{"branch"}
        :                        undef;

    my $or = $branch_limit
        ? {
        '-or' => [
            'borrower_attribute_types_branches.b_branchcode' => undef,
            'borrower_attribute_types_branches.b_branchcode' => $branch_limit,
        ]
        }
        : {};

    my $join = $branch_limit
        ? {
        join => { code => 'borrower_attribute_types_branches' },
        }
        : {};
    return $self->search( $or, $join );
}

=head3 merge_and_replace_with

$new_attributes is an arrayref of hashrefs

=cut

sub merge_and_replace_with {
    my ( $self, $new_attributes ) = @_;

    my @existing_attributes = @{ $self->unblessed };
    my $attribute_types     = { map { $_->code => $_->unblessed } Koha::Patron::Attribute::Types->search->as_list };
    my @new_attributes;
    for my $attr (@$new_attributes) {

        my $attribute_type = $attribute_types->{ $attr->{code} };

        Koha::Exceptions::Patron::Attribute::InvalidType->throw( type => $attr->{code} )
            unless $attribute_types->{ $attr->{code} };

        unless ( $attribute_type->{repeatable} ) {

            # filter out any existing attributes of the same code
            @existing_attributes = grep { $attr->{code} ne $_->{code} } @existing_attributes;
        }

        push @new_attributes, $attr;
    }

    my @merged = map { { code => $_->{code}, attribute => $_->{attribute} } } ( @existing_attributes, @new_attributes );

    # WARNING - we would like to return a set, but $new_attributes is not in storage yet
    # Maybe there is something obvious I (JD) am missing
    return [ sort { $a->{code} cmp $b->{code} || $a->{attribute} cmp $b->{attribute} } @merged ];
}

=head3 _type

=cut

sub _type {
    return 'BorrowerAttribute';
}

=head2 object_class

Missing POD for object_class.

=cut

sub object_class {
    return 'Koha::Patron::Attribute';
}

1;
