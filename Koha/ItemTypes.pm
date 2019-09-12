package Koha::ItemTypes;

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

use Carp;

use C4::Languages;

use Koha::Database;
use Koha::ItemType;

use base qw(Koha::Objects);

=head1 NAME

Koha::ItemTypes - Koha ItemType Object set class

=head1 API

=head2 Class Methods

=cut

=head3 search_with_localization

my $itemtypes = Koha::ItemTypes->search_with_localization

=cut

sub search_with_localization {
    my ( $self, $params, $attributes ) = @_;

    my $language = C4::Languages::getlanguage();
    $Koha::Schema::Result::Itemtype::LANGUAGE = $language;
    $attributes->{order_by} = 'translated_description' unless exists $attributes->{order_by};
    $attributes->{join} = 'localization';
    $attributes->{'+select'} = [
        {
            coalesce => [qw( localization.translation me.description )],
            -as      => 'translated_description'
        }
    ];
    if(defined $params->{branchcode}) {
        $self->search_with_library_limits( $params, $attributes );
    } else {
        $self->SUPER::search( $params, $attributes );
    }
}

=head3 search_with_library_limits

search itemtypes by library

my @itemtypes = Koha::ItemTypes->search_with_library_limits({branchcode => branchcode});

=cut

sub search_with_library_limits {
    my ( $self, $params, $attributes ) = @_;

    my $branchcode = $params->{branchcode};
    delete( $params->{branchcode} );

    return $self->SUPER::search( $params, $attributes ) unless $branchcode;

    my $where = {
        '-or' => [
            'itemtypes_branches.branchcode' => undef,
            'itemtypes_branches.branchcode' => $branchcode
        ]
    };

    $attributes //= {};
    if(exists $attributes->{join}) {
        if(ref $attributes->{join} eq 'ARRAY') {
            push @{$attributes->{join}}, 'itemtypes_branches';
        } else {
            $attributes->{join} = [ $attributes->{join}, 'itemtypes_branches' ];
        }
    } else {
        $attributes->{join} = 'itemtypes_branches';
    }

    return $self->SUPER::search( { %$params, %$where, }, $attributes );
}

=head3 type

=cut

sub _type {
    return 'Itemtype';
}

=head3 object_class

=cut

sub object_class {
    return 'Koha::ItemType';
}

1;
