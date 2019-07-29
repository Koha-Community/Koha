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

use Test::More tests => 2;
use t::lib::Mocks;

use MARC::Field;
use MARC::Record;

use C4::Biblio;

subtest 'GetMarcNotes MARC21' => sub {
    plan tests => 11;
    t::lib::Mocks::mock_preference( 'NotesBlacklist', '520' );

    my $record = MARC::Record->new;
    $record->append_fields(
        MARC::Field->new( '500', '', '', a => 'Note1' ),
        MARC::Field->new( '505', '', '', a => 'Note2', u => 'http://someserver.com' ),
        MARC::Field->new( '520', '', '', a => 'Note3 skipped' ),
        MARC::Field->new( '541', '0', '', a => 'Note4 skipped on opac' ),
        MARC::Field->new( '541', '', '', a => 'Note5' ),
    );
    my $notes = C4::Biblio::GetMarcNotes( $record, 'MARC21' );
    is( $notes->[0]->{marcnote}, 'Note1', 'First note' );
    is( $notes->[1]->{marcnote}, 'Note2', 'Second note' );
    is( $notes->[2]->{marcnote}, 'http://someserver.com', 'URL separated' );
    is( $notes->[3]->{marcnote}, 'Note4 skipped on opac',"Not shows if not opac" );
    is( $notes->[4]->{marcnote}, 'Note5', 'Fifth note' );
    is( @$notes, 5, 'No more notes' );
    $notes = C4::Biblio::GetMarcNotes( $record, 'MARC21', 1 );
    is( $notes->[0]->{marcnote}, 'Note1', 'First note' );
    is( $notes->[1]->{marcnote}, 'Note2', 'Second note' );
    is( $notes->[2]->{marcnote}, 'http://someserver.com', 'URL separated' );
    is( $notes->[3]->{marcnote}, 'Note5', 'Fifth note shows after fourth skipped' );
    is( @$notes, 4, 'No more notes' );

};

subtest 'GetMarcNotes UNIMARC' => sub {
    plan tests => 3;
    t::lib::Mocks::mock_preference( 'NotesBlacklist', '310' );

    my $record = MARC::Record->new;
    $record->append_fields(
        MARC::Field->new( '300', '', '', a => 'Note1' ),
        MARC::Field->new( '300', '', '', a => 'Note2' ),
        MARC::Field->new( '310', '', '', a => 'Note3 skipped' ),
    );
    my $notes = C4::Biblio::GetMarcNotes( $record, 'UNIMARC' );
    is( $notes->[0]->{marcnote}, 'Note1', 'First note' );
    is( $notes->[1]->{marcnote}, 'Note2', 'Second note' );
    is( @$notes, 2, 'No more notes' );
};
