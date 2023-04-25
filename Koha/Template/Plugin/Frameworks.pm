package Koha::Template::Plugin::Frameworks;

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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Template::Plugin;
use base qw( Template::Plugin );

use Koha::BiblioFrameworks;

=head1 NAME

Koha::Template::Plugin::Frameworks - A module for dealing with biblio frameworks in templates

=head1 DESCRIPTION

This plugin contains functions for getting frameowrk information in the template

=head2 Methods

=head3 GetName

[% Frameworks.GetName( frameworkcode ) %]

Return the display name (frameworktext field) for a framework, or the passed code if the framework
is not found

=cut


sub GetName {
    my ( $self, $frameworkcode ) = @_;
    return q{} unless defined $frameworkcode;
    return q{} if $frameworkcode eq q{};

    my $f = Koha::BiblioFrameworks->find($frameworkcode);

    my $frameworktext = $f ? $f->frameworktext : $frameworkcode;
    return $frameworktext;
}

1;
