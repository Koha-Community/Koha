#!/usr/bin/perl
#
# Copyright 2020 University of Helsinki
#
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

use Test::More tests => 1;
use t::lib::TestBuilder;

use C4::Biblio;
use Koha::Util::Search;
use MARC::Field;

my $builder = t::lib::TestBuilder->new;

subtest 'get_component_part_query' => sub {
    plan tests => 1;

    my $biblio = $builder->build_sample_biblio();
    my $biblionumber = $biblio->biblionumber;
    my $record = GetMarcBiblio({ biblionumber => $biblionumber });
    my $marc_001_field = MARC::Field->new('001', $biblionumber);
    $record->append_fields($marc_001_field);
    ModBiblioMarc($record, $biblionumber);

    is(Koha::Util::Search::get_component_part_query($biblionumber), "rcn=\"$biblionumber\"");
};
