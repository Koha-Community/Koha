#!/usr/bin/perl

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

=head1 default_search_class.pl

The only purpose of this script is to load C4::Context and print
the default search class from the QueryParser object

=cut

use t::lib::Mocks;
use C4::Context;

t::lib::Mocks::mock_preference("UseQueryParser","1");

my $QParser = C4::Context->queryparser();
my $default_search_class = $QParser->default_search_class();

print $default_search_class;

exit 0;
