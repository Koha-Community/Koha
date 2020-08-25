package Koha::Template::Plugin::Context;

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

use base qw( Template::Plugin );

use C4::Context;

=head1 NAME

Koha::Template::Plugin::Scalar - Return object set in scalar context

=head1 SYNOPSIS

If you need to force scalar context when calling a method on a object set.
Especially useful to call ->search

=cut

=head1 API

=head2 Class Methods

=cut

=head3 Scalar

Return object set in scalar context

=cut

sub Scalar {
    my ( $self, $set, $method ) = @_;
    return unless $set;
    $set = $set->$method;
    return $set;
}

1;
