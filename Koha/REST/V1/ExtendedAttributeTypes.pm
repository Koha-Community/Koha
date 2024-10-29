package Koha::REST::V1::ExtendedAttributeTypes;

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

# IMPORTANT NOTE
#
# Whilst this class is named ExtendedAttributeTypes, it currently
# allows for querying the Koha::AdditionalFields objects only.
#
# The longer term goal is to merge the additional fields, patron
# attributes and ill request attributes features into one system.

use Modern::Perl;

use Mojo::Base 'Mojolicious::Controller';

use Koha::AdditionalFields;

use Try::Tiny qw( catch try );

=head1 API

=head2 Methods

=head3 _list

=cut

sub _list {
    my ( $self, @resource_types ) = @_;

    # FIXME: Maybe not the best place for this mapping
    my $resource_to_table = {
        basket    => 'aqbasket',
        credit    => 'accountlines:credit',
        debit     => 'accountlines:debit',
        invoice   => 'aqinvoices',
        license   => 'erm_licenses',
        agreement => 'erm_agreements',
        package   => 'erm_packages',
        order     => 'aqorders',
        vendor    => 'aqbooksellers:vendor',
    };

    my @tables;
    for my $resource_type (@resource_types) {
        if ( $resource_type && $resource_to_table->{$resource_type} ) {
            push @tables, $resource_to_table->{$resource_type};
        } elsif ($resource_type) {
            push @tables, $resource_type;
        }
    }
    return Koha::AdditionalFields->new->search( ( @tables ? { tablename => \@tables } : () ) );
}

=head3 list

List all additional fields, can be filtered using the resource_type parameter.

=cut

sub list {
    my ($self) = @_;

    my $c = $self->openapi->valid_input or return;

    my $resource_type = $c->param('resource_type');

    return try {
        my $additional_fields_set = $self->_list($resource_type);
        return $c->render(
            status  => 200,
            openapi => $c->objects->search($additional_fields_set)
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 list_erm

List the ERM-related additional fields, can be filtered using the resource_type parameter.

=cut

sub list_erm {
    my ($self)         = @_;
    my $c              = shift->openapi->valid_input or return;
    my @resource_types = qw(erm_licenses erm_agreements erm_packages);

    return try {
        my $additional_fields_set = $self->_list(@resource_types);
        return $c->render(
            status  => 200,
            openapi => $c->objects->search($additional_fields_set)
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

1;
