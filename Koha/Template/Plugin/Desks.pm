package Koha::Template::Plugin::Desks;

# Copyright (C) BULAC 2020

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

use Template::Plugin;
use base qw( Template::Plugin );

use C4::Context;
use Koha::Desks;

=head1 NAME

Koha::Template::Plugin::Desks - A module for dealing with desks in templates

=head1 DESCRIPTION

This plugin contains getters functions, to fetch all desks a library
got or the current one.

=head2 Methods

=head3 GetLoggedInDeskId

[% Desks.GetLoggedInDeskId %]

return the desk name that is attached to the session or empty string

=cut

sub GetLoggedInDeskId {
    my ($self) = @_;

    return C4::Context->userenv
        ? C4::Context->userenv->{'desk_id'}
        : '';
}

=head3 GetLoggedInDeskName

[% Desks.GetLoggedInDeskName %]

Return the desk name that is attached to the session or empty string

=cut

sub GetLoggedInDeskName {
    my ($self) = @_;

    return C4::Context->userenv
        ? C4::Context->userenv->{'desk_name'}
        : '';
}

=head3 ListForLibrary

[% Desks.ListForLibrary %]

returns all desks existing at the current library

=cut

sub ListForLibrary {
    my ($self) = @_;
    my $branch_limit = C4::Context->userenv ? C4::Context->userenv->{"branch"} : "";
    return Koha::Desks->search(
        { branchcode => $branch_limit },
        { order_by   => { '-asc' => 'desk_name' } }
    );
}

=head3 all

[% Desks.all %]

returns all desks existing at all libraries

=cut

sub all {

    my ($self) = @_;
    return Koha::Desks->search();
}

1;
