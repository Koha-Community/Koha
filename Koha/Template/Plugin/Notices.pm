package Koha::Template::Plugin::Notices;

# Copyright ByWater Solutions 2023

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

use Koha::Notice::Templates;

=head1 NAME

Koha::Template::Plugin::Notices

=head1 DESCRIPTION

The Asset plugin is a helper that gets notice template objects
accepting an optional module parameter

=head1 SYNOPSIS

    [% USE Notices %]

    [% SET notices = Notices.GetTemplates( 'patron_slip' ) %]
    [% FOREACH notice IN notices %]
    ...
    [% END %]

=cut

=head1 API

=head2 Class Methods

=cut

=head3 GetTemplates

This routine searches the Koha::Notice::Template objects with passed module
parameter

=cut

sub GetTemplates {
    my ( $self, $module ) = @_;
    my $params = {};
    $params->{module} = $module if $module;

    my @letters = Koha::Notice::Templates->search($params)->as_list;

    return \@letters;
}

1;
