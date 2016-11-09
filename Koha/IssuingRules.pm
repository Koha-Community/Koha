package Koha::IssuingRules;

# Copyright Vaara-kirjastot 2015
# Copyright Koha Development Team 2016
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

use Koha::Database;

use Koha::IssuingRule;

use base qw(Koha::Objects);

=head1 NAME

Koha::IssuingRules - Koha IssuingRule Object set class

=head1 API

=head2 Class Methods

=cut

sub get_effective_issuing_rule {
    my ( $self, $params ) = @_;

    my $default      = '*';
    my $categorycode = $params->{categorycode};
    my $itemtype     = $params->{itemtype};
    my $branchcode   = $params->{branchcode};

    my $rule = $self->find($params);
    return $rule if $rule;

    $rule = $self->find(
        {
            categorycode => $categorycode,
            itemtype     => $default,
            branchcode   => $branchcode
        }
    );
    return $rule if $rule;

    $rule = $self->find(
        {
            categorycode => $default,
            itemtype     => $itemtype,
            branchcode   => $branchcode
        }
    );
    return $rule if $rule;

    $rule = $self->find(
        {
            categorycode => $default,
            itemtype     => $default,
            branchcode   => $branchcode
        }
    );
    return $rule if $rule;

    $rule = $self->find(
        {
            categorycode => $categorycode,
            itemtype     => $itemtype,
            branchcode   => $default
        }
    );
    return $rule if $rule;

    $rule = $self->find(
        {
            categorycode => $categorycode,
            itemtype     => $default,
            branchcode   => $default
        }
    );
    return $rule if $rule;

    $rule = $self->find(
        {
            categorycode => $default,
            itemtype     => $itemtype,
            branchcode   => $default
        }
    );
    return $rule if $rule;

    $rule = $self->find(
        {
            categorycode => $default,
            itemtype     => $default,
            branchcode   => $default
        }
    );
    return $rule if $rule;

    return;
}

=head3 type

=cut

sub _type {
    return 'Issuingrule';
}

sub object_class {
    return 'Koha::IssuingRule';
}

1;
