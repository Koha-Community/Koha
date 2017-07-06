#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright 2017 Koha-Suomi Oy
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
use Test::Warn;
use Data::Dumper qw(Dumper);

use t::lib::TestBuilder;

use Koha::Database;
use Koha::Auth::PermissionManager;

my $schema = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

$schema->storage->txn_begin;

my $manager = Koha::Auth::PermissionManager->new();

subtest 'borrowers.flags to Koha-Suomi permission' => sub {
    plan tests => 4;

    subtest 'Flags => 0' => sub {
        plan tests => 1;

        my $patron;
        my $permissions;
        my $borrowers = $builder->build({
            source => 'Borrower',
            value  => {
                flags => 0
            }
        });

        $patron = Koha::Patrons->find($borrowers->{'borrowernumber'});
        $permissions = $manager->getBorrowerPermissions($patron);

        is(scalar(@$permissions),0, 'Patron has no permissions');
    };

    subtest 'Permission module => superlibrarian' => sub {
        plan tests => 2;

        my $patron;
        my $permissions;
        my $borrowers = $builder->build({
            source => 'Borrower',
            value  => {
                flags => 1
            }
        });

        my $number_of_borrowers_permissions = Koha::Auth::Permissions->search({
            module => 'superlibrarian'
        })->count;
        $patron = Koha::Patrons->find($borrowers->{'borrowernumber'});
        $permissions = $manager->getBorrowerPermissions($patron);

        is(scalar(@$permissions), $number_of_borrowers_permissions,
           'Patron has all superlibrarian permissions');
        my $expected_permission = Koha::Auth::Permissions->find({
            code => 'superlibrarian' })->permission_id;
        is($permissions->[0]->permission_id, $expected_permission,
           'Patron has superlibrarian');
    };

    subtest 'Permission module => borrowers' => sub {
        plan tests => 2;

        my $patron;
        my $permissions;
        my $borrowers = $builder->build({
            source => 'Borrower',
            value  => {
                flags => 16
            }
        });

        my $number_of_borrowers_permissions = Koha::Auth::Permissions->search({
            module => 'borrowers'
        })->count;
        $patron = Koha::Patrons->find($borrowers->{'borrowernumber'});
        $permissions = $manager->getBorrowerPermissions($patron);

        is(scalar(@$permissions), $number_of_borrowers_permissions,
           'Patron has all borrowers permissions');
        is($manager->hasPermission($patron, 'borrowers', 'view_borrowers'), 1,
           'Patron has view_borrowers');
    };

    subtest 'Permission module => circulate' => sub {
        plan tests => 8;

        my $patron;
        my $permissions;
        my $borrowers = $builder->build({
            source => 'Borrower',
            value  => {
                flags => 2
            }
        });

        my $number_of_borrowers_permissions = Koha::Auth::Permissions->search({
            module => 'circulate'
        })->count;
        $patron = Koha::Patrons->find($borrowers->{'borrowernumber'});
        $permissions = $manager->getBorrowerPermissions($patron);

        my $ids = {};
        foreach my $permission (@$permissions) {
            $ids->{$permission->permission_id} = $permission->permission_id;
        };

        is(scalar(@$permissions), $number_of_borrowers_permissions,
           'Patron has all circulate permissions');
        my $expected_permission = Koha::Auth::Permissions->find({
            code => 'circulate_remaining_permissions' })->permission_id;
        is($ids->{$expected_permission}, $expected_permission,
           'Patron has circulate_remaining_permissions');
        $expected_permission = Koha::Auth::Permissions->find({
            code => 'override_renewals' })->permission_id;
        is($ids->{$expected_permission}, $expected_permission,
           'Patron has override_renewals');
        $expected_permission = Koha::Auth::Permissions->find({
            code => 'overdues_report' })->permission_id;
        is($ids->{$expected_permission}, $expected_permission,
           'Patron has overdues_report');
        $expected_permission = Koha::Auth::Permissions->find({
            code => 'force_checkout' })->permission_id;
        is($ids->{$expected_permission}, $expected_permission,
           'Patron has force_checkout');
        $expected_permission = Koha::Auth::Permissions->find({
            code => 'manage_restrictions' })->permission_id;
        is($ids->{$expected_permission}, $expected_permission,
           'Patron has manage_restrictions');
        $expected_permission = Koha::Auth::Permissions->find({
            code => 'superlibrarian' })->permission_id;
        ok(!exists $ids->{$expected_permission},
           'Patron does not have superlibrarian');
        $expected_permission = Koha::Auth::Permissions->find({
            code => 'place_holds' })->permission_id;
        ok(!exists $ids->{$expected_permission},
           'Patron does not have place_holds');
    };

};

$schema->storage->txn_rollback;

1;
