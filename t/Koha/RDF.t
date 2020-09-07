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
use Test::More tests => 3;

use t::lib::Mocks;

use_ok("Koha::RDF");

my $rdf = Koha::RDF->new;

t::lib::Mocks::mock_preference('OPACBaseURL', 'http://koha-community.org');
my $well_formed_uri = $rdf->mint_uri('biblio',1);
is($well_formed_uri,'http://koha-community.org/bib/1','Successfully minted a RDF URI');

t::lib::Mocks::mock_preference('OPACBaseURL', 'koha-community.org');
my $malformed_uri = $rdf->mint_uri('biblio',2);
is($malformed_uri,undef,"Didn't mint URI due to missing URI scheme");
