# Copyright 2016 KohaSuomi
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;
use Test::More;
use Scalar::Util qw(blessed);
use Try::Tiny;

use C4::Biblio::Diff;

use t::db_dependent::Biblio::Diff::localRecords;
use t::lib::TestObjects::BiblioFactory;


subtest "C4::Biblio::Diff", \&biblioDiff;
sub biblioDiff {
    my $testContext = {};
    eval {
        my $records = t::db_dependent::Biblio::Diff::localRecords::create($testContext);
        my @recKeys = sort(keys(%$records));

        my $diff = C4::Biblio::Diff->new(
                        {excludedFields => ['999', '942', '952']},
                        $records->{ $recKeys[0] },
                        $records->{ $recKeys[1] },
                        $records->{ $recKeys[2] },
                    );
        my $d = $diff->diffRecords();

        my $expectedDiff = {
            '000' => [
                '00510cam a22002054a 4500',
                '00618cam a22002294a 4500',
                '01096cam a22003134i 4500',
            ],
            '001' => [
                '300841',
                '21937',
                '4312727',
            ],
            '003' => [
                'KYYTI',
                'OUTI',
                undef,
            ],
            '007' => [
                undef,
                undef,
                'ta',
            ],
            '020' => [
                {
                    'a' => [
                        [
                            '9510108303',
                            '9510108304',
                            '9510108305',
                        ],
                    ],
                    'q' => [
                        [
                            'NID.',
                            'NID.',
                            undef,
                        ],
                    ],
                    'c' => [
                        [
                            undef,
                            '7.74 EUR',
                            undef,
                        ],
                    ],
                },
            ],
            '041' => [
                {
                    '_i1' => [
                        undef,
                        undef,
                        '0',
                    ],
                    '_i2' => [
                        undef,
                        undef,
                        ' '
                    ],
                    'a' => [
                        [
                            undef,
                            undef,
                            'lat',
                        ],
                        [
                            undef,
                            undef,
                            'swe',
                        ],
                        [
                            undef,
                            undef,
                            'eng',
                        ],
                    ],
                },
            ],
            '245' => [
                {
                    '_i2' => [
                        '4',
                        '0',
                        '0',
                    ],
                    'a' => [
                        [
                            'THE WISHING TREE /',
                            'TYRANNIT VOIVAT PAREMMIN :',
                            'TYRANNIT VOIVAT PAREMMIN :',
                        ],
                    ],
                    'b' => [
                        [
                            undef,
                            'RUNOJA /',
                            'RUNOJA /',
                        ],
                    ],
                    'c' => [
                        [
                            'USHA BAHL.',
                            'AKI LUOSTARINEN.',
                            'AKI LUOSTARINEN.',
                        ],
                    ],
                },
                {
                    '_i1' => [
                        undef,
                        '0',
                        undef,
                    ],
                    '_i2' => [
                        undef,
                        '0',
                        undef,
                    ],
                    'a' => [
                        [
                            undef,
                            'TYRANNIT VOIVAT PARHAITEN :',
                            undef,
                        ],
                    ],
                },
            ],
        };

        is_deeply($d, $expectedDiff, "Deep diff is as expected");


        $diff = C4::Biblio::Diff->new(
                        {},
                        $records->{ $recKeys[1] },
                        $records->{ $recKeys[2] },
                        $records->{ $recKeys[0] },
                    );
        $d = $diff->diffRecords();
        is($d->{'003'}->[0],
           'OUTI',
           "Same diff, different order");
        is($d->{'003'}->[1],
           undef,
           "Same diff, different order");
        is($d->{'003'}->[2],
           'KYYTI',
           "Same diff, different order");
    };
    if ($@) {
        ok(0, $@);
    }
    t::lib::TestObjects::ObjectFactory->tearDownTestContext($testContext);
}

subtest "C4::Biblio::Diff undef indexes", \&biblioDiffUndefIndexes;
sub biblioDiffUndefIndexes {
    my $testContext = {};
    eval {
        my $records = t::db_dependent::Biblio::Diff::localRecords::create2($testContext);
        my @recKeys = sort(keys(%$records));

        my $diff = C4::Biblio::Diff->new(
                        {excludedFields => ['999', '942', '952']},
                        $records->{ $recKeys[0] },
                        $records->{ $recKeys[1] },
                    );
        my $d = $diff->diffRecords();

        my $expectedDiff = {
            '020' => [
                {
                    'a' => [
                        [
                            '9510107417',
                            '9510107418',
                        ],
                    ],
                }
            ]
        };

        is_deeply($d, $expectedDiff, "Deep diff is as expected");
    };
    if ($@) {
        ok(0, $@);
    }
    t::lib::TestObjects::ObjectFactory->tearDownTestContext($testContext);
}



subtest "Grep changes", \&grepChanges;
sub grepChanges {
    my $testContext = {};
    eval {
        my $records = t::db_dependent::Biblio::Diff::localRecords::create($testContext);
        my @recKeys = sort(keys(%$records));

        my $diff = C4::Biblio::Diff->new(
                        {excludedFields => ['999', '942', '952']},
                        $records->{ $recKeys[0] },
                        $records->{ $recKeys[1] },
                        $records->{ $recKeys[2] },
                    );
        my $d = $diff->diffRecords();

        my $changes = C4::Biblio::Diff::grepChangedElements($d, [{f=>'020', sf=>'a'},
                                                                 {f=>'041', sf=>'a'},
                                                                 {f=>'003'}]);
        is(@$changes, 5, "Got five separate changes");
        ok(blessed($changes->[0]) && $changes->[0]->isa('C4::Biblio::Diff::Change'), "Change is of correct type");
        is($changes->[0]->getFieldCode, '020', "Field");
        is($changes->[0]->getSubfieldCode, 'a', "Subfield");
        is($changes->[0]->getVal(0), '9510108303', "Val1");
        is($changes->[0]->getVal(1), '9510108304', "Val2");
        is($changes->[0]->getVal(2), '9510108305', "Val3");
        ok(blessed($changes->[4]) && $changes->[4]->isa('C4::Biblio::Diff::Change'), "Change is of correct type");
        is($changes->[4]->getFieldCode, '003', "Field");
        is($changes->[4]->getSubfieldCode, undef, "No subfield");
        is($changes->[4]->getVal(0), 'KYYTI', "Val1");
        is($changes->[4]->getVal(1), 'OUTI',  "Val2");
        is($changes->[4]->getVal(2), undef,   "Val3");


    };
    if ($@) {
        ok(0, $@);
    }
    t::lib::TestObjects::ObjectFactory->tearDownTestContext($testContext);
}



done_testing();