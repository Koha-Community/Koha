package Koha::Exceptions::MarcMergeRule;

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

use Exception::Class (

    'Koha::Exceptions::MarcMergeRule' => {
        description => 'Something went wrong!',
    },
    'Koha::Exceptions::MarcMergeRule::InvalidTagRegExp' => {
        isa => 'Koha::Exceptions::MarcMergeRule',
        description => 'Invalid regular expression for tag'
    },
    'Koha::Exceptions::MarcMergeRule::InvalidControlFieldActions' => {
        isa => 'Koha::Exceptions::MarcMergeRule',
        description => 'Invalid control field actions'
    }
);

=head1 NAME

Koha::Exceptions::MarcMergeRule - Base class for MarcMergeRule exceptions

=head1 Exceptions

=head2 Koha::Exceptions::MarcMergeRule

Generic MarcMergeRule exception

=head2 Koha::Exceptions::MarcMergeRule::InvalidTagRegExp

Exception for rule validation when rule tag is an invalid regular expression

=head2 Koha::Exceptions::MarcMergeRule::InvalidControlFieldActions

Exception for rule validation for control field rules with invalid combination of actions

=cut

1;
