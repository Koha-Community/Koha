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

use utf8;

use t::lib::TestBuilder;

use C4::Letters;
use Koha::Database;

my $schema = Koha::Database->schema;
$schema->storage->txn_begin();

my $builder = t::lib::TestBuilder->new();
my $dbh = C4::Context->dbh;
$dbh->do(q{INSERT INTO letter (module, code, name, title, content) VALUES ('test', 'TEST_MESSAGE','Test', '[% biblio.title %]', "
----
<<biblio.title>>
----
")});
my $biblio_1 = $builder->build_sample_biblio({ title => "heÄllo" });
my $biblio_2 = $builder->build_sample_biblio({ title => "hell❤️" });
my $patron = $builder->build_object({ class => 'Koha::Patrons', value => { email => 'test@example.org'} });
my $letter = C4::Letters::GetPreparedLetter(
    (
        module      => 'test',
        letter_code => 'TEST_MESSAGE',
        tables      => {
            biblio => $biblio_1->biblionumber,
        },
    )
);

C4::Message->enqueue($letter, $patron->unblessed, 'email');
my $message = C4::Message->find_last_message($patron->unblessed, 'TEST_MESSAGE', 'email');
like( $message->{metadata}, qr{heÄllo} );

$letter = C4::Letters::GetPreparedLetter(
    (
        module      => 'test',
        letter_code => 'TEST_MESSAGE',
        tables      => {
            biblio => $biblio_2->biblionumber,
        },
    )
);
$message->append($letter);
like( $message->{metadata}, qr{heÄllo} );
like( $message->{metadata}, qr{hell❤️} );
