#!/usr/bin/env perl

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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 4;
use Test::Exception;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::Database;

BEGIN {
    use_ok('Koha::Module::Policy');
    use_ok('Koha::Module::Policy::Checkin');
}

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'Koha::Module::Policy base class tests' => sub {

    plan tests => 5;

    subtest 'new() tests' => sub {

        plan tests => 5;

        $schema->storage->txn_begin;

        my $patron  = $builder->build_object( { class => 'Koha::Patrons' } );
        my $library = $builder->build_object( { class => 'Koha::Libraries' } );

        throws_ok {
            Koha::Module::Policy->new( { library => $library->branchcode } );
        }
        'Koha::Exceptions::MissingParameter', 'Throws without user';

        my $policy;
        lives_ok {
            $policy = Koha::Module::Policy->new( { user => $patron } );
        }
        'Constructor succeeds with user only (library optional)';

        lives_ok {
            $policy = Koha::Module::Policy->new(
                {
                    user    => $patron,
                    library => $library->branchcode,
                }
            );
        }
        'Constructor succeeds with user and library';

        is( $policy->user->id, $patron->id,          'user accessor returns the patron' );
        is( $policy->library,  $library->branchcode, 'library accessor returns the branchcode' );

        $schema->storage->txn_rollback;
    };

    subtest '_build_hashref() tests' => sub {

        plan tests => 1;

        $schema->storage->txn_begin;

        my $patron  = $builder->build_object( { class => 'Koha::Patrons' } );
        my $library = $builder->build_object( { class => 'Koha::Libraries' } );

        my $policy = Koha::Module::Policy->new(
            {
                user    => $patron,
                library => $library->branchcode,
            }
        );

        throws_ok {
            $policy->_build_hashref;
        }
        'Koha::Exception', 'Base class _build_hashref throws (abstract)';

        $schema->storage->txn_rollback;
    };

    subtest 'module() tests' => sub {

        plan tests => 3;

        $schema->storage->txn_begin;

        my $patron = $builder->build_object( { class => 'Koha::Patrons' } );

        throws_ok {
            Koha::Module::Policy->new( { user => $patron } )->module;
        }
        'Koha::Exception', 'Base class module throws (abstract)';

        throws_ok {
            Koha::Module::Policy->new( { user => $patron } )->to_hashref;
        }
        'Koha::Exception', 'Base class to_hashref throws (abstract)';

        is( Koha::Module::Policy::Checkin->module, 'checkin', 'Subclasses return their module name' );

        $schema->storage->txn_rollback;
    };

    subtest 'to_hashref() tests' => sub {

        plan tests => 8;

        $schema->storage->txn_begin;

        t::lib::Mocks::mock_preference( 'AudioAlerts',     1 );
        t::lib::Mocks::mock_preference( 'CatalogConcerns', 0 );

        my $patron = $builder->build_object( { class => 'Koha::Patrons' } );

        my $policy = Koha::Module::Policy::Test->new( { user => $patron } );
        my $hash   = $policy->to_hashref;

        is_deeply( [ sort keys %{$hash} ], [qw( global module test )], 'The policy is an envelope' );
        is( $hash->{module}, 'test', 'The envelope carries the module name' );

        is_deeply(
            $hash->{global}, { audio_alerts => 1, catalog_concerns => 0 },
            'A subclass cannot override the global namespace'
        );
        isa_ok( $hash->{global}->{audio_alerts},     'JSON::PP::Boolean', 'audio_alerts' );
        isa_ok( $hash->{global}->{catalog_concerns}, 'JSON::PP::Boolean', 'catalog_concerns' );

        is_deeply(
            $hash->{test},
            {
                global       => { audio_alerts => 0, catalog_concerns => 1, bogus => 1 },
                some_feature => 1,
            },
            'Module-specific keys are placed under the module name'
        );

        is( $policy->to_hashref, $hash, 'The hashref is cached' );

        throws_ok {
            Koha::Module::Policy::BogusGlobal->new( { user => $patron } )->to_hashref;
        }
        'Koha::Exception', 'A module cannot be named after an envelope key';

        $schema->storage->txn_rollback;
    };

    subtest 'scope() tests' => sub {

        plan tests => 1;

        $schema->storage->txn_begin;

        my $patron  = $builder->build_object( { class => 'Koha::Patrons' } );
        my $library = $builder->build_object( { class => 'Koha::Libraries' } );

        my $policy = Koha::Module::Policy::Checkin->new(
            {
                user    => $patron,
                library => $library->branchcode,
            }
        );

        is( $policy->scope, 'checkin', 'scope() derives from class name' );

        $schema->storage->txn_rollback;
    };
};

package Koha::Module::Policy::BogusGlobal;

use parent 'Koha::Module::Policy';

sub module         { return 'global' }
sub _build_hashref { return { audio_alerts => 0 } }

package Koha::Module::Policy::Test;

use parent 'Koha::Module::Policy';

sub module { return 'test' }

sub _build_hashref {
    return {
        global       => { audio_alerts => 0, catalog_concerns => 1, bogus => 1 },
        some_feature => 1,
    };
}

1;
