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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Template::Plugin;
use base qw( Template::Plugin );

use C4::Koha;
use C4::Context;
use Koha::Desks;

=head1 NAME

Koha::Template::Plugin::Desks - A module for dealing with desks in templates

=head1 DESCRIPTION

This plugin contains getters functions, to fetch all desks a library
got or the current one.

=head2 Methods

=head3 GetName

[% Desk.GetName(desk_id) %]

return desk name or empty string

=cut

sub GetName {
    my ( $self, $desk_id ) = @_;
    my $d = Koha::Desks->search( { desk_id => $desk_id} )->unblessed;
    return @$d ? $d->{'desk_name'} : q{};
}

=head3 GetLoggedInDeskId

[% Desks.GetLoggedInDeskId %]

return the desk name that is attached to the session or empty string

=cut

sub GetLoggedInDeskId {
    my ($self) = @_;

    return C4::Context->userenv ?
        C4::Context->userenv->{'desk_id'} :
        '';
}

=head3 GetLoggedInDeskName

[% Desks.GetLoggedInDeskName %]

Return the desk name that is attached to the session or empty string

=cut

sub GetLoggedInDeskName {
    my ($self) = @_;

    return C4::Context->userenv ?
        C4::Context->userenv->{'desk_name'} :
        '';
}

=head3 all

[% Desks.all %]

returns all desks existing at the library

=cut

sub all {
    my ( $self, $params ) = @_;
    my $selected = $params->{selected};
    my $unfiltered = $params->{unfiltered} || 0;
    my $search_params = $params->{search_params} || {};

    if ( !$unfiltered ) {
        $search_params->{only_from_group} = $params->{only_from_group} || 0;
    }

    my $desks = $unfiltered
      ? Koha::Desks->search( $search_params, { order_by => ['desk_name'] } )->unblessed
      : Koha::Desks->search_filtered( $search_params, { order_by => ['desk_name'] } )->unblessed;

    for my $d ( @$desks ) {
        if (       defined $selected and $d->{desk_id} eq $selected
            or not defined $selected and C4::Context->userenv and $d->{branchcode} eq ( C4::Context->userenv->{desk_id} // q{} )
        ) {
            $d->{selected} = 1;
        }
    }

    return $desks;
}

=head3 defined

[% Desks.defined %]

return 1 if there is at least a desk defined for the library.

=cut

sub defined {
    my ( $self ) = @_;
    my $desks = Koha::Desks->search()->unblessed;
    if (@$desks) {
        return 1 ;
    }
    else {
        return 0;
    }
}

1;
