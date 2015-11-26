package Koha::QueryParser::Driver::PQF::Util;

# This file is part of Koha.
#
# Copyright 2012 C & P Bibliography Services
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

use Scalar::Util qw(looks_like_number);

use strict;
use warnings;

=head1 NAME

    Koha::QueryParser::Driver::PQF::Util - Utility module for PQF QueryParser driver

=head1 FUNCTIONS

=head2 attributes_to_attr_string

    Koha::QueryParser::Driver::PQF::Util(%attributes);

    Koha::QueryParser::Driver::PQF::Util({ '1' => '1003', '4' => '6' });

Convert a hashref with a Bib-1 mapping into its PQF string representation.

=cut

sub attributes_to_attr_string {
    my ($attributes) = @_;
    my $attr_string = '';
    foreach my $key ( sort keys %{$attributes} ) {
        next unless looks_like_number($key);
        $attr_string .= ' @attr ' . $key . '=' . $attributes->{ $key } . ' ';
    }
    $attr_string =~ s/^\s*//;
    $attr_string =~ s/\s*$//;
    $attr_string .= ' ' . $attributes->{''} if defined $attributes->{''};
    return $attr_string;
}

1;
