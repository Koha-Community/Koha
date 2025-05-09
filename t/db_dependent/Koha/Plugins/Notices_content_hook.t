#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 5;
use Test::Warn;

use File::Basename;

use t::lib::Mocks;
use t::lib::TestBuilder;

use C4::Letters qw( GetPreparedLetter );

BEGIN {
    # Mock pluginsdir before loading Plugins module
    my $path = dirname(__FILE__) . '/../../../lib/plugins';
    t::lib::Mocks::mock_config( 'pluginsdir', $path );

    use_ok('Koha::Plugins');
    use_ok('Koha::Plugins::Handler');
    use_ok('Koha::Plugin::Test');
}

t::lib::Mocks::mock_config( 'enable_plugins', 1 );

my $schema  = Koha::Database->schema;
my $builder = t::lib::TestBuilder->new();

subtest 'notices_content() tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin();

    my $dbh = C4::Context->dbh;

    # just to be sure
    $dbh->do(q|DELETE FROM letter WHERE module='test'|);

    my $plugins = Koha::Plugins->new;
    warning_is { $plugins->InstallPlugins; } undef;

    my $prepared_letter;

    my $sth = $dbh->prepare(
        q{
        INSERT INTO letter (module, code, name, title, content)
        VALUES ('test',?,'Test',?,?)}
    );

    $sth->execute(
        "TEST_HOLD",
        "[% hold.id %]",
        "[% plugin_content.test.custom_attribute.message %]. "
            . "We identified this is the '[% plugin_content.test.custom_attribute.module %]' module"
    );

    my $hold = $builder->build_object( { class => 'Koha::Holds' } );
    warning_like {
        $prepared_letter = GetPreparedLetter(
            (
                module      => 'test',
                letter_code => 'TEST_HOLD',
                tables      => {
                    reserves => $hold->unblessed,
                }
            )
        )
    }
    qr/transform_prepared_letter called with letter content/,
        'GetPreparedLetter calls the transform_prepared_letter hook';

    is(
        $prepared_letter->{content},
        "notices_content() called. We identified this is the 'test' module"
            . "\nThank you for using your local library!",
        'Patron object used correctly with scalar for content'
    );
    is(
        $prepared_letter->{title},
        $hold->id . "!",
        'Hold object used correctly with scalar for title'
    );

    $schema->storage->txn_rollback;
    Koha::Plugins::Methods->delete;

};
