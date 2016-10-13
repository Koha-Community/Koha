package Koha::AuthorisedValues;

# Copyright ByWater Solutions 2014
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

use Carp;

use Koha::Database;

use Koha::AuthorisedValue;
use Koha::MarcSubfieldStructures;

use base qw(Koha::Objects);

=head1 NAME

Koha::AuthorisedValues - Koha Authorised value Object set class

=head1 API

=head2 Class Methods

=cut

=head3 Koha::AuthorisedValues->search();

my @objects = Koha::AuthorisedValues->search($params);

=cut

sub search {
    my ( $self, $params, $attributes ) = @_;

    my $branchcode = $params->{branchcode};
    delete( $params->{branchcode} );

    my $or =
      $branchcode
      ? {
        '-or' => [
            'authorised_values_branches.branchcode' => undef,
            'authorised_values_branches.branchcode' => $branchcode,
        ]
      }
      : {};
    my $join = $branchcode ? { join => 'authorised_values_branches' } : {};
    $attributes //= {};
    $attributes = { %$attributes, %$join };
    return $self->SUPER::search( { %$params, %$or, }, $attributes );
}

sub search_by_marc_field {
    my ( $self, $params ) = @_;
    my $frameworkcode = $params->{frameworkcode} || '';
    my $tagfield      = $params->{tagfield};
    my $tagsubfield   = $params->{tagsubfield};

    return unless $tagfield or $tagsubfield;

    return $self->SUPER::search(
        {   'marc_subfield_structures.frameworkcode' => $frameworkcode,
            ( defined $tagfield    ? ( 'marc_subfield_structures.tagfield'    => $tagfield )    : () ),
            ( defined $tagsubfield ? ( 'marc_subfield_structures.tagsubfield' => $tagsubfield ) : () ),
        },
        { join => { category => 'marc_subfield_structures' } }
    );
}

sub search_by_koha_field {
    my ( $self, $params ) = @_;
    my $frameworkcode    = $params->{frameworkcode} || '';
    my $kohafield        = $params->{kohafield};
    my $category         = $params->{category};
    my $authorised_value = $params->{authorised_value};

    return unless $kohafield;

    return $self->SUPER::search(
        {   'marc_subfield_structures.frameworkcode' => $frameworkcode,
            'marc_subfield_structures.kohafield'     => $kohafield,
            ( defined $category ? ( category_name    => $category )         : () ),
            ( $authorised_value ? ( authorised_value => $authorised_value ) : () ),
        },
        {   join     => { category => 'marc_subfield_structures' },
            distinct => 1,
        }
    );
}

sub categories {
    my ( $self ) = @_;
    my $rs = $self->_resultset->search(
        undef,
        {
            select => ['category'],
            distinct => 1,
            order_by => 'category',
        },
    );
    return map $_->get_column('category'), $rs->all;
}

=head3 type

=cut

sub _type {
    return 'AuthorisedValue';
}

sub object_class {
    return 'Koha::AuthorisedValue';
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

=cut

1;
