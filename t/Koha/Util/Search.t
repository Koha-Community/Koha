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

use t::lib::Mocks;
use t::lib::TestBuilder;

use C4::Biblio qw( GetMarcBiblio ModBiblioMarc );
use Koha::Util::Search;
use MARC::Field;

my $builder = t::lib::TestBuilder->new;

subtest 'get_component_part_query' => sub {
    plan tests => 3;

    my $biblio = $builder->build_sample_biblio();
    my $biblionumber = $biblio->biblionumber;
    my $record = GetMarcBiblio({ biblionumber => $biblionumber });

    t::lib::Mocks::mock_preference( 'UseControlNumber', '0' );
    is(Koha::Util::Search::get_component_part_query($biblionumber), "Host-item:(Some boring read)", "UseControlNumber disabled");

    t::lib::Mocks::mock_preference( 'UseControlNumber', '1' );
    my $marc_001_field = MARC::Field->new('001', $biblionumber);
    $record->append_fields($marc_001_field);
    ModBiblioMarc($record, $biblionumber);

    is(Koha::Util::Search::get_component_part_query($biblionumber), "rcn:$biblionumber AND (bib-level:a OR bib-level:b)", "UseControlNumber enabled without MarcOrgCode");

    my $marc_003_field = MARC::Field->new('003', 'OSt');
    $record->append_fields($marc_003_field);
    ModBiblioMarc($record, $biblionumber);
    is(Koha::Util::Search::get_component_part_query($biblionumber), "((rcn:$biblionumber AND cni:OSt) OR rcn:OSt $biblionumber) AND (bib-level:a OR bib-level:b)", "UseControlNumber enabled with MarcOrgCode");
};
