#!/usr/bin/perl
#
# This file is part of Koha.
#
# Copyright (c) 2015   Mark Tompsett
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

use C4::Context;

use Test::More tests => 8;

BEGIN {
    use_ok('C4::Context');
    use_ok('C4::Koha');
}

can_ok('C4::Koha','GetKohaAuthorisedValuesMapping');

my $avMappingOPAC;
my $avMappingStaff;
my $avMappingUndef1;
my $avMappingUndef2;
my $avMappingUndef3;
SKIP: {
    my $dbh = C4::Context->dbh;
    my $count = $dbh->selectrow_arrayref("SELECT COUNT(*) FROM marc_subfield_structure WHERE kohafield LIKE 'item%';");
    skip "Lacking item mappings in marc_subfield_structure",5 unless ($count && $count->[0]>0);
    $count = $dbh->selectrow_arrayref("SELECT COUNT(*) FROM authorised_values;");
    skip "Lacking authorised_values",5 unless ($count && $count->[0]>0);
    $avMappingOPAC   = GetKohaAuthorisedValuesMapping( { interface => 'opac' });
    $avMappingStaff  = GetKohaAuthorisedValuesMapping( { interface => 'staff' });
    $avMappingUndef1 = GetKohaAuthorisedValuesMapping( { interface => undef });
    $avMappingUndef2 = GetKohaAuthorisedValuesMapping( { } );
    $avMappingUndef3 = GetKohaAuthorisedValuesMapping();
    is_deeply($avMappingUndef1,$avMappingStaff,"Undefined interface = Staff test 1");
    is_deeply($avMappingUndef2,$avMappingStaff,"Undefined interface = Staff test 2");
    is_deeply($avMappingUndef3,$avMappingStaff,"Undefined interface = Staff test 3");
    isnt($avMappingOPAC ,undef,"OPAC has a mapping");
    isnt($avMappingStaff,undef,"Staff has a mapping");
}
